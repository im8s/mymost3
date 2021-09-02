package com.shiku.im.service;

import com.alibaba.fastjson.JSONObject;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.entity.Collect;
import com.shiku.im.user.dao.CollectionDao;
import com.shiku.im.user.dao.CourseDao;
import com.shiku.im.user.dao.CourseMessageDao;
import com.shiku.im.user.entity.Course;
import com.shiku.im.user.entity.CourseMessage;
import com.shiku.im.user.entity.Emoji;
import com.shiku.im.user.service.CollectService;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.service.impl.AbstractCollectService;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

@Slf4j
@Service
public class CollectServiceImpl extends AbstractCollectService {






    /** @Description:（收藏）
     * @param emoji
     **/
    public Emoji addNewEmoji(String emoji) {
        Emoji newEmoji = null;
        if (StringUtil.isEmpty(emoji))
            throw new ServiceException("addNewEmoji emoji is null");
        List<Emoji> emojiList = JSONObject.parseArray(emoji, Emoji.class);
        for (Emoji emojis : emojiList) {
            emojis.setUserId(ReqUtil.getUserId());
//			Query<Emoji> query = getDatastore().createQuery(Emoji.class).field("msg").equal(emojis.getMsg()).field("type").equal(emojis.getType()).field("userId").equal(emojis.getUserId());
            Emoji emoji1;
            if (!StringUtil.isEmpty(emojis.getMsgId())) {
                emoji1 = collectionDao.getEmoji(emojis.getMsg(), emojis.getType(), emojis.getUserId(), emojis.getMsgId());
            } else {
                emoji1 = collectionDao.getEmoji(emojis.getMsg(), emojis.getType(), emojis.getUserId(), null);
            }
            if (null != emoji1) {
                // 相同内容支持继续收藏
                if (null != emoji1.getMsgId()) {
                    if (emoji1.getMsgId().equals(emojis.getMsgId())) {
                        throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
                    }
                }
                if (null != emoji1.getCollectMsgId()) {
                    if (emoji1.getCollectMsgId().equals(emojis.getCollectMsgId())) {
                        throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
                    }
                }
            }
            if (!StringUtil.isEmpty(emojis.getMsgId()) && 0 == emojis.getCollectType()) {
                // 添加收藏
                newEmoji = newAddCollection(ReqUtil.getUserId(), emojis);
            } else if (StringUtil.isEmpty(emojis.getMsgId()) && 0 == emojis.getCollectType()) {
                // 添加表情
                newEmoji = newAddEmoji(ReqUtil.getUserId(), emojis);
            } else if (StringUtil.isEmpty(emojis.getMsgId()) && -1 == emojis.getCollectType()) {
                // 无关消息的相关收藏
                newEmoji = newAddCollection(ReqUtil.getUserId(), emojis);
            }
            if (StringUtil.isEmpty(emojis.getMsgId()) && 1 == emojis.getCollectType() && StringUtil.isEmpty(emojis.getTitle()) && StringUtil.isEmpty(emojis.getShareURL())) {
                // 朋友圈收藏
                newEmoji = msgCollect(ReqUtil.getUserId(), emojis, 0);
                saveCollect(new ObjectId(newEmoji.getCollectMsgId()), userCoreService.getNickName(emojis.getUserId()), emojis.getUserId());
            } else if (StringUtil.isEmpty(emojis.getMsgId()) && 1 == emojis.getCollectType() && !StringUtil.isEmpty(emojis.getTitle()) && !StringUtil.isEmpty(emojis.getShareURL())) {
                // SDK分享链接
                newEmoji = msgCollect(ReqUtil.getUserId(), emojis, 1);
                saveCollect(new ObjectId(newEmoji.getCollectMsgId()), userCoreService.getNickName(emojis.getUserId()), emojis.getUserId());
            }
        }
        return newEmoji;
    }


    private Emoji msgCollect(Integer userId,Emoji msgEmoji,int isShare) {
        StringBuffer buffer = new StringBuffer();
        if(msgEmoji.getType() != 5){
            String[] msgs = msgEmoji.getMsg().split(",");
            String copyFile = "";
            String newCopyFile = null;
            for (int i = 0; i < msgs.length; i++) {
                copyFile = ConstantUtil.copyFile(-1, msgs[i]);
                buffer.append(copyFile).append(",");
            }
            newCopyFile = buffer.deleteCharAt(buffer.length()-1).toString();
            msgEmoji.setUrl(newCopyFile);
        }
        Emoji emoji = null;
        if(0 == isShare){
            emoji = new Emoji(msgEmoji.getUserId(), msgEmoji.getType(), (5 == msgEmoji.getType() ? null : msgEmoji.getUrl()), msgEmoji.getMsg(),
                    msgEmoji.getFileName(), msgEmoji.getFileSize(), msgEmoji.getFileLength(), msgEmoji.getCollectType(),msgEmoji.getCollectContent(),msgEmoji.getCollectMsgId());
        }else if(1 == isShare){
            emoji = new Emoji(msgEmoji.getUserId(), msgEmoji.getType(), (5 == msgEmoji.getType() ? null : msgEmoji.getUrl()), msgEmoji.getMsg(),
                    msgEmoji.getFileName(), msgEmoji.getFileSize(), msgEmoji.getFileLength(), msgEmoji.getCollectType(),msgEmoji.getCollectContent(),msgEmoji.getCollectMsgId(),msgEmoji.getTitle(),msgEmoji.getShareURL());
        }
//		getDatastore().save(emoji);
        collectionDao.addEmoji(emoji);
//		// 维护朋友圈收藏
        userRedisService.deleteUserCollectCommon(userId);
        return emoji;
    }

    /** @Description:（添加收藏）
     * @param userId
     * @param emoji
     * @return
     **/
    public synchronized Emoji newAddCollection(Integer userId, Emoji emoji) {
        if (emoji.getType() != 5) {
            Emoji dbEmoji = collectionDao.queryEmojiByUrlAndType(emoji.getMsg(),emoji.getType(),userId);
            if(null!=dbEmoji){
                throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
            }
            try {
                String copyFile = ConstantUtil.copyFile(-1, emoji.getMsg());
                emoji.setUrl(copyFile);
            } catch (ServiceException e) {
                throw new ServiceException(e.getMessage());
            }
        }else if(emoji.getType() == 5){
            emoji.setCollectContent(emoji.getMsg());
        }
        Document emojiMsg = emojiMsg(emoji);
        if (null != emojiMsg) {

            // 格式化body 转译&quot;
            JSONObject test = JSONObject.parseObject(emojiMsg.getString("message"));
            if(3==test.getIntValue("encryptType")){
                throw new ServiceException(KConstants.ResultCode.NOTSUPPORT_COLLECT);
            }

            if (emoji.getType() != 5){
                if(null!=test.get("fileName"))
                    emoji.setFileName(test.get("fileName").toString());
                if(null!=test.get("fileSize"))
                    emoji.setFileSize(Double.valueOf(test.get("fileSize").toString()));
            }
            if (emoji.getType() == 4)
                emoji.setFileLength(Integer.valueOf(test.get("fileTime").toString()));
        }
		/*if (!StringUtil.isEmpty(emoji.getRoomJid()))
			emoji.setRoomJid(emoji.getRoomJid());
		if(!StringUtil.isEmpty(emoji.getTitle()))
			emoji.setTitle(emoji.getTitle());
		if(!StringUtil.isEmpty(emoji.getShareURL()))
			emoji.setShareURL(emoji.getShareURL());*/
        emoji.setUserId(userId);
        emoji.setCreateTime(DateUtil.currentTimeSeconds());
//		getDatastore().save(emoji);
        collectionDao.addEmoji(emoji);
        /**
         * 维护用户收藏的缓存
         */
        userRedisService.deleteUserCollectCommon(userId);
        return emoji;
    }

    /** @Description:（语音、文件特殊处理）
     * @param emoji
     * @param type
     * @return
     **/
    private Document emojiMsg(Emoji emoji){
        int isSaveMsg = SKBeanUtils.getSystemConfig().getIsSaveMsg();
        if (0 == isSaveMsg)
            throw new ServiceException(KConstants.ResultCode.NOSAVEMSGAND);
        return messageRepository.emojiMsg(emoji.getUserId(),emoji.getRoomJid(),emoji.getMsgId());
    }

    /** @Description:（添加收藏表情）
     * @param userId
     * @param emoji
     * @return
     **/
    public Emoji newAddEmoji(Integer userId,Emoji emoji){
        try {
            Emoji dbEmoji = collectionDao.queryEmojiByUrlAndType(emoji.getMsg(),emoji.getType(),userId);
            if(null!=dbEmoji){
                throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
            }
            String copyFile = ConstantUtil.copyFile(-1,emoji.getUrl());
            emoji.setUserId(userId);
            emoji.setType(emoji.getType());
            if(!StringUtil.isEmpty(copyFile))
                emoji.setUrl(copyFile);
            else
                emoji.setUrl(emoji.getUrl());

            emoji.setCreateTime(DateUtil.currentTimeSeconds());
            collectionDao.addEmoji(emoji);
            /**
             * 维护用户自定义表情缓存
             */
            userRedisService.deleteUserCollectEmoticon(userId);
        } catch (ServiceException e) {
            throw new ServiceException("文件服务器连接超时");
        }
        return emoji;
    }

    // 收藏详情记录
    public void saveCollect(ObjectId msgId, String nickname, int userId){
        Collect collect = new Collect(msgId,nickname,userId);
        msgDao.addCollect(collect);
    }


    /**
     * 旧版收藏 兼容版本
     */
    // 添加收藏
    @Override
    public List<Object> addCollection(int userId, String roomJid, String msgId, String type) {
        int isSaveMsg = SKBeanUtils.getSystemConfig().getIsSaveMsg();
        if(0 == isSaveMsg)
            throw new ServiceException(KConstants.ResultCode.NOSAVEMSGAND);
//			Query<Emoji> query=null;
        Emoji getEmoji = null;
        Document data=null;
        List<Object> listEmoji=new ArrayList<>();
        List<String> listMsgId=new ArrayList<>();
        List<String> listType=new ArrayList<>();
        if(!StringUtil.isEmpty(msgId)){
            listMsgId= Arrays.asList(msgId.split(","));
            listType=Arrays.asList(type.split(","));
            for(int i=0;i<listMsgId.size();i++){
                getEmoji = collectionDao.getEmoji(listMsgId.get(i),userId);
                if(getEmoji == null){
                    Emoji emoji=new Emoji();
                    emoji.setUserId(userId);
                    emoji.setType(Integer.valueOf(listType.get(i)));
                    if(!StringUtil.isEmpty(roomJid)){
                        emoji.setRoomJid(roomJid);
                    }

                    if(!StringUtil.isEmpty(listMsgId.get(i))){
                        emoji.setMsgId(listMsgId.get(i));
                        data=messageRepository.emojiMsg(userId,roomJid,listMsgId.get(i));
                        if(data==null){
                            continue;
                        }
                        JSONObject jsonObject = JSONObject.parseObject(data.getString("message"));
                        if(3==jsonObject.getIntValue("isEncrypt")){
                            throw new ServiceException(KConstants.ResultCode.NOTSUPPORT_COLLECT);
                        }

                    }
                    if(Integer.valueOf(listType.get(i))!=5){
                        JSONObject obj=JSONObject.parseObject(data.toJson());
                        try {
                            String copyFile = ConstantUtil.copyFile(-1,obj.get("content").toString());
                            data.replace("content", copyFile);
                            emoji.setUrl(copyFile);
                        } catch (Exception e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                    }
                    emoji.setMsg(data.toJson());
                    emoji.setCreateTime(DateUtil.currentTimeSeconds());
                    collectionDao.addEmoji(emoji);
                    listEmoji.add(emoji);
                    /**
                     * 维护用户收藏的缓存
                     */
                    userRedisService.deleteUserCollectCommon(userId);
                    userRedisService.deleteUserCollectEmoticon(userId);
                }else{
                    return null;
                }
            }

        }

        return listEmoji;
    }


    //添加收藏表情
    @Override
    public Object addEmoji(int userId,String url,String type) {

//			Query<Emoji> query=null;
        Emoji getEmoji = null;
        if(!StringUtil.isEmpty(url)){
            getEmoji=collectionDao.getEmoji(userId,url);
        }

        String copyFile = ConstantUtil.copyFile(-1,url);

        if(getEmoji==null){
            Emoji emoji=new Emoji();
            emoji.setUserId(userId);
            emoji.setType(Integer.valueOf(type));
            if(!StringUtil.isEmpty(copyFile)){
                emoji.setUrl(copyFile);
            }else {
                emoji.setUrl(url);
            }

            emoji.setCreateTime(DateUtil.currentTimeSeconds());
            collectionDao.addEmoji(emoji);
            /**
             * 维护用户表情缓存
             */
            userRedisService.deleteUserCollectEmoticon(userId);
            return emoji;
        }else{
            return null;
        }

    }


    //取消收藏
    @Override
    public void deleteEmoji(Integer userId,String emojiId) {
        List<String> list=new ArrayList<>();
        list=Arrays.asList(emojiId.split(","));
        for(String emjId:list){
            if(!ObjectId.isValid(emjId))
                continue;
            Emoji getEmoji = collectionDao.getEmoji(new ObjectId(emjId),userId);
            if(null != getEmoji){

                if(getEmoji.getCollectType() == 1){
                    msgDao.deleteCollect(new ObjectId(getEmoji.getCollectMsgId()));
                }
                // 删除收藏不删除源文件
//					ConstantUtil.deleteFile(dbObj.getUrl());

                if(getEmoji.getType() != 6)
                    userRedisService.deleteUserCollectCommon(ReqUtil.getUserId());
                else
                    userRedisService.deleteUserCollectEmoticon(ReqUtil.getUserId());
                collectionDao.deleteEmoji(new ObjectId(emjId),userId);
            }else{
                throw new ServiceException(KConstants.ResultCode.DataNotExists);
            }

        }
    }


    //收藏列表
    @Override
    public List<Emoji> emojiList(int userId,int type,int pageSize,int pageIndex) {
        // 用户收藏
        List<Emoji> emojiLists = null;
        if(type != 0){
            emojiLists = collectionDao.queryEmojiList(userId,type);
            // 兼容旧版文本
            emojiLists = unescapeHtml3(emojiLists);
        }else {
            List<Emoji> userCollectCommon = userRedisService.getUserCollectCommon(userId);
            if(null != userCollectCommon && userCollectCommon.size() > 0){
                emojiLists = userCollectCommon;
            }else{
                emojiLists = collectionDao.queryEmojiListOrType(userId);
                // 兼容旧版文本
                emojiLists = unescapeHtml3(emojiLists);
                userRedisService.saveUserCollectCommon(userId, emojiLists);
            }
        }
        return emojiLists;
    }

    /** @Description: 旧版收藏的文本数据格式化
     * @param emojiLists
     * @return
     **/
    public List<Emoji> unescapeHtml3(List<Emoji> emojiLists){
        if(null == emojiLists)
            return null;
        for (Emoji emojis : emojiLists) {
            if(5 == emojis.getType() && null == emojis.getCollectContent()){
                Document emojiMsg = emojiMsg(emojis);
                if (null != emojiMsg) {
                    // 格式化body 转译&quot;
                    JSONObject test = JSONObject.parseObject(emojiMsg.getString("message"));
                    if(3==test.getIntValue("isEncrypt")){
                        throw new ServiceException(KConstants.ResultCode.NOTSUPPORT_COLLECT);
                    }
                    if(null != test.get("content")){
                        emojis.setMsg(test.get("content" ).toString());
                        log.info("旧版转译后的 content:"+test.get("content" ).toString());
                        emojis.setCollectContent(test.get("content").toString());
                    }
                }
            }
        }

        return emojiLists;
    }


    //收藏表情列表
    @Override
    public List<Emoji> emojiList(int userId) {
        List<Emoji> emojis = null;
        List<Emoji> userCollectEmoticon = userRedisService.getUserCollectEmoticon(userId);
        if(null != userCollectEmoticon && userCollectEmoticon.size() >0)
            emojis = userCollectEmoticon;
        else{
            List<Emoji> emojiList = collectionDao.queryEmojiList(userId,6);
            emojis = emojiList;
            userRedisService.saveUserCollectEmoticon(userId, emojis);
        }
        return emojis;
    }


    //添加课程
    @Override
    public void addMessageCourse(int userId, List<String> messageIds, long createTime, String courseName,String roomJid) {
        Course course=new Course();
        course.setUserId(userId);
        course.setMessageIds(messageIds);
        course.setCreateTime(createTime);
        course.setCourseName(courseName);
        course.setRoomJid(roomJid);
        courseDao.addCourse(course);
        ThreadUtils.executeInThread(obj -> {
            List<Document> documents = messageRepository.queryMsgDocument(userId, roomJid, messageIds);
            for (Document dbObj : documents) {
                JSONObject jsonObject = JSONObject.parseObject(dbObj.getString("message"));
                if(3==jsonObject.getIntValue("encryptType")){
                    throw new ServiceException(KConstants.ResultCode.NOTSUPPORT_COLLECT);
                }

                courseMessageDao.addCourseMessage(new ObjectId(),course.getUserId(),course.getCourseId().toString(),jsonObject.toJSONString(),String.valueOf(dbObj.get("messageId")),String.valueOf(dbObj.get("timeSend")));
            }

        });

    }

    //获取课程列表
    @Override
    public List<Course> getCourseList(int userId) {
        List<Course> list = courseDao.getCourseListByUserId(userId);
        return list;
    }

    //修改课程
    @Override
    public void updateCourse(Course course, String courseMessageId) {
        Course getCourse = courseDao.getCourseById(course.getCourseId());
        if(!StringUtil.isEmpty(courseMessageId)){
            CourseMessage courseMessage = courseMessageDao.queryCourseMessageById(courseMessageId);
            // 兼容IOS旧版本
            if(null == courseMessage){
                courseMessage = courseMessageDao.queryCourseMessageByIdOld(new ObjectId(courseMessageId));
            }
            courseMessageDao.deleteCourseMessage(courseMessage);
            // 维护讲课messageIds
            List<String> messageIds = getCourse.getMessageIds();
            Iterator<String> iterator = messageIds.iterator();
            while (iterator.hasNext()) {
                String next = iterator.next();
                if(next.equals(courseMessageId))
                    iterator.remove();
            }
            if(0 == messageIds.size()){
                courseDao.deleteCourse(course.getCourseId(),course.getUserId());
                return;
            }
            course.setMessageIds(messageIds);
        }
        courseDao.updateCourse(course.getCourseId(),course.getMessageIds(),course.getUpdateTime(),course.getCourseName());
    }

    //删除课程
    @Override
    public boolean deleteCourse(Integer userId,ObjectId courseId) {
        if(null == courseDao.getCourse(courseId,userId))
            return false;
        List<CourseMessage> asList = courseMessageDao.getCourseMessageList(String.valueOf(courseId),userId);
        for(int i=0;i<asList.size();i++){
            courseMessageDao.deleteCourseMessage(asList.get(i));
        }
        courseDao.deleteCourse(courseId,userId);
        return true;

    }
    //获取详情
    @Override
    public List<CourseMessage> getCourse(String courseId) {
        List<CourseMessage> listMessage=new ArrayList<CourseMessage>();
        listMessage = courseMessageDao.getCourseMessageList(courseId,null);
        return listMessage;
    }

}

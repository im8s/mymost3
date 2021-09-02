package com.shiku.im.msg.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.msg.dao.MsgCommentDao;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgPraiseDao;
import com.shiku.im.msg.entity.Comment;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.entity.Praise;
import com.shiku.im.msg.model.AddMsgParam;
import com.shiku.im.msg.model.MessageExample;
import com.shiku.im.msg.service.MsgManager;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;

import static java.util.stream.Collectors.toList;

/**
 *
 * @version V1.0
 * @Description: TODO(朋友圈相关业务)
 * @date 2019/9/6 17:30
 */
@Slf4j
@Service
public class MsgManagerImpl implements MsgManager {
    @Autowired
    @Lazy
    private MsgDao msgDao;
    public MsgDao getMsgDao(){
        return msgDao;
    }
    @Autowired
    @Lazy
    private MsgCommentDao msgCommentDao;
    @Autowired
    @Lazy
    private MsgPraiseDao msgPraiseDao;

   /* @Autowired
    private GiveGiftDao giveGiftDao;*/



    @Autowired
    private MusicManagerImpl musicManager;

    @Autowired
    private MessageService messageService;

    @Autowired
    private MsgRedisRepository msgRedisRepository;



    @Autowired
    private UserCoreService userCoreService;


    @Autowired
    private FriendsManagerImpl friendsManager;

    public Msg add(int userId, AddMsgParam param) {
        //去redis根据userId是否有数据
        User user =userCoreService.getUser(userId);
        //设置一些列参数
        Msg entity = Msg.build(user, param);
        // 保存生活圈消息
        msgDao.add(entity);
        // 如果musicId不为空维护音乐使用次数
        if(!StringUtil.isEmpty(param.getMusicId())){
            musicManager.updateUseCount(new ObjectId(param.getMusicId()));
        }
        List<Integer> friendUserIdList = friendsManager.queryFriendUserIdList(userId);
        if(null != param.getUserRemindLook()){
            if(null != param.getUserNotLook()){
                List<Integer> collect = param.getUserRemindLook().stream().filter(item -> param.getUserNotLook().contains(item)).collect(toList());
                log.info("朋友圈提醒朋友列表:{}, 不给看列表:{}, 交集列表：{}",param.getUserRemindLook(),param.getUserNotLook(), JSONObject.toJSONString(collect));
                param.getUserRemindLook().removeAll(collect);

                /**
                 * 移除不给看的好友
                 */
                friendUserIdList.removeAll(param.getUserNotLook());
                if(null == param.getUserRemindLook()){
                    return entity;
                }
            }
            ThreadUtils.executeInThread((Callback) obj -> {
                for(int i=0;i<param.getUserRemindLook().size();i++){
                    push(userId,param.getUserRemindLook().get(i),entity.getMsgId());
                }
            });
        }
        /**
         * 新消息 通知给自己的好友
         */
        if (2 != param.getVisible() && null != friendUserIdList && 0 < friendUserIdList.size()) {
            newMsgPush(user, friendUserIdList, entity.getMsgId().toString());
        }
        return entity;
    }

    private void newMsgPush(User user,List<Integer> userIdList,String msgId){

        MessageBean messageBean=new MessageBean();
        messageBean.setType(MessageType.MSG_NEW);
        messageBean.setFromUserId(String.valueOf(user.getUserId()));
        messageBean.setFromUserName(user.getNickname());
        messageBean.setObjectId(msgId);
        // 单聊消息
        messageBean.setMsgType(0);
        messageBean.setMessageId(StringUtil.randomUUID());

        messageService.send(messageBean,userIdList);
    }
    private void push(int userId,int toUserId,ObjectId msgId){
        // xmpp推送
        User user =userCoreService.getUser(userId);
        Msg msg = msgDao.get(msgId);
        int type=msg.getBody().getType();
        String url=null;
        if(type==1){
            url=msg.getBody().getText();
        }else if(type==2){
            url=msg.getBody().getImages().get(0).getTUrl();
        }else if(type==3){
            url=msg.getBody().getAudios().get(0).getOUrl();
        }else if(type==4){
            url=msg.getBody().getImages().get(0).getOUrl();
        }
        String t=String.valueOf(type);
        String u=String.valueOf(msgId);
        String mm=u+","+t+","+url;
        MessageBean messageBean=new MessageBean();
        messageBean.setType(MessageType.REMIND);
        messageBean.setFromUserId(String.valueOf(userId));
        messageBean.setFromUserName(user.getNickname());
        messageBean.setContent("");
        messageBean.setObjectId(mm);
        messageBean.setToUserId(String.valueOf(toUserId));
        messageBean.setMsgType(0);// 单聊消息
        messageBean.setMessageId(StringUtil.randomUUID());
        try {
		/*	List<Integer> praiseuserIdlist=new ArrayList<Integer>();
			DBObject d=new BasicDBObject("msgId",msgId);
			praiseuserIdlist=distinct("s_praise", "userId", d);

			List<Integer> userIdlist=new ArrayList<Integer>();
			userIdlist=distinct("s_comment","userId", d);

			userIdlist.addAll(praiseuserIdlist);

			userIdlist.add(msg.getUserId());

			HashSet<Integer> hs=new HashSet<Integer>(userIdlist);
			List<Integer> list=new ArrayList<Integer>(hs);

			//移出集合中当前操作人
			for (int i = 0; i < list.size(); i++) {
			       if (list.get(i).equals(userId)) {
			    	   list.remove(i);
			       }
			    } */
            messageService.send(messageBean);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private List<Msg> fetchAndAttach(int userId, List<Msg> msgList) {
        if(null!=msgList&&0<msgList.size()) {
            msgList.forEach(msg -> {
                if(null!=msg.getBody()) {
                    if(msg.getBody().getType() == 5) {
                        if(null!=msg.getBody().getFiles()&&null!=msg.getBody().getFiles().get(0))
                            msg.setFileName(msg.getBody().getFiles().get(0).getoFileName());
                    }
                }
                msg.setComments(getComments(msg.getMsgId().toString()));
                msg.setPraises(getPraises(msg.getMsgId().toString()));
               // msg.setGifts(giveGiftDao.find(msg.getMsgId(), null, 0, 10));
                msg.setIsPraise(msgPraiseDao.exists(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
                msg.setIsCollect(msgDao.existsCollect(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
            });
        }

        return msgList;
    }

    /** @Description: 获取最新二十条评论
     * @param msgId
     * @return
     **/
    private List<Comment> getComments(String msgId){
        List<Comment> msgComment = msgRedisRepository.getMsgComment(msgId);
        if(null != msgComment && msgComment.size() > 0){
            return msgComment;
        }else {
            List<Comment> commonListMsg = msgCommentDao.find(new ObjectId(msgId), null, 0, 20);
            if(null != commonListMsg && commonListMsg.size() > 0)
                msgRedisRepository.saveMsgComment(msgId, commonListMsg);
            return commonListMsg;

        }
    }

    private List<Praise> getPraises(String msgId){
        List<Praise> msgPraise = msgRedisRepository.getMsgPraise(msgId);
        if(null != msgPraise && msgPraise.size() > 0){
            return msgPraise;
        }else {
            List<Praise> praiseListMsg = msgPraiseDao.find(new ObjectId(msgId), null, 0, 20);
            if(null != praiseListMsg && praiseListMsg.size() > 0)
                msgRedisRepository.saveMsgPraise(msgId, praiseListMsg);
            return praiseListMsg;
        }
    }

    @Override
    public Msg get(int userId, ObjectId msgId) {
        Msg msg = msgRedisRepository.getMsg(String.valueOf(msgId));
        if(null == msg){
            msg = msgDao.get(msgId);
            if (null == msg)
                return msg;
            else if (0 == userId)
                return msg;
            msgRedisRepository.saveMsg(msg);
        }
        msg.setComments(msgCommentDao.find(msg.getMsgId(), null, 0, 20));
        msg.setPraises(msgPraiseDao.find(msg.getMsgId(), null, 0, 20));
       // msg.setGifts(giveGiftDao.find(msg.getMsgId(), null, 0, 20));
        msg.setIsPraise(msgPraiseDao.exists(userId, msg.getMsgId()) ? 1 : 0);
        msg.setIsCollect(msgDao.existsCollect(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
        return msg;
    }

    public PageResult<Msg> getMsgList(Integer page, Integer limit, String nickname, Integer userId) {
        PageResult<Msg> result=new PageResult<Msg>();
        try {
            result = msgDao.getMsgListResult(userId,nickname,page,limit);
            for(Msg msg : result.getData()){
                User user = userCoreService.getUser(msg.getUserId());
                if(null == user){
                    // 过滤废弃的测试账号朋友圈数据
                    ThreadUtils.executeInThread((Callback) obj -> msgDao.deleteMsg(msg.getUserId()));

                }else{
                    msg.setUserStatus(user.getStatus());
                }
            }
//            result.setCount(query.count());
//            result.setData(msgList);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    @Override
    public void deleteMsg(String userId) {
        msgDao.delete(userId);
    }

    @Override
    public List<Msg> findByExample(int userId, MessageExample example) {
        return fetchAndAttach(userId,msgDao.findByExample(userId,example));
    }

    @Override
    public List<Msg> getUserMsgList(Integer userId, Integer toUserId, ObjectId msgId,int pageIndex, Integer pageSize) {
        return fetchAndAttach(userId,msgDao.getUserMsgList(userId,toUserId,msgId,pageIndex,pageSize));
    }

    @Override
    public List<Msg> getUserMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize) {
        return msgDao.getUserMsgIdList(userId,toUserId,msgId,pageSize);
    }

    @Override
    public List<Msg> getSquareMsgList(int userId, ObjectId msgId, Integer pageSize) {
        return msgDao.getSquareMsgList(userId,msgId,pageSize);
    }

    @Override
    public List<Msg> getMsgListByIds(int userId, String ids) {
        return fetchAndAttach(userId,msgDao.gets(userId,ids));
    }

    @Override
    public List<Msg> getMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize) {
        return msgDao.getMsgIdList(userId,toUserId,msgId,pageSize);
    }

    @Override
    public List<Msg> getMsgList(Integer userId, ObjectId msgId, Integer pageSize, Integer pageIndex) {
        return fetchAndAttach(userId, msgDao.getMsgList(userId,msgId,pageIndex,pageSize));
    }

    @Override
    public List<Msg> getPureVideo(Integer pageIndex, Integer pageSize, String lable) {
        return msgDao.getPureVideo(pageIndex,pageSize,lable);
    }

    @Override
    public boolean forwarding(Integer userId, AddMsgParam param) {
        return msgDao.forwarding(userId,param);
    }

    @Override
    public void lockingMsg(ObjectId msgId, int state) {
        msgDao.lockingMsg(msgId,state);
    }

    @Override
    public void delete(String[] msgIds) {
        msgDao.delete(msgIds);
    }

    @Override
    public boolean delete(ObjectId messageId) {
        return msgDao.delete(messageId.toString());
    }
}

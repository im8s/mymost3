package com.shiku.im.msg.service.impl;

import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.msg.dao.MsgCommentDao;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgPraiseDao;
import com.shiku.im.msg.entity.Comment;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.model.AddCommentParam;
import com.shiku.im.msg.service.MsgCommentManager;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

/**
 * 
 * @version V1.0
 * @Description: TODO(朋友圈评论相关业务)
 * @date 2019/9/6 17:31
 */
@Service
public class MsgCommentManagerImpl implements MsgCommentManager {
    @Autowired
    private MsgCommentDao msgCommentDao;
    @Autowired
    private MsgDao msgDao;
    @Autowired
    private MsgPraiseDao msgPraiseDao;

    @Autowired
    private MsgRedisRepository msgRedisRepository;

    @Autowired
    private MessageService messageService;

    @Autowired
    private UserCoreService userCoreService;

    @Override
    public ObjectId add(int userId, AddCommentParam param) {
        User user = userCoreService.getUser(userId);
        ObjectId commentId = ObjectId.get();
        Comment entity = new Comment(commentId, new ObjectId(
                param.getMessageId()), user.getUserId(), user.getNickname(),
                param.getBody(), param.getToUserId(), param.getToNickname(),
                param.getToBody(), DateUtil.currentTimeSeconds());
		/*// 缓存评论
		String key = String.format("msg:%1$s:comment",
				param.getMessageId());
		SKBeanUtils.getRedisCRUD().del(key);*/
       msgRedisRepository.deleteMsgComment(param.getMessageId());

        // 保存评论
//        getDatastore().save(entity);
        msgCommentDao.save(entity);
        // 更新消息：评论数+1、活跃度+1
        msgDao.update(new ObjectId(param.getMessageId()),
                Msg.Op.Comment, 1);

        //新线程进行xmpp推送
        ThreadUtils.executeInThread((Callback) obj -> tack(userId,param));

        return entity.getCommentId();
    }

    private void tack(int userId, AddCommentParam param){
        User user = userCoreService.getUser(userId);
        // xmpp推送
//        Query<Msg> q=getDatastore().createQuery(getEntityClass());
//        Msg msg=q.filter("msgId", new ObjectId(param.getMessageId())).get();
        Msg msg = msgDao.get(0,new ObjectId(param.getMessageId()));
        int type=msg.getBody().getType();

        String url=null;
        if(type==1){
            url=msg.getBody().getText();
        }else if(type==2){
            url=msg.getBody().getImages().get(0).getTUrl();
        }else if(type==3){
            url=msg.getBody().getAudios().get(0).getOUrl();
        }else if(type==4){
            url=msg.getBody().getVideos().get(0).getOUrl();
        }
        String u=String.valueOf(type);
        String us=param.getMessageId()+","+u+","+url;
        MessageBean messageBean=new MessageBean();
        messageBean.setType(MessageType.COMMENT);//类型为42
        messageBean.setFromUserId(String.valueOf(userId));//评论者的Id
        messageBean.setFromUserName(user.getNickname());//评论者的昵称
				/*messageBean.setToUserId(String.valueOf(param.getToUserId()));//被回复者的ID
				if(StringUtil.isEmpty(param.getToNickname())){
					messageBean.setToUserName(param.getToNickname());//被回复者的昵称
				}*/
        messageBean.setObjectId(us);//id,type,url
        messageBean.setContent(param.getBody());//评论内容
        messageBean.setMessageId(StringUtil.randomUUID());
        try {
            List<Integer> praiseuserIdlist=new ArrayList<Integer>();
            Query d= msgDao.createQuery("msgId",new ObjectId(param.getMessageId()));
            praiseuserIdlist = msgPraiseDao.getDatastore().findDistinct(d,"userId","s_praise", Integer.class);
            List<Integer> userIdlist=new ArrayList<Integer>();
            userIdlist =  msgCommentDao.getDatastore().findDistinct(d,"userId","s_comment", Integer.class);

            userIdlist.addAll(praiseuserIdlist);

            userIdlist.add(msg.getUserId());
            HashSet<Integer> hs=new HashSet<Integer>(userIdlist);
            List<Integer> list=new ArrayList<Integer>(hs);
            //移出集合中当前操作人
            for (int i = 0; i < list.size(); i++) {
                if (list.get(i).equals(userId)) {
                    list.remove(i);
                }
            }
            for(Integer toUserId : list){
                messageBean.setToUserId(toUserId.toString());//被回复者的ID
                if(!StringUtil.isEmpty(param.getToNickname())){
                    messageBean.setToUserName(param.getToNickname());//被回复者的昵称
                }
               messageService.send(messageBean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean delete(ObjectId msgId, String commentId) {
        String[] commentIds = StringUtil.getStringList(commentId);
        for (String commId : commentIds) {
            if(!ObjectId.isValid(commId))
                continue;
            // 删除评论
//            Query<Comment> query = getDatastore().createQuery(Comment.class).field(MongoOperator.ID).equal(new ObjectId(commId));
            Comment comment = msgCommentDao.getComment(new ObjectId(commId));
            if(null != comment){
//                getDatastore().findAndDelete(query);
                msgCommentDao.deleteComment(new ObjectId(commId));
                // 更新消息：评论数-1、活跃度-1
               msgDao.update(msgId, Msg.Op.Comment, -1);
            }else{
                throw new ServiceException(KConstants.ResultCode.DataNotExists);
            }
        }
        // 清除缓存
       msgRedisRepository.deleteMsgComment(msgId.toString());
        return true;
    }

    @Override
    public List<Comment> find(ObjectId msgId, ObjectId commentId, int pageIndex, int pageSize) {
        return msgCommentDao.find(msgId,commentId,pageIndex,pageSize);
    }

    @Override
    public PageResult<Comment> commonListMsg(ObjectId msgId, Integer page, Integer limit) {
        return msgCommentDao.commonListMsg(msgId,page,limit);
    }
}

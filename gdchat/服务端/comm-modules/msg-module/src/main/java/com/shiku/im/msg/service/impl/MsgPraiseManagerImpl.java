package com.shiku.im.msg.service.impl;

import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.msg.dao.MsgCommentDao;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgPraiseDao;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.entity.Praise;
import com.shiku.im.msg.service.MsgPraiseManager;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
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
 * @Description: TODO(朋友圈点赞相关业务)
 * @date 2019/9/6 17:31
 */
@Service
public class MsgPraiseManagerImpl implements MsgPraiseManager {
    @Autowired
    private MsgPraiseDao msgPraiseDao;
    @Autowired
    private MsgDao msgDao;
    @Autowired
    private MsgCommentDao msgCommentDao;
   

    @Autowired
    private MessageService messageService;


    @Autowired
    private UserCoreService userCoreService;

    @Autowired
    private MsgRedisRepository msgRedisRepository;


    @Override
    public ObjectId add(int userId, ObjectId msgId) {
        User user = userCoreService.getUser(userId);

        if (!msgPraiseDao.exists(userId, msgId)) {
            Praise entity = new Praise(ObjectId.get(), msgId, user.getUserId(), user.getNickname(),
                    DateUtil.currentTimeSeconds());
            // 更新缓存
            msgRedisRepository.deleteMsgPraise(msgId.toString());
            // 持久化赞
//            getDatastore().save(entity);
            msgPraiseDao.save(entity);
            // 更新消息：赞+1、活跃度+1
            msgDao.update(msgId, Msg.Op.Praise, 1);

            ThreadUtils.executeInThread((Callback) obj -> push(userId, msgId, 0));

            return entity.getPraiseId();
        }

         throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
    }
    private void push(int userId,ObjectId msgId,int praiseType){
        // xmpp推送
        User user = userCoreService.getUser(userId);
//        Query<Msg> q=getDatastore().createQuery(Msg.class);
//        Msg msg=q.filter("msgId", msgId).get();
        Msg msg = msgDao.get(0,msgId);
        int type=msg.getBody().getType();
        String url=null;
        if(null!=msg.getBody()) {
            if(type==1){
                url=msg.getBody().getText();
            }else if(type==2){
                url=msg.getBody().getImages().get(0).getTUrl();
            }else if(type==3){
                url=msg.getBody().getAudios().get(0).getOUrl();
            }else if(type==4){
                url=msg.getBody().getVideos().get(0).getOUrl();
            }
        }

        String t=String.valueOf(type);
        String u=String.valueOf(msgId);
        String mm=u+","+t+","+url;
      MessageBean messageBean=new MessageBean();
        messageBean.setType(0 == praiseType ? MessageType.PRAISE : MessageType.CANCELPRAISE);
        messageBean.setFromUserId(String.valueOf(userId));
        messageBean.setFromUserName(user.getNickname());
        messageBean.setContent("");
        messageBean.setObjectId(mm);
        messageBean.setMessageId(StringUtil.randomUUID());
        try {
            List<Integer> praiseuserIdlist=new ArrayList<Integer>();
            Query d= msgDao.createQuery("msgId",msgId);
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
            messageService.send(messageBean,list);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean delete(int userId, ObjectId msgId) {
        // 取消点赞
//        Query<Praise> q = getDatastore().createQuery(Praise.class).field("msgId")
//                .equal(msgId).field("userId").equal(userId);
        Praise praise = msgPraiseDao.getPraise(userId,msgId);
        if(null!=praise){
//            getDatastore().findAndDelete(q);
            msgPraiseDao.deletePraise(userId,msgId);
            msgRedisRepository.deleteMsgPraise(msgId.toString());
            // 更新消息：赞-1、活跃度-1
//            SKBeanUtils.getMsgRepository().update(msgId, Msg.Op.Praise, -1);
            msgDao.update(msgId,Msg.Op.Praise,-1);
            ThreadUtils.executeInThread((Callback) obj -> push(userId, msgId, 1));
            return true;
        }else{
            throw new ServiceException(KConstants.ResultCode.DataNotExists);
        }


    }

    @Override
    public List<Praise> getPraiseList(ObjectId msgId, ObjectId praiseId, int pageIndex, int pageSize) {
        return msgPraiseDao.find(msgId,praiseId,pageIndex,pageSize);
    }

    @Override
    public boolean exists(int userId, ObjectId msgId) {
        return msgPraiseDao.exists(userId,msgId);
    }

    @Override
    public boolean existsCollect(int userId, ObjectId msgId) {
        return msgPraiseDao.existsCollect(userId,msgId);
    }

    @Override
    public List<Praise> find(ObjectId msgId, ObjectId praiseId, int pageIndex, int pageSize) {
        return msgPraiseDao.find(msgId,praiseId,pageIndex,pageSize);
    }



    @Override
    public PageResult<Praise> praiseListMsg(ObjectId msgId, Integer page, Integer limit) {
        return msgPraiseDao.praiseListMsg(msgId,page,limit);
    }
}

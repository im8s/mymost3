package com.shiku.im.msg.service.impl;

import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgForwardAmountDao;
import com.shiku.im.msg.entity.ForwardAmount;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.service.MsgForwardAmountManager;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/20 18:01
 */
@Service
public class MsgForwardAmountManagerImpl implements MsgForwardAmountManager {

    @Autowired
    private MsgForwardAmountDao msgForwardAmountDao;
    @Autowired
    private MsgDao msgDao;

    @Autowired
    private MsgRedisRepository msgRedisRepository;

    @Autowired
    private UserCoreService userCoreService;


    @Override
    public void addForwardAmount(int userId,String msgId) {
        User user  = userCoreService.getUser(userId);
        ForwardAmount forwardAmount = new ForwardAmount(ObjectId.get(), msgId, userId, user.getNickname(), DateUtil.currentTimeMilliSeconds());
        // 维护缓存
        msgRedisRepository.deleteMsgForward(msgId);
        // 持久化转发详情
        msgForwardAmountDao.addForwardAmount(forwardAmount);
        // 更新消息：转发数量+1、活跃度+1
        msgDao.update(new ObjectId(msgId), Msg.Op.Forwarding, 1);
    }


    @Override
    public boolean exists(int userId, String msgId) {
       return msgForwardAmountDao.exists(userId,msgId);
    }

    @Override
    public List<ForwardAmount> find(ObjectId msgId, ObjectId forwardId, int pageIndex, int pageSize) {
       return msgForwardAmountDao.find(msgId,forwardId,pageIndex,pageSize);
    }

}

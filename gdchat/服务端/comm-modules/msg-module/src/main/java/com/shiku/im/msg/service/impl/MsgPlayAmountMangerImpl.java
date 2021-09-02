package com.shiku.im.msg.service.impl;

import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.dao.MsgPlayAmountDao;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.entity.PlayAmount;
import com.shiku.im.msg.service.MsgPlayAmountManger;
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
 * @date 2019/9/20 17:30
 */
@Service
public class MsgPlayAmountMangerImpl implements MsgPlayAmountManger {
    @Autowired
    private MsgPlayAmountDao msgPlayAmountDao;
    @Autowired
    private UserCoreService userCoreService;
    @Autowired
    private MsgDao msgDao;

    @Autowired
    private MsgRedisRepository msgRedisRepository;

    @Override
    public void addPlayAmount(int userId, String msgId) {
        User user = userCoreService.getUser(userId);
        PlayAmount playAmount = new PlayAmount(ObjectId.get(), msgId, userId, user.getNickname(), DateUtil.currentTimeMilliSeconds());
        // 维护缓存
        msgRedisRepository.deleteMsgPlay(msgId);
        msgPlayAmountDao.addPlayAmount(playAmount);
        // 更新消息：观看数+1
        msgDao.update(new ObjectId(msgId), Msg.Op.Play, 1);
    }

    @Override
    public boolean exists(int userId, String msgId) {
        return msgPlayAmountDao.exists(userId,msgId);
    }

    @Override
    public List<PlayAmount> find(ObjectId msgId, ObjectId playAmountId, int pageIndex, int pageSize) {
        return msgPlayAmountDao.find(msgId,playAmountId,pageIndex,pageSize);
    }
}

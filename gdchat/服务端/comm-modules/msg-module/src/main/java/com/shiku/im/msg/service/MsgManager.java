package com.shiku.im.msg.service;

import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.model.AddMsgParam;
import com.shiku.im.msg.model.MessageExample;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgManager {
    Msg get(int userId, ObjectId msgId);

    void deleteMsg(String userId);

    List<Msg> getMsgList(Integer userId, ObjectId msgId, Integer pageSize,Integer pageIndex);

    List<Msg> findByExample(int userId, MessageExample example);

    List<Msg> getUserMsgList(Integer userId, Integer toUserId, ObjectId msgId,int pageIndex, Integer pageSize);

    List<Msg> getUserMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize);

    List<Msg> getSquareMsgList(int userId, ObjectId msgId, Integer pageSize);

    List<Msg> getMsgListByIds(int userId, String ids);

    List<Msg> getMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize);

    List<Msg> getPureVideo(Integer pageIndex,Integer pageSize,String lable);

    boolean forwarding(Integer userId, AddMsgParam param);

    void lockingMsg(ObjectId msgId,int state);

    void delete(String[] msgIds);

    boolean delete(ObjectId messageId);
}

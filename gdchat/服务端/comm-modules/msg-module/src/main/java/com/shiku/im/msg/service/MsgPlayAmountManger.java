package com.shiku.im.msg.service;

import com.shiku.im.msg.entity.PlayAmount;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgPlayAmountManger {

    void addPlayAmount(int userId, String msgId);

    boolean exists(int userId, String msgId);

    List<PlayAmount> find(ObjectId msgId, ObjectId playAmountId, int pageIndex, int pageSize);
}

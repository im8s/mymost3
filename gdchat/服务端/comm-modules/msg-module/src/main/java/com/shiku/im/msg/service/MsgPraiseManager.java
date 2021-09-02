package com.shiku.im.msg.service;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.entity.Praise;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgPraiseManager {

    ObjectId add(int userId, ObjectId msgId);

    boolean delete(int userId, ObjectId msgId);

    List<Praise> getPraiseList(ObjectId msgId, ObjectId praiseId, int pageIndex, int pageSize);

    boolean exists(int userId, ObjectId msgId);

    boolean existsCollect(int userId, ObjectId msgId);

    List<Praise> find(ObjectId msgId, ObjectId praiseId, int pageIndex, int pageSize);


    PageResult<Praise> praiseListMsg(ObjectId msgId, Integer page, Integer limit);
}

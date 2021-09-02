package com.shiku.im.redpack.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.redpack.entity.RedReceive;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RedReceiveDao extends IMongoDAO<RedReceive, ObjectId> {

    void addRedReceive(RedReceive redReceive);

    Object addRedReceiveResult(RedReceive redReceive);

    void updateRedReceive(ObjectId redPacketId, int userId, Map<String, Object> map);

    List<RedReceive> getRedReceiveList(ObjectId redPacketId);

    List<RedReceive> getRedReceiveList(int userId, int pageIndex, int pageSize);

    PageResult<RedReceive> getRedReceivePageResult(ObjectId redId, int pageIndex, int pageSize);
}

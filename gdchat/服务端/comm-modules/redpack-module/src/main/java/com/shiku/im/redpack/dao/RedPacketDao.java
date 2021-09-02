package com.shiku.im.redpack.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.redpack.entity.RedPacket;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RedPacketDao extends IMongoDAO<RedPacket, ObjectId> {

    void addRedPacket(RedPacket redPacket);

    RedPacket getRedPacketById(ObjectId id);

    void updateRedPacket(ObjectId id, Map<String, Object> map);

    List<RedPacket> getRedPacketList(int userId, int pageIndex, int pageSize);

    PageResult<RedPacket> getRedPackListPageResult(String userName, String redPacketId, int pageIndex, int pageSize);

    List<RedPacket> getRedPackListTimeOut(long outTime, int status);

    void updateRedPackListTimeOut(long outTime, int status, Map<String, Object> map);

    public RedPacket getRedPacketByPoy(String yopRedPacketId);


    String queryRedpackOverGroupCount(long startTime, long endTime);
}

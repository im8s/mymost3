package com.shiku.im.live.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface LiveRoomDao extends IMongoDAO<LiveRoom, ObjectId> {

    void addLiveRoom(LiveRoom entity);

    Object addLiveRoomReturn(LiveRoom liveRoom);

    LiveRoom getLiveRoom(ObjectId roomId);

    LiveRoom getLiveRoomByUserId(int userId);

    LiveRoom getLiveRoomByJid(String jid);

    void updateLiveRoom(ObjectId roomId, int userId, Map<String, Object> map);

    void updateLiveRoomNum(ObjectId roomId, int number);

    void deleteLiveRoom(ObjectId roomId);

    PageResult<LiveRoom> findLiveRoomList(String name, String nickName, int userId, int status, int pageIndex, int pageSize, int type);

    void clearLiveRoom();

    PageResult<LiveRoom> getLiveRoomList(long time);

    void updateLiveRoom(int userId, Map<String, Object> map);

}

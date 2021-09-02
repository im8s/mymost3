package com.shiku.im.live.dao;

import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface LiveRoomMemberDao extends IMongoDAO<LiveRoom.LiveRoomMember, ObjectId> {

    void addLiveRoomMember(LiveRoom.LiveRoomMember entity);

    void deleteLiveRoomMember(ObjectId roomId);

    void deleteLiveRoomMember(ObjectId roomId, int userId);

    LiveRoom.LiveRoomMember getLiveRoomMember(ObjectId roomId, int userId);


    void updateLiveRoomMember(ObjectId roomId, int userId, Map<String, Object> map);

    List<LiveRoom.LiveRoomMember> getLiveRoomMemberList(ObjectId roomId, int online, int pageIndex, int pageSize);

    List<Integer> findMembersUserIds(ObjectId roomId, int online);

    void updateMember(int userId, Map<String, Object> map);

    public List<LiveRoom.LiveRoomMember> queryLiveRoomMemberList(int userId);

}

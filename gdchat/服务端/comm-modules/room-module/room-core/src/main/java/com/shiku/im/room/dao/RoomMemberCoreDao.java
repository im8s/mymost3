package com.shiku.im.room.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;

public interface RoomMemberCoreDao extends IMongoDAO<Room.Member, ObjectId> {

    List<Integer> getRoomPushUserIdList(ObjectId roomId);


    List<String> queryUserNoPushJidList(int userId);

    List<ObjectId> getRoomIdListByUserId(Integer userId);


    List<ObjectId> getRoomIdListByType(Integer userId, int type);

    Object getMemberIsNoPushMsg(ObjectId roomId, Integer userId, int i);

    List<String> queryUserRoomsJidListByDB(int userId);

    void deleteRoomJidsUserId(Integer userId);

    void updateRoomJidsUserId(Integer userId, List<String> jids);

    void saveJidsByUserId(Integer userId, String jid, ObjectId roomId);

    void delJidsByUserId(Integer userId, String jid);
}

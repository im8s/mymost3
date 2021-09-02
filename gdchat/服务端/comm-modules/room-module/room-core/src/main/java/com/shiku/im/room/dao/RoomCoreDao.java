package com.shiku.im.room.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;

public interface RoomCoreDao extends IMongoDAO<Room,ObjectId> {


    Room getRoomById(ObjectId roomId);


    Room getRoomByJid(String roomJid);


    ObjectId getRoomId(String jid);

    String queryRoomJid(ObjectId roomId);

    String getRoomNameByJid(String jid);

    String getRoomNameByRoomId(ObjectId roomId);


    List<String> queryUserRoomsJidList(List<ObjectId> list);




}

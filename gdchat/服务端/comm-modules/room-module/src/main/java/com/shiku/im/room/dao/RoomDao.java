package com.shiku.im.room.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RoomDao extends IMongoDAO<Room, ObjectId> {

    void addRoom(Room room);


    Room getRoom(String roomname, ObjectId roomId);

    long getAllRoomNums();

    void updateRoomUserSize(ObjectId roomId, int userSize);

    void updateRoom(ObjectId roomId, Map<String,Object> map);

    void updateRoomByUserId(int userId,Map<String,Object> map);

    void deleteRoom(ObjectId roomId);

    Integer getCreateUserId(ObjectId roomId);



    Integer queryRoomStatus(ObjectId roomId);



    Integer getRoomStatus(ObjectId roomId);


    List<Room> getRoomList(List<ObjectId> list,int s,int pageIndex,int pageSize);

    List<Room> getRoomListOrName(int pageIndex, int pageSize, String roomName);

    List<Object> getAddRoomsCount(long startTime,long endTime,String mapStr,String reduce);
//---------------------------------------以下是没有实体且数据操作不多的--------------------------------------------------
    List<String> queryRoomHistoryFileType(String roomJid);

    void dropRoomChatHistory(String roomJid);



}

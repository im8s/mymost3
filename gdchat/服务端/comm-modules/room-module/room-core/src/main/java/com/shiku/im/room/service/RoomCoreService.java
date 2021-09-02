package com.shiku.im.room.service;

import com.shiku.im.room.dao.RoomCoreDao;
import com.shiku.im.room.dao.RoomMemberCoreDao;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RoomCoreService {


    @Autowired
    private RoomCoreDao roomCoreDao;

    @Autowired
    private RoomMemberCoreDao  roomMemberCoreDao;

    public ObjectId getRoomId(String roomJid) {
        return roomCoreDao.getRoomId(roomJid);
    }

    public boolean getMemberIsNoPushMsg(ObjectId roomId, Integer userId) {
        Object field = roomMemberCoreDao.getMemberIsNoPushMsg(roomId,userId,1);
        return null!=field;
    }

    public String getRoomName(String jid) {
        return roomCoreDao.getRoomNameByJid(jid);
    }

    public Room getRoomById(ObjectId roomId) {
       return roomCoreDao.getRoomById(roomId);
    }
}

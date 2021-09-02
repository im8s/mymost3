package com.shiku.im.room.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;

public interface ShareDao extends IMongoDAO<Room.Share, ObjectId> {

    void addShare(Room.Share share);

    Room.Share getShare(ObjectId roomId, ObjectId shareId);

    List<Room.Share> getShareList(ObjectId roomId,int userId,int pageIndex,int pageSize);

    void deleteShare(ObjectId roomId, ObjectId shareId);

    List<String> getShareUrlList(ObjectId roomId);

}

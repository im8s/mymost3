package com.shiku.im.room.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RoomNoticeDao extends IMongoDAO<Room.Notice, ObjectId> {

    void addNotice(Room.Notice entity);

    void deleteNotice(ObjectId roomId,ObjectId noticeId);

    Room.Notice getNotic(ObjectId noticeId,ObjectId roomId);

    List<Room.Notice> getNoticList(ObjectId roomId,int pageIndex,int pageSize);

    void updateNotic(ObjectId roomId, ObjectId noticeId, Map<String,Object> map);
}

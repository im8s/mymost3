package com.shiku.im.room.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.room.dao.RoomNoticeDao;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class RoomNoticeDaoImpl extends MongoRepository<Room.Notice, ObjectId> implements RoomNoticeDao {

    @Autowired(required = false)
    @Qualifier(value = "mongoTemplateForRoom")
    protected MongoTemplate dsForRoom;
    @Override
    public MongoTemplate getDatastore() {
        return dsForRoom;
    }
    @Override
    public Class<Room.Notice> getEntityClass() {
        return Room.Notice.class;
    }

    @Override
    public void addNotice(Room.Notice entity) {
        getDatastore().save(entity);
    }

    @Override
    public void deleteNotice(ObjectId roomId,ObjectId noticeId) {
        Query query = createQuery();
        if(null != roomId)
            addToQuery(query,"roomId",roomId);
        if(null != noticeId)
            addToQuery(query,"_id",noticeId);
        deleteByQuery(query);
    }

    @Override
    public Room.Notice getNotic(ObjectId noticeId, ObjectId roomId) {
        Query query = createQuery(noticeId);
                addToQuery(query,"roomId",roomId);
        return findOne(query);
    }

    @Override
    public List<Room.Notice> getNoticList(ObjectId roomId,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        if(0 != pageSize)
           query.with(createPageRequest(pageIndex,pageSize));
        descByquery(query,"time");
        return queryListsByQuery(query);
    }

    @Override
    public void updateNotic(ObjectId roomId, ObjectId noticeId, Map<String,Object> map) {
        Query query = createQuery("roomId",roomId);
        addToQuery(query,"_id",noticeId);
        Update ops =createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }
}

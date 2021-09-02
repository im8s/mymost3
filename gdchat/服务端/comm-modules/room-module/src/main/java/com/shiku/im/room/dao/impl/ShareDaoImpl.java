package com.shiku.im.room.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.room.dao.ShareDao;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ShareDaoImpl extends MongoRepository<Room.Share, ObjectId> implements ShareDao {

    @Autowired(required = false)
    @Qualifier(value = "mongoTemplateForRoom")
    protected MongoTemplate dsForRoom;
    @Override
    public MongoTemplate getDatastore() {
        return dsForRoom;
    }
    @Override
    public Class<Room.Share> getEntityClass() {
        return Room.Share.class;
    }

    @Override
    public void addShare(Room.Share share) {
        getDatastore().save(share);
    }

    @Override
    public Room.Share getShare(ObjectId roomId, ObjectId shareId) {
        Query query =createQuery("roomId",roomId);
        addToQuery(query,"shareId",shareId);
        return findOne(query);
    }

    @Override
    public List<Room.Share> getShareList(ObjectId roomId, int userId, int pageIndex, int pageSize) {
        Query query = createQuery("roomId",roomId);
        if(0 != userId)
            addToQuery(query,"userId",userId);
        if(0 != pageSize)
            query.with(createPageRequest(pageIndex,pageSize));
        return queryListsByQuery(query);
    }

    @Override
    public void deleteShare(ObjectId roomId, ObjectId shareId) {
        Query query = createQuery();
        if(null != shareId)
            addToQuery(query,"shareId",shareId);
        if(null != roomId)
          addToQuery(query,"roomId",roomId);
       deleteByQuery(query);
    }

    @Override
    public List<String> getShareUrlList(ObjectId roomId) {
        Query query = createQuery("roomId",roomId);
        return getDatastore().findDistinct(query,"url",getEntityClass(),String.class);
    }
}

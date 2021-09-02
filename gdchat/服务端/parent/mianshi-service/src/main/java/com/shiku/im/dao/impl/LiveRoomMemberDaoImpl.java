package com.shiku.im.dao.impl;

import com.google.common.collect.Lists;
import com.shiku.im.live.dao.LiveRoomMemberDao;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.repository.MongoRepository;
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
public class LiveRoomMemberDaoImpl extends MongoRepository<LiveRoom.LiveRoomMember, ObjectId> implements LiveRoomMemberDao {


    @Autowired
    @Qualifier(value = "mongoLiveMember")
    private MongoTemplate mongoLiveMember;

    @Override
    public MongoTemplate getDatastore() {
        return mongoLiveMember;
    }

    @Override
    public Class<LiveRoom.LiveRoomMember> getEntityClass() {
        return LiveRoom.LiveRoomMember.class;
    }

    @Override
    public void addLiveRoomMember(LiveRoom.LiveRoomMember entity) {
        getDatastore().save(entity,getCollectionName(entity.getRoomId()));
    }

    @Override
    public void deleteLiveRoomMember(ObjectId roomId) {
        Query query = createQuery("roomId",roomId);
        deleteByQuery(query,getCollectionName(roomId));
    }

    @Override
    public void deleteLiveRoomMember(ObjectId roomId, int userId) {
        Query query = createQuery("roomId",roomId);
        if(0 != userId)
            addToQuery(query,"userId",userId);
        deleteByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<LiveRoom.LiveRoomMember> queryLiveRoomMemberList(int userId) {
        List<LiveRoom.LiveRoomMember> resultList= Lists.newArrayList();
        Query query = createQuery("userId",userId);
        getDatastore().getCollectionNames().forEach(name->{
            resultList.addAll(queryListsByQuery(query,name));
        });
        return resultList;
    }

    @Override
    public LiveRoom.LiveRoomMember getLiveRoomMember(ObjectId roomId, int userId) {
        Query query = createQuery("roomId",roomId);
        if(0 != userId)
            addToQuery(query,"userId",userId);
        return findOne(query,getCollectionName(roomId));
    }

    @Override
    public void updateLiveRoomMember(ObjectId roomId, int userId, Map<String, Object> map) {
        Query query = createQuery("roomId",roomId);
        if(0 != userId)
            addToQuery(query,"userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops,getCollectionName(roomId));
    }

    @Override
    public List<LiveRoom.LiveRoomMember> getLiveRoomMemberList(ObjectId roomId, int online, int pageIndex, int pageSize) {
        Query query = createQuery("roomId",roomId);
        addToQuery(query,"online",online);
        if(0 != pageSize)
            query.with(createPageRequest(pageIndex,pageSize));
        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<Integer> findMembersUserIds(ObjectId roomId, int online) {
        Query query = createQuery();
        if(null!=roomId)
			addToQuery(query,"roomId",roomId);
        addToQuery(query,"online", 1);
       return getDatastore().findDistinct(query,"userId",getCollectionName(roomId),getEntityClass(),Integer.class);
    }

    @Override
    public void updateMember(int userId, Map<String, Object> map) {
        Query query =createQuery("userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });

        getDatastore().getCollectionNames().forEach(name->{
            update(query,ops,name);
        });

    }
}

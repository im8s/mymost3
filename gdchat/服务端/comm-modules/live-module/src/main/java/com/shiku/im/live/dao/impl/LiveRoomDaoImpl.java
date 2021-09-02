package com.shiku.im.live.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.live.dao.LiveRoomDao;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public class LiveRoomDaoImpl extends MongoRepository<LiveRoom, ObjectId> implements LiveRoomDao {


    @Override
    public Class<LiveRoom> getEntityClass() {
        return LiveRoom.class;
    }

    @Override
    public void addLiveRoom(LiveRoom entity) {
        getDatastore().save(entity);
    }

    @Override
    public Object addLiveRoomReturn(LiveRoom liveRoom) {

        return save(liveRoom).getRoomId();
    }

    @Override
    public LiveRoom getLiveRoom(ObjectId roomId) {
        if(null==roomId){
            return null;
        }
        return get(roomId);
    }

    @Override
    public LiveRoom getLiveRoomByUserId(int userId) {
        Query query = createQuery("userId",userId);
        return findOne(query);
    }

    @Override
    public LiveRoom getLiveRoomByJid(String jid) {
        Query query = createQuery("jid",jid);
        return findOne(query);
    }

    @Override
    public void updateLiveRoom(ObjectId roomId, int userId, Map<String, Object> map) {
        Query query = createQuery(roomId);
        if(0 != userId)
            addToQuery(query,"userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void updateLiveRoomNum(ObjectId roomId, int number) {
        Query query = createQuery(roomId);
        Update ops = createUpdate();
        ops.inc("numbers", number);
        update(query,ops);
    }

    @Override
    public void deleteLiveRoom(ObjectId roomId) {
       deleteById(roomId);
    }

    @Override
    public PageResult<LiveRoom> findLiveRoomList(String name, String nickName, int userId, int status, int pageIndex, int pageSize, int type) {
        Query query = createQuery();
        if(!StringUtil.isEmpty(name)){
            addToQuery(query,"name",name);
        }
        if(!StringUtil.isEmpty(nickName)){
            addToQuery(query,"nickName",nickName);
        }
        if(0!=userId){
            addToQuery(query,"userId",userId);
        }
        if(1==status){
            addToQuery(query,"status",status);
        }
        descByquery(query,"createTime");
        PageResult<LiveRoom> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,type));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public void clearLiveRoom() {
        Query query=createQuery();
        deleteByQuery(query);
    }

    @Override
    public PageResult<LiveRoom> getLiveRoomList(long time) {
        PageResult<LiveRoom> pageResult = new PageResult<>();
        Query query =createQuery();
        query.addCriteria(Criteria.where("createTime").lt(time));

        pageResult.setData(queryListsByQuery(query));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public void updateLiveRoom(int userId, Map<String, Object> map) {
        Query query = createQuery("userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }
}

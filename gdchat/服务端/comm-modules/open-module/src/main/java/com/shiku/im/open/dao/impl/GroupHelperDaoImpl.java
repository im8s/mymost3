package com.shiku.im.open.dao.impl;

import com.mongodb.client.result.DeleteResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.open.dao.GroupHelperDao;
import com.shiku.im.open.entity.GroupHelper;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class GroupHelperDaoImpl extends MongoRepository<GroupHelper, ObjectId> implements GroupHelperDao {



    @Override
    public Class<GroupHelper> getEntityClass() {
        return GroupHelper.class;
    }

    @Override
    public void addGroupHelper(GroupHelper groupHelper) {
        getDatastore().save(groupHelper);
    }

    @Override
    public GroupHelper getGroupHelper(ObjectId id) {
        return get(id);
    }

    @Override
    public GroupHelper queryGroupHelper(ObjectId id, Integer userId) {
       Query query =createQuery(id);
       addToQuery(query,"userId",userId);
        return findOne(query);
    }

    @Override
    public GroupHelper queryGroupHelper(String roomId, String helperId) {
       Query query = createQuery("roomId",roomId);
        addToQuery(query,"helperId",helperId);
        return findOne(query);
    }

    @Override
    public GroupHelper queryGroupHelper(String roomId) {
        Query query = createQuery("roomId",roomId);
        return findOne(query);
    }

    @Override
    public void deleteGroupHelper(Integer userId, ObjectId id) {
        Query query =createQuery(id);
        addToQuery(query,"userId",userId);
        DeleteResult deleteResult = deleteByQuery(query);
        if(deleteResult.getDeletedCount()<=0){
            throw new ServiceException(KConstants.ResultCode.DeleteFailure);
        }
    }

    @Override
    public List<GroupHelper> getGroupHelperList(String roomId) {
        Query query = createQuery("roomId",roomId);
        return queryListsByQuery(query);
    }

    @Override
    public void updateGroupHelper(ObjectId id, Integer userId, Map<String, Object> map) {
       Query query = createQuery(id);
        if(null != userId)
            addToQuery(query,"userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
       update(query,ops);
    }

    @Override
    public void updateGroupHelper(String roomId, String helperId, Map<String, Object> map) {
        Query query = createQuery("roomId",roomId);
        addToQuery(query,"helperId",helperId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void deleteGroupHelper(String helperId) {
       Query query = createQuery("helperId",helperId);
       deleteByQuery(query);
    }
}

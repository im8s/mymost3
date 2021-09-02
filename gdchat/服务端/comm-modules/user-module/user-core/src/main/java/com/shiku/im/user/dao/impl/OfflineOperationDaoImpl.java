package com.shiku.im.user.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.OfflineOperationDao;
import com.shiku.im.user.entity.OfflineOperation;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class OfflineOperationDaoImpl extends MongoRepository<OfflineOperation,ObjectId> implements OfflineOperationDao {
  

    @Override
    public Class<OfflineOperation> getEntityClass() {
        return OfflineOperation.class;
    }

    @Override
    public OfflineOperation queryOfflineOperation(Integer userId,String tag,String friendId) {
        Query query =createQuery("userId",userId);
               addToQuery(query,"friendId",friendId);

        if(!StringUtil.isEmpty(tag)){
           addToQuery(query,"tag",tag);
        }
        return findOne(query);
    }

    @Override
    public void addOfflineOperation(Integer userId, String tag, String friendId, long updateTime) {
        OfflineOperation offlineOperation = new OfflineOperation();
        if(null != userId){
            offlineOperation.setUserId(userId);
        }
        if(null != tag){
            offlineOperation.setTag(tag);
        }
        if(null != friendId){
            offlineOperation.setFriendId(friendId);
        }
        if(0!=updateTime){
            offlineOperation.setOperationTime(updateTime);
        }
        getDatastore().save(offlineOperation);
    }

    @Override
    public void updateOfflineOperation(int userId, String friendId, Map<String, Object> map) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"friendId",friendId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void updateOfflineOperation(ObjectId id,OfflineOperation offlineOperation) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        if(null != offlineOperation.getFriendId())
            ops.set("friendId",offlineOperation.getFriendId());
        if(null != offlineOperation.getUserId())
            ops.set("userId",offlineOperation.getUserId());
        if(!StringUtil.isEmpty(offlineOperation.getTag()))
            ops.set("tag",offlineOperation.getTag());
        if(0 != offlineOperation.getOperationTime())
            ops.set("operationTime",offlineOperation.getOperationTime());

        update(query,ops);

    }

    @Override
    public void updateOfflineOperation(int userId, String friendId, OfflineOperation offlineOperation) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"friendId",friendId);
        Update ops = createUpdate();
        if(null != offlineOperation.getFriendId())
            ops.set("friendId",offlineOperation.getFriendId());
        if(null != offlineOperation.getUserId())
            ops.set("userId",offlineOperation.getUserId());
        if(!StringUtil.isEmpty(offlineOperation.getTag()))
            ops.set("tag",offlineOperation.getTag());
        if(0 != offlineOperation.getOperationTime())
            ops.set("operationTime",offlineOperation.getOperationTime());
        update(query,ops);
    }

    @Override
    public List<OfflineOperation> getOfflineOperationList(Integer userId, long startTime) {
        Query query =createQuery("userId",userId);
        query.addCriteria(Criteria.where("operationTime").gt(startTime));
        return queryListsByQuery(query);
    }
}

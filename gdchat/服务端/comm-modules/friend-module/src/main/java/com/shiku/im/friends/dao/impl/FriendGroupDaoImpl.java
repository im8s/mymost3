package com.shiku.im.friends.dao.impl;

import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.friends.dao.FriendGroupDao;
import com.shiku.im.friends.entity.FriendGroup;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.entity.OfflineOperation;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/8/27 9:41
 */
@Repository
public class FriendGroupDaoImpl extends MongoRepository<FriendGroup, ObjectId> implements FriendGroupDao {


    @Override
    public Class<FriendGroup> getEntityClass() {
        return FriendGroup.class;
    }

    @Override
    public void addFriendGroup(FriendGroup friendGroup) {
        getDatastore().save(friendGroup);
    }

    @Override
    public void updateFriendGroup(ObjectId groupId, FriendGroup friendGroup) {
        update(groupId,friendGroup);
    }

    @Override
    public FriendGroup getFriendGroup(int userId, String groupName) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"groupName",groupName);
        return findOne(query);
    }

    @Override
    public void updateFriendGroup(int userId, ObjectId groupId, Map<String, Object> map) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"groupId",groupId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        UpdateResult update = update(query, ops);
        if(update.getModifiedCount()<0){
            throw new ServiceException(0);
        }
    }

    @Override
    public List<FriendGroup> getFriendGroupList(int userId) {
        Query query =createQuery("userId",userId);
        return queryListsByQuery(query);
    }

    @Override
    public void deleteGroup(int userId, ObjectId groupId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"groupId",groupId);
        DeleteResult deleteResult = deleteByQuery(query);
        if(deleteResult.getDeletedCount()<0){
            throw new ServiceException(0);
        }
    }

    @Override
    public void multipointLoginUpdateFriendsGroup(Integer userId, String nickName) {


        Query query =createQuery("userId",userId);
       addToQuery(query,"friendId",String.valueOf(userId));
       addToQuery(query,"tag",KConstants.MultipointLogin.TAG_LABLE);
        if(null == findOne(query))
            getDatastore().save(new OfflineOperation(userId, KConstants.MultipointLogin.TAG_LABLE, String.valueOf(userId), DateUtil.currentTimeSeconds()));
        else{
            Update ops = createUpdate();
            ops.set("operationTime", DateUtil.currentTimeSeconds());
            getDatastore().updateFirst(query, ops,OfflineOperation.class);
        }
    }
}

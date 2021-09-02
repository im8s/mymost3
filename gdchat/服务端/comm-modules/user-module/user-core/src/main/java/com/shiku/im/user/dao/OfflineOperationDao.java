package com.shiku.im.user.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.OfflineOperation;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface OfflineOperationDao extends IMongoDAO<OfflineOperation,ObjectId> {

    OfflineOperation queryOfflineOperation(Integer userId,String tag,String friendId);

    void addOfflineOperation(Integer userId, String tag, String friendId, long updateTime);

    void updateOfflineOperation(int userId, String friendId, Map<String,Object> map);

    void updateOfflineOperation(ObjectId id, OfflineOperation offlineOperation);

    void updateOfflineOperation(int userId,String friendId,OfflineOperation offlineOperation);

    List<OfflineOperation> getOfflineOperationList(Integer userId,long startTime);
}

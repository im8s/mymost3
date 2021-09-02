package com.shiku.im.open.dao;

import com.shiku.im.open.entity.GroupHelper;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface GroupHelperDao extends IMongoDAO<GroupHelper, ObjectId> {

    void addGroupHelper(GroupHelper groupHelper);

    GroupHelper getGroupHelper(ObjectId id);

    GroupHelper queryGroupHelper(ObjectId id,Integer userId);

    GroupHelper queryGroupHelper(String roomId,String helperId);

    GroupHelper queryGroupHelper(String roomId);

    List<GroupHelper> getGroupHelperList(String roomId);

    void deleteGroupHelper(Integer userId,ObjectId id);

    void updateGroupHelper(ObjectId id, Integer userId, Map<String,Object> map);

    void updateGroupHelper(String roomId,String helperId,Map<String,Object> map);

    void deleteGroupHelper(String helperId);
}

package com.shiku.im.friends.dao;

import com.shiku.im.friends.entity.FriendGroup;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

/**
 * @Description: TODO(todo)
 * 
 * @date 2019/8/27 9:41
 * @version V1.0
 */
public interface FriendGroupDao extends IMongoDAO<FriendGroup, ObjectId> {

    void addFriendGroup(FriendGroup friendGroup);

    void updateFriendGroup(ObjectId groupId, FriendGroup friendGroup);

    FriendGroup getFriendGroup(int userId, String groupName);

    void updateFriendGroup(int userId, ObjectId groupId, Map<String, Object> map);

    List<FriendGroup> getFriendGroupList(int userId);

    void deleteGroup(int userId, ObjectId groupId);

    void multipointLoginUpdateFriendsGroup(Integer userId, String nickName);
}

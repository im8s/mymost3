package com.shiku.im.friends.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.entity.NewFriends;
import com.shiku.im.repository.IMongoDAO;

import java.util.List;
import java.util.Map;

public interface FriendsDao extends IMongoDAO<Friends,Integer> {

    Friends deleteFriends(int userId, int toUserId);

    void deleteFriends(int userId);

    Friends getFriends(int userId, int toUserId);

    List<Friends> queryBlacklist(int userId, int pageIndex, int pageSize);

    List<Friends> queryFriendsList(int userId, int status, int pageIndex, int pageSize);

    /**
     * 查询好友的用户ID 列表 排除拉黑关系
     * @param userId
     * @return
     */
    List<Integer> queryFriendUserIdList(int userId);

    PageResult<Friends> queryFollowByKeyWord(int userId, int status, String keyWord, int pageIndex, int pageSize);

    List<Integer> queryFollowId(int userId);

    List<Friends> queryFriends(int userId);

    List<Friends> queryAllFriends(Integer userId);

    List<Friends> friendsOrBlackList(int userId, String type);

    Object saveFriends(Friends friends);

    Friends updateFriends(Friends friends);

    void updateFriends(int userId, int toUserId, Map<String, Object> map);

    void updateFriendsAttribute(int userId, int toUserId, String key, Object value);

    Friends updateFriendsReturn(int userId, int toUserId, Map<String, Object> map);

    void updateFriendsEncryptType(int userId, int toUserId, byte type);

    List<Friends> queryBlacklistWeb(int userId, int pageIndex, int pageSize);


    PageResult<Friends> consoleQueryFollow(int userId, int toUserId, int status, int page, int limit);


    Friends updateFriendRemarkName(Integer userId, Integer toUserId, String remarkName, String describe);

    List<Object> getAddFriendsCount(long startTime, long endTime, String mapStr, String reduce);

    List<NewFriends> getNewFriendsList(int userId, int pageIndex, int pageSize);

    NewFriends getNewFriendLast(int userId, int toUserId);

    long getFriendsCount(int userId);

    long queryAllFriendsCount();
}

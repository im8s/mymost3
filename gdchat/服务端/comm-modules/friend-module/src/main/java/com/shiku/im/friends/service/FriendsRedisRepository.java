package com.shiku.im.friends.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.friends.entity.Friends;
import com.shiku.redisson.AbstractRedisson;
import org.redisson.api.RList;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
public class FriendsRedisRepository extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }




    /**
     * 用户的好友userId列表
     */
    public static final String FRIENDS_USERIDS="friends:toUserIds:%s";



    /**
     * 用户通讯录好友userId列表
     */
    public static final String ADDRESSBOOK_USERIDS="addressBook:userIds";


    /**
     * 用户的好友列表
     */
    public static final String FRIENDS_USERS="friends:toUsers:%s";



    /** @Description: 删除通讯录好友userIds列表
     * @param userId
     **/
    public void delAddressBookFriendsUserIds(Integer userId){
        String key = String.format(ADDRESSBOOK_USERIDS,userId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 获取通讯录好友列表userIds
     * @param userId
     * @return
     **/
    public List<Integer> getAddressBookFriendsUserIds(Integer userId){
        String key = String.format(ADDRESSBOOK_USERIDS,userId);
        RList<Integer> list = redissonClient.getList(key);
        return list.readAll();
    }

    /** @Description: 维护用户通讯录好友列表userIds
     * @param userId
     **/
    public void saveAddressBookFriendsUserIds(Integer userId,List<Integer> friendIds){
        String key = String.format(ADDRESSBOOK_USERIDS,userId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(friendIds);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }




    /** @Description: 删除用户userIds
     * @param userId
     **/
    public void deleteFriendsUserIdsList(Integer userId){
        String key = String.format(FRIENDS_USERIDS,userId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 获取好友列表userIds
     * @param userId
     * @return
     **/
    public List<Integer> getFriendsUserIdsList(Integer userId){
        String key = String.format(FRIENDS_USERIDS,userId);
        RList<Integer> list = redissonClient.getList(key);
        return list.readAll();
    }

    /** @Description: 维护用户好友列表
     * @param userId
     **/
    public void saveFriendsList(Integer userId,List<Friends> friends){
        String key = String.format(FRIENDS_USERS,userId);
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(friends);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    /** @Description: 删除用户好友列表
     * @param userId
     **/
    public void deleteFriends(Integer userId){
        String key = String.format(FRIENDS_USERS,userId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description:（获取好友列表）
     * @param userId
     * @return
     **/
    public List<Friends> getFriendsList(Integer userId){
        String key = String.format(FRIENDS_USERS,userId);
        RList<Friends> friendList = redissonClient.getList(key);
        return friendList.readAll();
    }


    /** @Description: 维护用户好友列表userIds
     * @param userId
     **/
    public void saveFriendsUserIdsList(Integer userId,List<Integer> friendIds){
        String key = String.format(FRIENDS_USERIDS,userId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(friendIds);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

}

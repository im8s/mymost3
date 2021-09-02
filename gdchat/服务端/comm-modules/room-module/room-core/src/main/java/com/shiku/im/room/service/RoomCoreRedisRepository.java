package com.shiku.im.room.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.room.dao.RoomCoreDao;
import com.shiku.im.room.dao.RoomMemberCoreDao;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.entity.Room.Member;
import com.shiku.redisson.AbstractRedisson;
import org.bson.types.ObjectId;
import org.redisson.api.RBucket;
import org.redisson.api.RList;
import org.redisson.api.RedissonClient;
import org.redisson.client.codec.IntegerCodec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.concurrent.TimeUnit;

@Repository
public class RoomCoreRedisRepository extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }


    @Autowired
    private RoomCoreDao roomCoreDao;

    @Autowired
    private RoomMemberCoreDao roomMemberCoreDao;


    /**
     * 群组 离线推送成员列表
     */
    public static final String ROOMPUSH_MEMBERLIST = "roomPush_member:%s";

    /**
     * 用户群组 Jid 列表
     */
    public static final String ROOMJID_LIST = "roomJidList:%s";

    /**
     * 用户 免打扰的 群组列表
     */
    public static final String ROOM_NOPUSH_Jids="room_nopushJids:%s";



    /**
     * 群组对象(群组对象不包含:群成员，公告列表)
     */
    public static final String ROOMS="room:rooms:%s";



    /**
     * 群组内的群成员列表
     */
    public static final String ROOM_MEMBERLIST="room:memberList:%s";

    /**
     * 群公告列表
     */
    public static final String ROOM_NOTICELIST="room:noticeList:%s";






    /**
     * 查询群推送成员列表
     * @param jid
     * @return
     */
    public List<Integer> queryRoomPushMemberUserIds(String jid){
        String key = String.format(ROOMPUSH_MEMBERLIST,jid);
        RList<Integer> list= redissonClient.getList(key, IntegerCodec.INSTANCE);
        return list.readAll();
    }

    public void addRoomPushMember(String jid,Integer userId){
        String key = String.format(ROOMPUSH_MEMBERLIST,jid);
        RList<Integer> list = redissonClient.getList(key,IntegerCodec.INSTANCE);
        if(!list.contains(userId))
            list.addAsync(userId);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    public void removeRoomPushMember(String jid,Integer userId){
        String key = String.format(ROOMPUSH_MEMBERLIST,jid);
        redissonClient.getList(key,IntegerCodec.INSTANCE).removeAsync(userId);

    }

    public void saveRoom(Room room){
        String key = String.format(ROOMS,room.getId().toString());
        RBucket<Room> bucket = redissonClient.getBucket(key);
        bucket.set(room, KConstants.Expire.DAY1,TimeUnit.SECONDS);
    }
    public Room queryRoom(ObjectId roomId){
        String key = String.format(ROOMS,roomId.toString());
        RBucket<Room> bucket = redissonClient.getBucket(key);
        if(bucket.isExists())
            return bucket.get();
        else return null;
    }

    public void deleteRoom(String roomId){
        String key = String.format(ROOMS, roomId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 群成员列表
     * @param roomId
     * @return
     **/
    public List<Member> getMemberList(String roomId){
        String key = String.format(ROOM_MEMBERLIST, roomId);
        RList<Member> rList = redissonClient.getList(key);
        return rList.readAll();
    }


    /** @Description: 删除群成员列表
     * @param roomId
     **/
    public void deleteMemberList(String roomId){
        String key = String.format(ROOM_MEMBERLIST, roomId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description:保存群成员列表
     * @param roomId
     * @param members
     **/
    public void saveMemberList(String roomId,List<Member> members){
        String key = String.format(ROOM_MEMBERLIST,roomId);
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(members);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }







    public List<String> queryUserRoomJidList(Integer userId){
        String key = String.format(ROOMJID_LIST,userId);
        RList<String> list = redissonClient.getList(key);

        if(0==list.size()) {
            List<String> roomsJidList = roomMemberCoreDao.queryUserRoomsJidListByDB(userId);
            if(0<roomsJidList.size()) {
                list.addAllAsync(roomsJidList);
                list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
            }
            return roomsJidList;
        }else
            return list.readAll();
    }


    public void updateUserRoomJidList(Integer userId){
        String key = String.format(ROOMJID_LIST,userId);
        RBucket<Object> bucket = redissonClient.getBucket(key);
        List<String> roomsJidList = roomMemberCoreDao.queryUserRoomsJidListByDB(userId);
        bucket.set(roomsJidList, KConstants.Expire.DAY7, TimeUnit.SECONDS);

    }
    public void deleteUserRoomJidList(Integer userId){
        String key = String.format(ROOMJID_LIST,userId);
        RBucket<Object> bucket = redissonClient.getBucket(key);
        if(bucket.isExists())
            bucket.delete();

    }



    /**
     * 查询用户开启免打扰的  群组Jid 列表
     * @param userId
     * @return
     */
    public List<String> queryNoPushJidLists(Integer userId){
        String key = String.format(ROOM_NOPUSH_Jids,userId);
        RList<String> list = redissonClient.getList(key);
        if (0 == list.size()) {
            List<String> roomsJidList = roomMemberCoreDao.queryUserNoPushJidList(userId);
            if (0 < roomsJidList.size()) {
                list.addAllAsync(roomsJidList);
                list.expire(KConstants.Expire.DAY1, TimeUnit.SECONDS);
            }
            return roomsJidList;
        } else {
            return list.readAll();
        }
    }
    public void addToRoomNOPushJids(Integer userId,String jid){
        String key = String.format(ROOM_NOPUSH_Jids,userId);
        RList<String> list = redissonClient.getList(key);
        if(!list.contains(jid))
            list.addAsync(jid);
        list.expire(KConstants.Expire.DAY1, TimeUnit.SECONDS);
    }
    public void removeToRoomNOPushJids(Integer userId,String jid){
        String key = String.format(ROOM_NOPUSH_Jids,userId);
        RList<String> list = redissonClient.getList(key);
        list.removeAsync(jid);
        list.expire(KConstants.Expire.DAY1, TimeUnit.SECONDS);
    }

    public void saveJidsByUserId(Integer userId, String jid, ObjectId roomId){
        roomMemberCoreDao.saveJidsByUserId(userId,jid,roomId);
        deleteUserRoomJidList(userId);

    }

    public void delJidsByUserId(Integer userId,String jid) {
        roomMemberCoreDao.delJidsByUserId(userId,jid);
        deleteUserRoomJidList(userId);
    }










}

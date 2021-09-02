package com.shiku.im.room.service;

import com.alibaba.fastjson.JSON;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.entity.Room.Member;
import com.shiku.im.room.entity.Room.Notice;
import com.shiku.im.room.entity.Room.Share;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.redisson.AbstractRedisson;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.redisson.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

@Service("RoomRedisRepository1")
public class RoomRedisRepository extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }



    @Autowired
    private RoomCoreRedisRepository roomCoreRedisRepository;

   @Autowired
    private UserCoreService userCoreService;


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
     *面对面建群
     */
    public static final String GEO_LOCATION_ROOM = "locationRoom:room:%s";


    /**
     *面对面建群
     */
    public static final String GEO_LOCATION_ROOM_ID = "locationRoom:id:%s";

    /**
     * 群组内的群成员列表
     */
    public static final String ROOM_MEMBERLIST="room:memberList:%s";

    /**
     * 群公告列表
     */
    public static final String ROOM_NOTICELIST="room:noticeList:%s";

    /**
     * 群文件列表
     */
    public static final String ROOM_SHARELIST="room:shareList:%s";







    /**
     * 查询群推送成员列表
     * @param jid
     * @return
     */
   /* public List<Integer> queryRoomPushMemberUserIds(String jid){
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
    */

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
    public List<Member> getMemberList(String roomId,Integer pageIndex,Integer pageSize){
        String key = String.format(ROOM_MEMBERLIST, roomId);
        List<Member> redisPageLimit = redisPageLimit(key, pageIndex, pageSize);
        return redisPageLimit;
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


    /** @Description: 群公告列表
     * @param roomId
     * @return
     **/
    public List<Notice> getNoticeList(ObjectId roomId){
        String key = String.format(ROOM_NOTICELIST, roomId.toString());
        RList<Notice> rList = redissonClient.getList(key);
        return rList.readAll();
    }

    /** @Description: 删除群公告列表
     * @param roomId
     **/
    public void deleteNoticeList(Object roomId){
        String key = String.format(ROOM_NOTICELIST, roomId.toString());
        redissonClient.getBucket(key).delete();
    }

    /** @Description:保存群公告列表
     * @param roomId
     * @param members
     **/
    public void saveNoticeList(ObjectId roomId,List<Notice> notices){
        String key = String.format(ROOM_NOTICELIST,roomId.toString());
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(notices);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    /** @Description: 群共享文件列表
     * @param roomId
     * @param pageIndex
     * @param pageSize
     * @return
     **/
    public List<Share> getShareList(ObjectId roomId,Integer pageIndex,Integer pageSize){
        String key = String.format(ROOM_SHARELIST, roomId.toString());
        List<Share> redisPageLimit = redisPageLimit(key, pageIndex, pageSize);
        return redisPageLimit;
    }

    /** @Description: 删除群文件列表
     * @param roomId
     **/
    public void deleteShareList(Object roomId){
        String key = String.format(ROOM_SHARELIST, roomId.toString());
        redissonClient.getBucket(key).delete();
    }

    /** @Description:保存群文件列表
     * @param roomId
     * @param members
     **/
    public void saveShareList(ObjectId roomId,List<Share> shares){
        String key = String.format(ROOM_SHARELIST,roomId.toString());
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(shares);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }





    public List<String> queryUserRoomJidList(Integer userId){

       return roomCoreRedisRepository.queryUserRoomJidList(userId);

    }


    public void updateUserRoomJidList(Integer userId){
        roomCoreRedisRepository.updateUserRoomJidList(userId);

    }
    public void deleteUserRoomJidList(Integer userId){
        roomCoreRedisRepository.deleteUserRoomJidList(userId);
    }



    /**
     * 查询用户开启免打扰的  群组Jid 列表
     * @param userId
     * @return
     */
    public List<String> queryNoPushJidLists(Integer userId){
        return roomCoreRedisRepository.queryNoPushJidLists(userId);

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





    /**
     * 根据 密码查询 附近的 群组Jid
     * @param longitude
     * @param latitude
     * @param password
     * @return
     */
    public synchronized  String queryLocationRoomJid(double longitude,double latitude,
                                                     String password) {
        String key = String.format(GEO_LOCATION_ROOM_ID,password);
        String jid=null;
        RGeo<String> geo = redissonClient.getGeo(key);
        List<String> radius = geo.radius(longitude, latitude, 5, GeoUnit.KILOMETERS,1);
        if(0==radius.size()) {
            jid = StringUtil.randomUUID();
            geo.add(longitude, latitude,jid);
            geo.expire(10, TimeUnit.MINUTES);
        }else {
            jid=radius.get(0);
        }
        return jid;
    }

    public void deleteLocalRoomJid(double longitude,double latitude,String password){
        String key = String.format(GEO_LOCATION_ROOM_ID,password);
        String jid=null;
        RGeo<String> geo = redissonClient.getGeo(key);
        List<String> radius = geo.radius(longitude, latitude, 5, GeoUnit.KILOMETERS,1);
        System.out.println(" =========   radius =========== ："+ JSON.toJSONString(radius));
        if(radius.size() != 0){
            geo.delete();
        }
    }

    public Room queryLocationRoom(int userId,double longitude,double latitude,
                                    String password,String name) {
        Room result=null;
        String jid=queryLocationRoomJid(longitude, latitude, password);
        String key = String.format(GEO_LOCATION_ROOM,jid);
        RBucket<Room> bucket = redissonClient.getBucket(key);
        result=bucket.get();
        if(null==result) {
            result=new Room();
            result.setJid(jid);
            // 维护经纬度和面对面建群的key
            result.setLongitude(longitude);
            result.setLatitude(latitude);
            result.setLocalRoomKey(password);
            Room.Member member=new Member();
            member.setUserId(userId);
            member.setNickname(userCoreService.getNickName(userId));
            if(!StringUtil.isEmpty(name))
                result.setName(name);
            else {
                result.setName(member.getNickname());
            }

            result.addMember(member);
            bucket.set(result);
            bucket.expire(10, TimeUnit.MINUTES);
        }else {
            Room.Member member=new Member();
            member.setUserId(userId);
            member.setNickname(userCoreService.getNickName(userId));
            result.addMember(member);
            bucket.set(result);
        }
        return result;
    }

    public Room queryLocationRoom(String jid) {
        String key = String.format(GEO_LOCATION_ROOM,jid);
        RBucket<Room> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public void saveLocationRoom(String jid,Room room) {
        String key = String.format(GEO_LOCATION_ROOM,jid);
        RBucket<Room> bucket = redissonClient.getBucket(key);
        bucket.set(room);
    }

    public void exitLocationRoom(int userId,String jid) {
        String key = String.format(GEO_LOCATION_ROOM,jid);
        RBucket<Room> bucket = redissonClient.getBucket(key);
        if(!bucket.isExists()) {
            return;
        }
        Room room = bucket.get();
        room.removeMember(userId);
        bucket.set(room);
    }

    public void deleteLocalRoom(String jid){
        String key = String.format(GEO_LOCATION_ROOM,jid);
        RBucket<Room> bucket = redissonClient.getBucket(key);
        bucket.delete();
    }





}

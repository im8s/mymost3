package com.shiku.im.room.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.room.entity.Room;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RoomMemberDao extends IMongoDAO<Room.Member, ObjectId> {

    void addMember(Room.Member entity);

    void addMemberList(List<Room.Member> memberList);

    Room.Member getMember(ObjectId roomId, int userId);



    List<Room.Member> getMemberList(ObjectId roomId,int pageIndex,int pageSize);

    PageResult<Room.Member> getMemberListResult(ObjectId roomId, int pageIndex, int pageSize);

    List<Room.Member> getMemberListLessThanOrEq(ObjectId roomId,int role,int pageIndex,int pageSize);

    List<Room.Member> getMemberListLessThan(ObjectId roomId,int role,int pageIndex,int pageSize);

    List<Room.Member> getMemberListGreaterThan(ObjectId roomId,int role,int pageIndex,int pageSize);

    List<Room.Member> getMemberListByTime(ObjectId roomId,int role,long createTime,int pageSize);

    List<Room.Member> getMemberListByNickname(ObjectId roomId,String nickName);

    List<Room.Member> getMemberListOrder(ObjectId roomId);

    Map<String,Object> getMemberListOr(ObjectId roomId,int role,int userId,int pageIndex,int pageSize);

    List<Room.Member> getMemberListAdminRole(ObjectId roomId,int role,int pageSize);

    Object getMemberOneFile(ObjectId roomId,int userId,int offlineNoPushMsg);




    List<Integer>  getMemberUserIdList(ObjectId roomId,int role);

    Object findMemberRole(ObjectId roomId, int userId);

    void deleteRoomMember(ObjectId roomId,Integer userId);

    void updateRoomMember(ObjectId roomId,long talkTime);

    void updateRoomMemberRole(ObjectId roomId,int userId,int role);

    void updateRoomMember(ObjectId roomId, int userId, Map<String,Object> map);

    void updateRoomMemberAttribute(ObjectId roomId, int userId,String key,Object value);

    long getMemberNumGreaterThanOrEq(ObjectId roomId,byte role,int pageIndex,int pageSize);

    long getMemberNumLessThan(ObjectId roomId,byte role,int userId);
}

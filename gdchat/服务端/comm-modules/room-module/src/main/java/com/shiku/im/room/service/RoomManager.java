package com.shiku.im.room.service;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.entity.Room.Share;
import com.shiku.im.user.entity.User;
import org.bson.types.ObjectId;

import java.util.List;


public interface RoomManager {
	public static final String BEAN_ID = "RoomManagerImpl";

	Room add(User user, Room room, List<Integer> memberUserIdList, JSONObject userKeys);

	void delete( ObjectId roomId,Integer userId);


	Room get(ObjectId roomId,Integer pageIndex,Integer pageSize);

	Room getRoomByJid(String roomJid);

	Room exisname(Object roomname,ObjectId roomId);

	List<Room> selectList(int pageIndex, int pageSize, String roomName);

	Object selectHistoryList(int userId, int type);

	Object selectHistoryList(int userId, int type, int pageIndex, int pageSize);

	void deleteMember(User user, ObjectId roomId, int userId,boolean deleteUser);

	void updateMember(User user, ObjectId roomId, Room.Member member);

	void updateMember(User user, ObjectId roomId, List<Integer> idList,JSONObject userKeys);
	
	void Memberset(Integer offlineNoPushMsg,ObjectId roomId,int userId,int type);

	Room.Member getMember(ObjectId roomId, int userId);

	List<Room.Member> getMemberList(ObjectId roomId,String keyword);

    Room.Notice updateNotice(ObjectId roomId, ObjectId noticeId, String noticeContent, Integer userId);

    void join(int userId, ObjectId roomId, int type);

	void setAdmin(ObjectId roomId,int touserId,int type,int userId);

	void setExtRole(ObjectId roomId,int toUserId,int type,int userId, int operate);

	Share Addshare(ObjectId roomId,long size,int type ,int userId, String url,String name);
	
	List<Room.Share> findShare(ObjectId roomId,long time,int userId,int pageIndex,int pageSize);
	
	Room.Share getShare(ObjectId roomId, ObjectId shareId);
	
	void deleteShare(ObjectId roomId,ObjectId shareId,int userId);
	
	String getCall(ObjectId roomId);
	
	String getVideoMeetingNo(ObjectId roomId);

	Long countRoomNum();

    Room getRoom(ObjectId objRoomId, Integer adminUserId);

	void joinRoom(Integer userId, String name, ObjectId objRoomId, long currentTime, Integer adminUserId);

	List<ObjectId> getRoomIdList(Integer userId);

	String getRoomName(ObjectId objectId);

	Integer getRoomStatus(ObjectId objectId);

	void deleteRedisRoom(String toString);
}

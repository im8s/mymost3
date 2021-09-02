package com.shiku.im.user.service;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.user.entity.*;
import com.shiku.im.user.model.LoginExample;
import com.shiku.im.user.model.SdkLoginInfo;
import com.shiku.im.user.model.UserExample;
import com.shiku.im.user.model.UserQueryExample;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface UserManager extends IBaseUserManager {

	User createUser(String telephone, String password);

	void createUser(User user);

	User.UserSettings getSettings(int userId);

	User getUser(int userId);
	
	User getUser(int userId, int toUserId);

	User getUser(String telephone);
	
	String getNickName(int userId);

	int getUserId(String accessToken);

	boolean isRegister(String telephone);

	User login(String telephone, String password);
	
	Map<String, Object> login(LoginExample example);


	void logout(String access_token, String areaCode, String userKey, String deviceKey);

	void outtime(String access_token, int userId);

	List<Document> query(UserQueryExample param);

	Map<String, Object> register(UserExample example);


	Map<String, Object> registerIMUser(UserExample example) throws Exception;

	/**
	 * 第三方账号注册
	 * @param example
	 * @param type
	 * @return
	 * @throws Exception
	 */
	Map<String, Object> registerIMUserBySdk(UserExample example, int type) throws Exception;


	void addUser(int userId, String password);

	int resetPassword(String telephone, String password);

	void updatePassword(int userId, String oldPassword, String newPassword);

	User updateSettings(int userId, User.UserSettings userSettings);

	User updateUser(int userId, UserExample example);

	List<Document> findUser(int pageIndex, int pageSize);

	List<Integer> getAllUserId();

	//消息免打扰
	User updataOfflineNoPushMsg(int userId, int OfflineNoPushMsg);

	// 添加收藏
	List<Object> addCollection(int userId, String roomJid, String msgId, String type);

	// 添加收藏表情
	Object addEmoji(int userId, String url, String type);

	// 收藏列表
	List<Emoji> emojiList(int userId, int type, int pageSize, int pageIndex);

	List<Emoji> emojiList(int userId);

	//取消收藏
	void deleteEmoji(Integer userId, String emojiId);

	//添加消息课程
	void addMessageCourse(int userId, List<String> messageIds, long createTime, String courseName, String roomJid);

	//通过userId获取用户课程
	List<Course> getCourseList(int userId);

	//修改课程
	void updateCourse(Course course, String courseMessageId);

	//删除课程
	boolean deleteCourse(Integer userId, ObjectId courseId);

	//发送课程
	List<CourseMessage> getCourse(String courseId);

	//void updateContent(ObjectId courseMessageId);
	//添加微信公众号用户
	WxUser addwxUser(JSONObject jsonObject);

	JSONObject getWxOpenId(String code);

	String getWxToken();

	Integer createInviteCodeNo(int createNum);

	SdkLoginInfo addSdkLoginInfo(int type, Integer userId, String loginInfo);

	SdkLoginInfo findSdkLoginInfo(int type, String loginInfo);

	User.LoginLog getLogin(int userId);

    List<User> queryPublicUser(int page, int limit, String keyWorld);
}

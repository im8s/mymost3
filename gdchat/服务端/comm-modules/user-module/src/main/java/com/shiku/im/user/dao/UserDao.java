package com.shiku.im.user.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.LoginExample;
import com.shiku.im.user.model.NearbyUser;
import com.shiku.im.user.model.UserExample;
import com.shiku.im.user.model.UserQueryExample;
import org.bson.Document;

import java.util.List;
import java.util.Map;

public interface UserDao extends IMongoDAO<User,Integer> {
    Map<String, Object> addUser(int userId, UserExample param);

    void addUser(User user);

    void addUser(int userId,String password);

    List<User> findByTelephone(List<String> telephoneList);

    long getCount(String telephone);

    User.LoginLog getLogin(int userId);

    long getUserOnlinestateCount(int onlinestate);

    User.UserSettings getSettings(int userId);

    User getUser(int userId);

    User getUser(String telephone);

    User getUser(String areaCode,String userKey, String password);

    User getUserv1(String userKey, String password);

    List<Document> queryUser(UserQueryExample param);

    List<Document> findUser(int pageIndex, int pageSize);

    void updateLogin(int userId, String serial);

    void updateLogin(int userId, UserExample example);

    void  updateUserLoginLog(int userId, LoginExample example);

    void updateLoginLogTime(int userId);

//    User updateUser(int userId, UserExample param);

    User updateSettings(int userId,User.UserSettings userSettings);

    User updateUser(User user);

    void updateUserOnline();

    void updateUser(int userId,Map<String,Object> map);

    User updateUserResult(int userId,Map<String,Object> map);

    void updatePassword(String telephone, String password);

    void updatePassowrd(int userId, String password);

    List<User> searchUsers(int pageIndex,int pageSize,String strKeyworld,short onlinestate,short userType);

    User.UserLoginLog queryUserLoginLog(int userId);

    void updateLoc(int userId,User.Loc loc);

    void saveIosAppId(int userId,String appId);

    void updateDeviceMap(int userId,String devicekey);

    List<Integer> getAllUserId();

    void updateUserOfflineTime(int userId);

    Double updateUserBalanceSafe(Integer userId,double balance);

    User updateOfflineNoPushMsg(Integer userId,int OfflineNoPushMsg);

    Integer createUserId(Integer userId);

    Integer createCall();

    Integer createvideoMeetingNo();

    Integer createInviteCodeNo(int createNum);

    Integer getServiceNo(String areaCode);

    List<Object> getUserRegisterCount(long startTime,long endTime,String mapStr,String reduce);

    List<Object> getUserOnlineStatusCount(long startTime,long endTime,short timeUnit,String mapStr,String reduce);

    List<User> getUserlimit(int pageIndex, int pageSize,int isAuth);

    List<User> getNearbyUser(NearbyUser model, Integer userId, int telephoneSearchUser, int nicknameSearchUser);

    void deleteUserById(Integer userId);

//    List<OfflineOperation> getOfflineOperation(Integer userId, long startTime);

    long getAllUserCount();

    Object getOneFieldById(String key,int userId);

    User getUserByAccount(String account,Integer userId);

    User.LoginDevices getLoginDevices(int userId);

    void addLoginDevices(User.LoginDevices loginDevices);

    List<User> exprotExcelPhone(long startTime,long endTime,String onlinestate, String keyWord);


    void savePushToken(Integer userId, User.DeviceInfo info);

    List<User> queryPublicUser(int page, int limit, String keyWorld);

    List<User> findUserList(int pageIndex, int pageSize, Integer notId);

    void updateIpInfo(int userId, User.IpInfo ipInfo);
}

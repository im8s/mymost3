package com.shiku.im.user.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.User;
import org.bson.Document;

import java.util.List;
import java.util.Map;

public interface UserCoreDao extends IMongoDAO<User,Integer> {


    void addUser(User user);
    List<User> findByTelephone(List<String> telephoneList);

    long getCount(String telephone);

    long getUserOnlinestateCount(int onlinestate);

    User.LoginLog getLogin(int userId);

    User.UserSettings getSettings(int userId);

    User getUser(int userId);

    User getUser(String telephone);

    Double updateUserBalanceSafe(Integer userId, double balance);



    User getUser(String areaCode, String userKey, String password);

    User getUserv1(String userKey, String password);


    List<Document> findUser(int pageIndex, int pageSize);

    void updateLogin(int userId, String serial);




    User updateUser(User user);

    void updateUserOnline();

    void updateUser(int userId, Map<String, Object> map);

    User updateUserResult(int userId, Map<String, Object> map);

    void updatePassword(String telephone, String password);

    void updatePassowrd(int userId, String password);


    User.UserLoginLog queryUserLoginLog(int userId);

    void updateLoc(int userId, User.Loc loc);


    void updateDeviceMap(int userId, String devicekey);

    List<Integer> getAllUserId();


    Integer createUserId(Integer userId);

    Integer createCall();

    Integer createvideoMeetingNo();

    Integer createInviteCodeNo(int createNum);


    List<Object> getUserRegisterCount(long startTime, long endTime, String mapStr, String reduce);


    List<User> getUserlimit(int pageIndex, int pageSize, int isAuth);


    void deleteUserById(Integer userId);


    long getAllUserCount();

    Object getOneFieldById(String key, int userId);

    User getUserByAccount(String account, Integer userId);

    User updateSettings(int userId, User.UserSettings userSettings);
}

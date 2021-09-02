package com.shiku.im.user.service;

import com.shiku.im.support.Call;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import org.bson.Document;

import java.util.List;

public interface UserCoreService {

	User createUser(String telephone, String password);

	void createUser(User user);

	User.UserSettings getSettings(int userId);

	User getUser(int userId);

	User getUser(int userId, int toUserId);

	User getUser(String telephone);

	String getNickName(int userId);

	Double getUserMoenyV1(Integer userId);

	Double rechargeUserMoenyV1(UserMoneyLog userMoneyLog);

	Double rechargeUserMoenyV1(UserMoneyLog userMoneyLog, Call<Double> callback);


	/**
	 * 余额交易支出金额 加分布式锁
	 * @param userId 用户ID
	 * @param money 支出金额
	 * @param callback 加锁成功执行逻辑
	 */
	Object payMoenyBalanceOnLock(Integer userId, double money, Call callback)throws Exception;

	int getUserId(String accessToken);

	boolean isRegister(String telephone);


	void updatePersonalInfo(Integer userId, String nickName, Integer toUserId, String toNickName, int type);

	List<Document> findUser(int pageIndex, int pageSize);

	List<Integer> getAllUserId();


	void multipointLoginDataSync(Integer userId, String nickName, String operationType);

	User.LoginLog getLogin(int userId);

	Integer createInviteCodeNo(int createNum);

	int getOnlinestateByUserId(Integer key);

	Integer createUserId();

	boolean isOpenMultipleDevices(int userId);

    User updateSettings(int userId, User.UserSettings userSettings);

    void multipointLoginUpdateUserInfo(Integer userId, String nickName, Integer toUserId, String nickName1, int i);

    void delReport(Integer userId, String roomId);

    void rechargeUserMoeny(UserMoneyLog userMoneyLog);

    void updatePassowrd(int userId, String password);

    int getMsgNum(int toUserId);

	void changeMsgNum(int toUserId, int msgNum);
}

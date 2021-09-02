package com.shiku.im.admin.service;


import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.*;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.PayConfig;
import com.shiku.im.entity.SysApiLog;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.user.entity.InviteCode;
import org.bson.types.ObjectId;


public interface AdminManager {

	Config getConfig();
	
	ClientConfig getClientConfig();

	PayConfig getPayConfig();
	
	Config initConfig();
	
	ClientConfig initClientConfig();

	PayConfig initPayConfig();
	
	void setConfig(Config dbObj);
	
	void setClientConfig(ClientConfig dbObj);

	void setPayConfig(PayConfig dbObj);

	PageResult<SysApiLog> apiLogList(String keyWorld, int page, int limit) throws Exception;

	void deleteApiLog(String apiLogId, int type);

	void addServerList(ServerListConfig server);

	PageResult<ServerListConfig> getServerList(ObjectId id, int pageIndex, int limit);

	PageResult<ServerListConfig> findServerByArea(String area);

	void updateServer(ServerListConfig server);

	void deleteServer(ObjectId id);

	PageResult<AreaConfig> areaConfigList(String area, int pageIndex, int limit);

	void addAreaConfig(AreaConfig areaConfig);

	void updateAreaConfig(AreaConfig areaConfig);

	void deleteAreaConfig(ObjectId id);

	UrlConfig addUrlConfig(UrlConfig urlConfig);

	void deleteUrlConfig(ObjectId id);

	PageResult<UrlConfig> findUrlConfig(ObjectId id, String type);

	UrlConfig findUrlConfig(String area);

	CenterConfig addCenterConfig(CenterConfig centerConfig);

	PageResult<CenterConfig> findCenterConfig(String type, ObjectId id);

	CenterConfig findCenterCofigByArea(String clientA, String clientB);

	void deleteCenter(ObjectId id);

	void addTotalConfig(TotalConfig totalConfig);


	void addAdmin(String account, String password, byte role);

	Admin findAdminByAccount(String account);

	void delAdminById(ObjectId adminId);

	Admin modifyAdmin(Admin admin);

	PageResult<Admin> adminList(String keyWorld, ObjectId adminId, int page, int limit);

	Admin findAdminById(ObjectId adminId);

	boolean changePasswd(ObjectId adminId, String newPwd);

	PageResult<SkOpenApp> openAppList(int status, int type, int pageIndex, int limit, String keyworld);

	void createInviteCode(int num, int userId);

	PageResult<InviteCode> inviteCodeList(int userId, String keyworld, short status, int page, int limit);

	boolean delInviteCode(int userId, String inviteCodeId);

	InviteCode findUserPopulInviteCode(int userId);
	
	
}

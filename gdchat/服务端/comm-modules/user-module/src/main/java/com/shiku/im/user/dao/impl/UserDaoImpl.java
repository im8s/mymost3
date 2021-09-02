package com.shiku.im.user.dao.impl;


import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.mongodb.BasicDBObject;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import com.shiku.common.util.StringUtil;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.repository.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.UserDao;
import com.shiku.im.user.entity.PushInfo;
import com.shiku.im.user.entity.Role;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserStatusCount;
import com.shiku.im.user.model.LoginExample;
import com.shiku.im.user.model.NearbyUser;
import com.shiku.im.user.model.UserExample;
import com.shiku.im.user.model.UserQueryExample;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.utils.MoneyUtils;
import com.shiku.im.user.utils.UserUtil;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.Md5Util;
import com.shiku.utils.ValueUtil;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.Metrics;
import org.springframework.data.geo.Point;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@Repository(value = "userDao")
public class UserDaoImpl extends MongoRepository<User, Integer> implements UserDao {

    private final String USER_DBNAME="user";


    @Autowired
    private UserCoreService userCoreService;

    @Autowired
    private UserCoreRedisRepository userCoreRedisRepository;
    @Override
    public Class<User> getEntityClass() {
        return User.class;
    }

    @Override
    public Map<String, Object> addUser(int userId, UserExample example) {
        example.setAccount(UserUtil.getAccountNo(userId));
        Document jo = new Document();
        jo.put("_id", userId);// 索引
        jo.put("userKey", Md5Util.md5Hex(example.getPhone()));// 索引
        jo.put("username", "");
        jo.put("password", example.getPassword());
        jo.put("payPassword", example.getPayPassWord());
        jo.put("userType", ValueUtil.parse(example.getUserType()));

        jo.put("telephone", example.getTelephone());// 索引
        jo.put("phone", example.getPhone());// 索引
//        jo.put("account", example.getAccount());
        //统一使用系统生成的account规则，不再关注外部传入的accountId
        jo.put("account", UserUtil.getAccountNo(userId));
        jo.put("areaCode", example.getAreaCode());// 索引
        jo.put("name", ValueUtil.parse(example.getName()));// 索引
        if(10000==userId)
            jo.put("nickname", "客服公众号");// 索引
        else
            jo.put("nickname", ValueUtil.parse(example.getNickname()));// 索引
        jo.put("description", ValueUtil.parse(example.getDescription()));
        jo.put("birthday", ValueUtil.parse(example.getBirthday()));// 索引
        jo.put("sex", ValueUtil.parse(example.getSex()));// 索引
        jo.put("loc", new Document("lng", example.getLongitude()).append(
                "lat", example.getLatitude()));// 索引

        jo.put("countryId", ValueUtil.parse(example.getCountryId()));
        jo.put("provinceId", ValueUtil.parse(example.getProvinceId()));
        jo.put("cityId", ValueUtil.parse(example.getCityId()));
        jo.put("areaId", ValueUtil.parse(example.getAreaId()));

        jo.put("money", 0.00);
        jo.put("moneyTotal", 0.00);
        jo.put("balance", 0.00);
        jo.put("totalRecharge", 0.00);

        jo.put("level", 0);
        jo.put("vip", 0);

        jo.put("friendsCount", 0);
        jo.put("fansCount", 0);
        jo.put("attCount", 0);
        jo.put("msgNum", 0);

        jo.put("createTime", DateUtil.currentTimeSeconds());
        jo.put("modifyTime", DateUtil.currentTimeSeconds());

        jo.put("idcard", "");
        jo.put("idcardUrl", "");

        jo.put("isAuth", example.getIsSmsRegister()==1?1:0);
        jo.put("status", 1);
        jo.put("onlinestate", 0);
        jo.put("regInviteCode", example.getInviteCode());
        jo.put("invitedUserId", example.getInvitedUserId());
        // 初始化登录日志
        //jo.put("loginLog", User.UserLoginLog.init(example, true));
        // 初始化用户设置
        jo.put("settings", User.UserSettings.getDefault());
        // 1、新增用户
        getDatastore().getCollection("user").insertOne(jo);
        initUserLogin(userId,example);
        try {
            // 2、缓存用户认证数据到
            Map<String, Object> data =new HashMap<>();
            data.put("userId", userId);
            data.put("nickname", jo.getString("nickname"));
            data.put("name", jo.getString("name"));
            data.put("createTime", jo.getLong("createTime"));
            return data;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public void initUserLogin(int userId,UserExample example){
        User.UserLoginLog loginLog=new User.UserLoginLog();
        loginLog.setUserId(userId);
        User.LoginLog log= User.UserLoginLog.init(example, true);
        loginLog.setLoginLog(log);
        loginLog.setDeviceMap(Maps.newHashMap());
        getDatastore().save(loginLog);
    }

    @Override
    public void addUser(User user) {
        getDatastore().save(user);
    }

    @Override
    public void addUser(int userId, String password) {
        Document jo = new Document();
        jo.put("_id", userId);// 索引
        if(null!=getDatastore().getCollection(USER_DBNAME).find(jo).first())
            return ;
        jo.put("userKey", Md5Util.md5Hex(userId+""));// 索引
        jo.put("username", String.valueOf(userId));
        jo.put("password", Md5Util.md5Hex(password));

        if(userId==10000){
            jo.put("userType", ValueUtil.parse(2));
            Role role = new Role(userId, String.valueOf(userId), (byte) 2, (byte) 1, 0);
            getDatastore().save(role);
        }else{
            jo.put("userType", ValueUtil.parse(1));
        }


        //jo.put("companyId", ValueUtil.parse(0));  当前版本用户表中不在维护公司Id
        jo.put("telephone","86"+String.valueOf(userId));// 索引
        jo.put("areaCode","86");// 索引
        jo.put("name", String.valueOf(userId));// 索引
        if(10000==userId){
            jo.put("nickname", "客服公众号");// 索引
            jo.put("phone", userId);
        } else if (1100 == userId) {
            jo.put("nickname", "支付公众号");
        }else if (10100>userId||1000==userId) {
            jo.put("nickname", "系统管理员");
        } else{
            jo.put("nickname", String.valueOf(userId));// 索引
        }


        jo.put("description", String.valueOf(userId));
        jo.put("birthday", ValueUtil.parse(userId));// 索引
        jo.put("sex", ValueUtil.parse(userId));// 索引
        jo.put("loc", new Document("lng", 10.00).append(
                "lat", 10.00));// 索引

        jo.put("countryId", ValueUtil.parse(0));
        jo.put("provinceId", ValueUtil.parse(0));
        jo.put("cityId", ValueUtil.parse(400300));
        jo.put("areaId", ValueUtil.parse(0));

        jo.put("money", 0);
        jo.put("moneyTotal", 0);

        jo.put("level", 0);
        jo.put("vip", 0);

        jo.put("friendsCount", 0);
        jo.put("fansCount", 0);
        jo.put("attCount", 0);

        jo.put("createTime", DateUtil.currentTimeSeconds());
        jo.put("modifyTime", DateUtil.currentTimeSeconds());

        jo.put("idcard", "");
        jo.put("idcardUrl", "");

        jo.put("isAuth", 0);
        jo.put("status", 1);
        jo.put("onlinestate", 1);
        // 初始化登录日志
        //jo.put("loginLog", User.LoginLog.init(example, true));
        // 初始化用户设置
        jo.put("settings", User.UserSettings.getDefault());

        // 1、新增用户
        getDatastore().getCollection("user").insertOne(jo);
    }



    @Override
    public List<User> findByTelephone(List<String> telephoneList) {
        Query query = createQuery();
        query.addCriteria(Criteria.where("telephone").in(telephoneList));

        return queryListsByQuery(query);
    }


    /**
     * hsg
     * 2018-07-28
     * 检索用户数据
     * @param strKeyworld   字符型关键词，用于匹配昵称、手机号等
     * @param onlinestate   匹配在线状态
     * @param userType      匹配用户类型     用户类型：1=普通用户；2=公众号 ；3=机器账号，由系统自动生成；4=客服账号
     * @return userList     返回值为检索到的用户列表
     */
    public List<User> searchUsers(int pageIndex,int pageSize,String strKeyworld,short onlinestate,short userType){
        List<User> users = new ArrayList<User>();
        Query query=createQuery();
        addToQuery(query,"role",userType);
        descByquery(query,"createTime");
        query.with(createPageRequest(pageIndex,pageSize));

        List<Role> robots =getDatastore().find(query, Role.class);

        robots.forEach(robot -> {
            User user =userCoreService.getUser(robot.getUserId());
            if(null != user)
                users.add(user);
        });
        return users;
    }



    @Override
    public long getCount(String telephone) {
        Query query=createQuery("telephone",telephone);
        return count(query);
    }

    @Override
    public long getUserOnlinestateCount(int onlinestate) {
        Query q = createQuery("onlinestate",onlinestate);
        return count(q);
    }

    @Override
    public User.LoginLog getLogin(int userId) {

        User.UserLoginLog userLoginLog = getDatastore().findOne(createQuery("_id", userId), User.UserLoginLog.class);
        if(null==userLoginLog||null==userLoginLog.getLoginLog()){
            User.UserLoginLog loginLog = new User.UserLoginLog();
            loginLog.setUserId(userId);
            loginLog.setLoginLog(new User.LoginLog());
            getDatastore().save(loginLog);
            return loginLog.getLoginLog();
        } else {
            return userLoginLog.getLoginLog();
        }




    }


    @Override
    public User.UserSettings getSettings(int userId) {
        User.UserSettings settings=null;
        User user=null;
        user=get(userId);
        if(null==user)
            return null;
        settings=user.getSettings();
        return null!=settings?settings:new User.UserSettings();

    }


    @Override
    public User getUser(int userId) {
        return getDatastore().findById(userId,getEntityClass(),User.getDBName());
    }


    @Override
    public User getUser(String telephone) {
        Query query=createQuery("telephone",telephone);

        return findOne(query);
    }

    @Override
    public User getUserByAccount(String account,Integer userId){
        Query query =createQuery();
        query.addCriteria(Criteria.where("_id").ne(userId));
        Criteria criteria = createCriteria().orOperator(Criteria.where("account").is(account), Criteria.where("phone").is(account));
        query.addCriteria(criteria);
        return findOne(query);
    }
    public User getUserByAccount(String account){
        return  findOne("account",account);
    }


    @Override
    public User getUser(String areaCode,String userKey, String password) {
        Query query =createQuery();
        if (!StringUtil.isEmpty(areaCode))
            addToQuery(query,"areaCode",areaCode);
        if (!StringUtil.isEmpty(userKey)){
            // 支持通讯号
            Criteria criteria = createCriteria().orOperator(Criteria.where("userKey").is(userKey), Criteria.where("encryAccount").is(userKey));
            query.addCriteria(criteria);
        }
        if (!StringUtil.isEmpty(password))
            addToQuery(query,"password",password);

        return findOne(query);
    }

    @Override
    public User getUserv1(String userKey, String password) {
        Query query = createQuery();
        if (!StringUtil.isEmpty(userKey))
            addToQuery(query,"userKey",userKey);
        if (!StringUtil.isEmpty(password))
            addToQuery(query,"password",password);

        return findOne(query);
    }

    @Override
    public List<Document> queryUser(UserQueryExample example) {
        List<Document> list = Lists.newArrayList();

        Document ref = new Document();
        if (null != example.getUserId())
            ref.put("_id", new Document("$lt", example.getUserId()));
        if (!StringUtil.isEmpty(example.getNickname()))
            ref.put("nickname", Pattern.compile(example.getNickname()));
        if (null != example.getSex())
            ref.put("sex", example.getSex());
        if (null != example.getStartTime())
            ref.put("birthday",
                    new BasicDBObject("$gte", example.getStartTime()));
        if (null != example.getEndTime())
            ref.put("birthday", new Document("$lte", example.getEndTime()));
        Document fields = new Document();
        fields.put("userKey", 0);
        fields.put("password", 0);
        fields.put("money", 0);
        fields.put("moneyTotal", 0);
        fields.put("status", 0);

        MongoCursor<Document> cursor = getDatastore().getCollection("user")
                .find(ref).projection(fields).sort(new Document("_id", -1))
                .limit(example.getPageSize()).iterator();
        while (cursor.hasNext()) {
            Document obj = cursor.next();
            obj.put("userId", obj.get("_id"));
            obj.remove("_id");

            list.add(obj);
        }

        return list;
    }

    @Override
    public List<Document> findUser(int pageIndex, int pageSize) {
        List<Document> list = Lists.newArrayList();
        Document fields = new Document();
        fields.put("userKey", 0);
        fields.put("password", 0);
        fields.put("money", 0);
        fields.put("moneyTotal", 0);
        fields.put("status", 0);
        MongoCursor<Document> cursor = getDatastore().getCollection(USER_DBNAME)
                .find(new Document()).projection(fields).sort(new BasicDBObject("_id", -1))
                .skip(pageIndex * pageSize).limit(pageSize).iterator();
        while (cursor.hasNext()) {
            Document obj = cursor.next();
            obj.put("userId", obj.get("_id"));
            obj.remove("_id");
            list.add(obj);
        }

        return list;
    }


    @Override
    public void updateLogin(int userId, String serial) {
        Document value = new Document();

        value.put("serial", serial);


        Document q = new Document("_id", userId);
        Document o = new Document("$set", new Document("loginLog",
                value));
        getDatastore().getCollection(USER_DBNAME).updateOne(q, o);
    }

    @Override
    public void updateLogin(int userId, UserExample example) {
        Document loc = new Document();
        loc.put("loc.lng", example.getLongitude());
        loc.put("loc.lat", example.getLatitude());

        Document values = new Document();
		/*values.put("loginLog.isFirstLogin", 0);
		values.put("loginLog.loginTime", DateUtil.currentTimeSeconds());
		values.put("loginLog.apiVersion", example.getApiVersion());
		values.put("loginLog.osVersion", example.getOsVersion());
		values.put("loginLog.model", example.getModel());
		values.put("loginLog.serial", example.getSerial());
		values.put("loginLog.latitude", example.getLatitude());
		values.put("loginLog.longitude", example.getLongitude());
		values.put("loginLog.location", example.getLocation());
		values.put("loginLog.address", example.getAddress());*/
        values.put("loc.lng", example.getLongitude());
        values.put("loc.lat", example.getLatitude());
        values.put("appId", example.getAppId());
        values.put("active",DateUtil.currentTimeSeconds());

        Document q = new Document("_id", userId);
        Document o = new Document("$set", values);
        // ("loginLog",
        // loginLog)).append
        getDatastore().getCollection(USER_DBNAME).updateOne(q, o);

    }
    public void updateUserLoginLog(int userId, LoginExample example) {
        Document query = new Document("_id", userId);
        Document values = new Document();
        Document object = getDatastore().getCollection(getCollectionName(User.UserLoginLog.class)).find(query).first();
        if (null == object)
            values.put("_id", userId);
        String loginLogStr = JSON.toJSONString(object.get("loginLog"));
        User.LoginLog loginLogObj = JSON.parseObject(loginLogStr, User.LoginLog.class);
        Document loginLog = new Document("isFirstLogin", 0);
        loginLog.put("loginTime", DateUtil.currentTimeSeconds());
        loginLog.put("apiVersion", example.getApiVersion());
        loginLog.put("osVersion", example.getOsVersion());
        loginLog.put("model", example.getModel());
        loginLog.put("serial", example.getSerial());
        loginLog.put("latitude", example.getLatitude());
        loginLog.put("longitude", example.getLongitude());
        loginLog.put("location", example.getLocation());
        loginLog.put("address", example.getAddress());
        loginLog.put("offlineTime", loginLogObj.getOfflineTime());// 每次登陆不重置上次离线时间
        values.put("loginLog", loginLog);
        getDatastore().getCollection(getCollectionName(User.UserLoginLog.class))
                .updateOne(query, new Document(MongoOperator.SET, values), new UpdateOptions().upsert(true));

        //updateAttribute(userId, "appId", example.getAppId());
    }
    public void updateLoginLogTime(int userId){
        Document query = new Document("_id", userId);

        MongoCollection<Document> collection = getDatastore().getCollection(getCollectionName(User.UserLoginLog.class));
        Document values = new Document();
        Document object = collection.find(query).first();
        Document loginLog=null;
        if(null==object||null==object.get("loginLog")) {
            values.put("_id", userId);

            loginLog=new Document("isFirstLogin", 0);
            loginLog.put("loginTime", DateUtil.currentTimeSeconds());
            values.put("loginLog", loginLog);
            collection
                    .updateOne(query,new Document(MongoOperator.SET, values),new UpdateOptions().upsert(true));
        }else {
            values.put("loginLog.loginTime",  DateUtil.currentTimeSeconds());
            collection
                    .updateOne(query,new Document(MongoOperator.SET, values),new UpdateOptions().upsert(true));

        }

    }

    @Override
    public User updateUserResult(int userId, Map<String, Object> map) {
        Query query = createQuery(userId);
        Update ops= createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        return getDatastore().findAndModify(query,ops,new FindAndModifyOptions().returnNew(true),getEntityClass());
    }

    @Override
    public void updateUserOnline() {
        Document q = new Document("_id",new Document(MongoOperator.GT,1000));
        q.append("onlinestate", 1);
        Document values = new Document();
        values.put(MongoOperator.SET,new Document("onlinestate",0));
        getDatastore().getCollection(USER_DBNAME).updateMany(q, values);
    }

    @Override
    public User updateSettings(int userId, User.UserSettings userSettings){
        Query query = createQuery(userId);
        User user = findOne(query);
        Update ops = createUpdate();
        if (null != new Integer(userSettings.getAllowAtt()))
            ops.set("settings.allowAtt", userSettings.getAllowAtt());
        if (null != new Integer(userSettings.getAllowGreet()))
            ops.set("settings.allowGreet", userSettings.getAllowGreet());
        if (-1 != userSettings.getFriendsVerify())
            ops.set("settings.friendsVerify", userSettings.getFriendsVerify());
        //是否开启客服模式
        if (null!=new Integer(userSettings.getAllowAtt())) {
            ops.set("settings.openService", userSettings.getOpenService());
        }
        if (null!=new Integer(userSettings.getCloseTelephoneFind())) {
            ops.set("settings.closeTelephoneFind", userSettings.getCloseTelephoneFind());
        }
        if(!"0".equals(userSettings.getChatRecordTimeOut())){
            ops.set("settings.chatRecordTimeOut", userSettings.getChatRecordTimeOut());
        }
        if(0!=userSettings.getChatSyncTimeLen()){
            ops.set("settings.chatSyncTimeLen", userSettings.getChatSyncTimeLen());
            userCoreService.multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_PRIVATE_SETTINGS);
        }
        if(-1!=userSettings.getIsEncrypt()){
            ops.set("settings.isEncrypt", userSettings.getIsEncrypt());
            userCoreService.multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_PRIVATE_SETTINGS);
        }
        if(-1!=userSettings.getIsTyping()){
            ops.set("settings.isTyping", userSettings.getIsTyping());
            userCoreService.multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_PRIVATE_SETTINGS);
        }
        if(-1!=userSettings.getIsUseGoogleMap())
            ops.set("settings.isUseGoogleMap", userSettings.getIsUseGoogleMap());
        if(-1!=userSettings.getIsVibration()){
            ops.set("settings.isVibration", userSettings.getIsVibration());
            userCoreService.multipointLoginDataSync(userId, user.getNickname(), KConstants.MultipointLogin.SYNC_PRIVATE_SETTINGS);
        }
        if(-1!=userSettings.getMultipleDevices())
            ops.set("settings.multipleDevices", userSettings.getMultipleDevices());
        if(-1 != userSettings.getIsKeepalive())
            ops.set("settings.isKeepalive", userSettings.getIsKeepalive());
        if(-1 != userSettings.getPhoneSearch())
            ops.set("settings.phoneSearch", userSettings.getPhoneSearch());
        if(-1 != userSettings.getNameSearch())
            ops.set("settings.nameSearch", userSettings.getNameSearch());
        if(0 != userSettings.getShowLastLoginTime())
            ops.set("settings.showLastLoginTime", userSettings.getShowLastLoginTime());
        if(0 != userSettings.getShowTelephone())
            ops.set("settings.showTelephone", userSettings.getShowTelephone());
        if(null != userSettings.getFriendFromList())
            ops.set("settings.friendFromList", userSettings.getFriendFromList());
        if(null != userSettings.getFilterCircleUserIds())
            ops.set("settings.filterCircleUserIds", userSettings.getFilterCircleUserIds());
        if(null != userSettings.getNotSeeFilterCircleUserIds())
            ops.set("settings.notSeeFilterCircleUserIds", userSettings.getNotSeeFilterCircleUserIds());
        if(-1 != userSettings.getAuthSwitch())
            ops.set("settings.authSwitch",userSettings.getAuthSwitch());
        if(-1 != userSettings.getIsOpenPrivacyPosition()){
            if(1 == userSettings.getIsOpenPrivacyPosition()){
                if(1 == SKBeanUtils.getImCoreService().getClientConfig().getIsOpenPositionService()){
                    throw new ServiceException(KConstants.ResultCode.NOAUTHORITYOPENPOSITION);
                }
            }
            ops.set("settings.isOpenPrivacyPosition",userSettings.getIsOpenPrivacyPosition());
        }
        return getDatastore().findAndModify(query, ops,getEntityClass());
    }

    public User.UserSettings getUserSetting(Integer userId){
        Query query = createQuery("userId",userId);
        return getDatastore().findOne(query,User.UserSettings.class);
    }

    @Override
    public User updateUser(User user) {
        Query query = createQuery(user.getUserId());
        Update ops =createUpdate();
        if (!StringUtil.isNullOrEmpty(user.getTelephone())) {
            ops.set("userKey",Md5Util.md5Hex(user.getTelephone()));
            ops.set("telephone", user.getTelephone());
        }
        if (!StringUtil.isNullOrEmpty(user.getUsername()))
            ops.set("username", user.getUsername());

        if (null != user.getUserType())
            ops.set("userType", user.getUserType());

        if (!StringUtil.isNullOrEmpty(user.getName()))
            ops.set("name", user.getName());
        if (!StringUtil.isNullOrEmpty(user.getNickname()))
            ops.set("nickname", user.getNickname());
        if (!StringUtil.isNullOrEmpty(user.getDescription()))
            ops.set("description", user.getDescription());
        if (null != user.getBirthday())
            ops.set("birthday", user.getBirthday());
        if (null != user.getSex())
            ops.set("sex", user.getSex());

        if (null != user.getCountryId())
            ops.set("countryId", user.getCountryId());
        if (null != user.getProvinceId())
            ops.set("provinceId", user.getProvinceId());
        if (null != user.getCityId())
            ops.set("cityId", user.getCityId());
        if (null != user.getAreaId())
            ops.set("areaId", user.getAreaId());

        if (null != user.getLevel())
            ops.set("level", user.getLevel());
        if (null != user.getVip())
            ops.set("vip", user.getVip());

        ops.set("modifyTime", DateUtil.currentTimeSeconds());

        if (!StringUtil.isNullOrEmpty(user.getIdcard()))
            ops.set("idcard", user.getIdcard());
        if (!StringUtil.isNullOrEmpty(user.getIdcardUrl()))
            ops.set("idcardUrl", user.getIdcardUrl());

        if (null != user.getIsAuth())
            ops.set("isAuth", user.getIsAuth());
        if (null != user.getStatus())
            ops.set("status", user.getStatus());
        return getDatastore().findAndModify(query, ops,getEntityClass());
    }

    @Override
    public void updateUser(int userId, Map<String, Object> map) {
        Query query =createQuery(userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void updatePassword(String telephone, String password) {
        Query q = createQuery("telephone",telephone);
        Update ops = createUpdate();
        ops.set("password", password);
        update(q, ops);
    }

    @Override
    public void updatePassowrd(int userId, String password) {
        Query query =createQuery(userId);

        Update ops = createUpdate();
        ops.set("password", password);
        update(query, ops);
        // 更新redis中的数据
        userCoreRedisRepository.deleteUserByUserId(userId);
    }

    @Override
    public User.UserLoginLog queryUserLoginLog(int userId) {
        Query query = createQuery("_id",userId);
        User.UserLoginLog one = getDatastore().findOne(query, User.UserLoginLog.class);
        return one;
    }

    @Override
    public void updateLoc(int userId, User.Loc loc) {
        Update ops = createUpdate();
        ops.set("active", DateUtil.currentTimeSeconds());
        ops.set("loc", loc);
        updateAttributeByOps(userId, ops);
    }

    @Override
    public void saveIosAppId(int userId, String appId) {
        Query query = createQuery("_id",userId);
        Update ops = createUpdate();
        try {
            ops.set("deviceMap."+KConstants.DeviceKey.IOS+".appId",appId);

            getDatastore().updateFirst(query, ops,User.UserLoginLog.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void updateDeviceMap(int userId, String devicekey) {
        Query query = createQuery("_id",userId);
        Update ops = createUpdate();
        ops.set("loginLog.offlineTime",DateUtil.currentTimeSeconds());
        if(!StringUtil.isEmpty(devicekey))	{
            ops.set("deviceMap."+devicekey+".pushServer","");
            ops.set("deviceMap."+devicekey+".pushToken","");
        }

        getDatastore().updateFirst(query, ops,User.UserLoginLog.class);
    }

    @Override
    public List<Integer> getAllUserId() {
        return getDatastore().findDistinct(createQuery(), "_id", getEntityClass(), Integer.class);
    }

    @Override
    public void updateUserOfflineTime(int userId) {
        Query query=createQuery(userId);
        User.UserLoginLog loginLog = getDatastore().findOne(query,User.UserLoginLog.class);
        if(null==loginLog)
            return;
        if(null==loginLog.getLoginLog())
            return;
        Update ops = createUpdate();
        ops.set("loginLog.offlineTime",DateUtil.currentTimeSeconds());
        getDatastore().findAndModify(query, ops,User.UserLoginLog.class);
    }

    @Override
    public Double updateUserBalanceSafe(Integer userId,double balance) {
        Query query =createQuery(userId);
        Update ops =createUpdate();
        ops.set("balanceSafe", MoneyUtils.encrypt(balance,userId.toString()));

        update(query, ops);
        userCoreRedisRepository.deleteUserByUserId(userId);
        return balance;
    }

    @Override
    public User updateOfflineNoPushMsg(Integer userId, int OfflineNoPushMsg) {
        Query query=createQuery(userId);
        Update ops = createUpdate();
        ops.set("offlineNoPushMsg", OfflineNoPushMsg);
        return getDatastore().findAndModify(query, ops,getEntityClass());
    }

    @Override
    public Integer createUserId(Integer userId) {
        MongoCollection<Document> collection=getDatastore().getCollection("idx_user");
        Document obj=collection.find().first();
        if(null==obj)
            return createIdxUserCollection(collection,0);
        if(null!=userId){
            collection.updateOne(new Document("_id", obj.get("_id")),
                    new Document(MongoOperator.SET, new Document("id", userId)));
            return userId;
        }else{
            userId= (Integer)obj.get("id");
            userId+=1;
            collection.updateOne(new Document("_id", obj.get("_id")),
                    new Document(MongoOperator.SET, new Document("id", userId)));
            return userId;
        }
    }

    @Override
    public Integer createCall() {
        /*MongoCollection<Document> collection=getDatastore().getCollection("idx_user");
        if(null==collection){
            return createIdxUserCollection(collection,0);
        }
        Document obj=collection.find().first();
        if(null!=obj){
            if(obj.get("call")==null){
                obj.put("call", 300000);
            }
            Integer call=new Integer(obj.get("call").toString());
            call+=1;
            if(call>349999){
                call=300000;
            }
            collection.updateOne(new Document("_id", obj.get("_id")),new Document(MongoOperator.SET, new BasicDBObject("call", call)));
            return call;
        }else{
            return createIdxUserCollection(collection,0);
        }*/
        return 0;
    }

    @Override
    public Integer createvideoMeetingNo() {
       /* MongoCollection<Document> collection=getDatastore().getCollection("idx_user");
        if(null==collection){
            return createIdxUserCollection(collection,0);
        }
        Document obj=collection.find().first();
        if(null!=obj){
            if(obj.get("videoMeetingNo")==null){
                obj.put("videoMeetingNo",350000);
            }
            Integer videoMeetingNo=new Integer(obj.get("videoMeetingNo").toString());
            videoMeetingNo+=1;
            if(videoMeetingNo>399999){
                videoMeetingNo=350000;
            }
            collection.updateOne(new Document("_id",obj.get("_id")),new Document(MongoOperator.SET, new Document("videoMeetingNo", videoMeetingNo)));
            return videoMeetingNo;
        }else{
            return createIdxUserCollection(collection,0);
        }*/
        return 0;
    }

    @Override
    public Integer createInviteCodeNo(int createNum) {
        MongoCollection<Document> collection = getDatastore().getCollection("idx_user");
        if(null==collection) {
            createIdxUserCollection(collection,0);
        }
        Document obj = collection.find().first();
        if(null!=obj){
            if(obj.get("inviteCodeNo")==null){
                obj.put("inviteCodeNo",1001);
            }
        }else {
            createIdxUserCollection(collection,0);
        }

        Integer inviteCodeNo = new Integer(obj.get("inviteCodeNo").toString());
        //inviteCodeNo += 1;
        collection.updateOne(new Document("_id", obj.get("_id")),
                new Document(MongoOperator.INC, new Document("inviteCodeNo", createNum)));
        return inviteCodeNo;
    }


    //初始化自增长计数表数据
    private Integer createIdxUserCollection(MongoCollection collection,long userId){
        if(null==collection)
            collection=getDatastore().createCollection("idx_user");
        Document init=new Document();
        Integer id=getMaxUserId();
        if(0==id||id<KConstants.MIN_USERID)
            id=new Integer(KConstants.MIN_USERID);
        id+=1;
        init.append("id", id);
        init.append("stub","id");
        init.append("call",300000);
        init.append("videoMeetingNo",350000);
        init.append("inviteCodeNo",1001);
        collection.insertOne(init);
        return id;
    }

    public Integer getMaxUserId(){
        Document projection=new Document("_id", 1);
        Document dbobj=getDatastore().getCollection("user").find().projection(projection).sort(new Document("_id", -1)).first();
        if(null==dbobj)
            return 0;
        Integer id=new Integer(dbobj.get("_id").toString());
        return id;
    }

    @Override
    public Integer getServiceNo(String areaCode) {
        MongoCollection<Document> collection=getDatastore().getCollection("sysServiceNo");
        Document obj= collection.find(new Document("areaCode", areaCode)).first();
        if(null!=obj)
            return obj.getInteger("userId");
        return createServiceNo(areaCode);
    }

    //创建系统服务号
    private Integer createServiceNo(String areaCode){
        MongoCollection<Document> collection=getDatastore().getCollection("sysServiceNo");
        Integer userId=getMaxServiceNo()+1;
        Document value=new Document("areaCode", areaCode);
        value.append("userId", userId);
        collection.insertOne(value);
        addUser(userId, Md5Util.md5Hex(userId+""));
        return userId;
    }

    //获取系统最大客服号
    private Integer getMaxServiceNo(){
        MongoCollection<Document> collection=getDatastore().getCollection("sysServiceNo");
        Document obj= collection.find(new Document()).projection(new Document("userId", 1)).sort(new Document("userId", -1)).first();
        if(null!=obj){
            return obj.getInteger("userId");
        }else{
            Document query=new Document("_id",new Document(MongoOperator.LT, 10200));
            query.append("_id",new BasicDBObject(MongoOperator.GT, 10200));
            Document projection=new Document("_id", 1);
            Document dbobj=getDatastore().getCollection(USER_DBNAME).find(query).projection(projection).sort(new Document("_id", -1)).first();
            if(null==dbobj)
                return 10200;
            Integer id=new Integer(dbobj.get("_id").toString());
            return id;
        }
    }

    @Override
    public List<Object> getUserRegisterCount(long startTime, long endTime,String mapStr,String reduce) {
        List<Object> countData = new ArrayList<>();
        Document queryTime = new Document("$ne",null);

        if(startTime!=0 && endTime!=0){
            queryTime.append("$gt", startTime);
            queryTime.append("$lt", endTime);
        }

        Document query = new Document("createTime",queryTime);

        //获得用户集合对象
        MongoCollection<Document> collection = getDatastore().getCollection(USER_DBNAME);
        MongoCursor<Document> iterator = collection.mapReduce(mapStr, reduce).filter(query).iterator();
        Map<String,Double> map = new HashMap<>();
        while (iterator.hasNext()) {
            Document obj =  iterator.next();

            map.put((String)obj.get("_id"),(Double)obj.get("value"));
            countData.add(JSON.toJSON(map));
            map.clear();

        }

        return countData;
    }

    @Override
    public List<Object> getUserOnlineStatusCount(long startTime, long endTime, short timeUnit, String mapStr, String reduce) {
        List<Object> countData = new ArrayList<>();
        Document queryTime = new Document("$ne",null);

        if(startTime!=0 && endTime!=0){
            queryTime.append("$gte", startTime);
            queryTime.append("$lt", endTime);
        }

        //用户在线采样标识, 对应 UserStatusCount 表的type 字段     1零时统计   2:小时统计   3:天数统计
        short  minute_sampling = 1, hour_sampling = 2, day_sampling = 3;

        Document queryType = new Document("$eq",day_sampling); //默认筛选天数据

        if(1 == timeUnit){ //月数据
            queryType.append("$eq",day_sampling);
        }else if(2 == timeUnit) {//天数据
            queryType.append("$eq",day_sampling);
        }else if(timeUnit == 3) {//小时数据
            queryType.append("$eq",hour_sampling);
        }else if(timeUnit == 4) {//分钟数据
            queryType.append("$eq", minute_sampling);
        }

        Document query = new Document("time",queryTime).append("type", queryType);

        //获得用户集合对象
        MongoCollection<Document> collection = getDatastore().getCollection(getCollectionName(UserStatusCount.class));

        MongoCursor<Document> iterator = collection.mapReduce(mapStr, reduce).filter(query).iterator();
        Map<String,Object> map = new HashMap<String,Object>();
        while (iterator.hasNext()) {
            Document obj =  iterator.next();

            map.put((String)obj.get("_id"),obj.get("value"));
            countData.add(JSON.toJSON(map));
            map.clear();

        }

        return countData;
    }

    @Override
    public List<User> getUserlimit(int pageIndex, int pageSize, int isAuth) {
        Query query = createQuery();

        if (1 == isAuth) {
            addToQuery(query,"isAuth",isAuth);
        }
        descByquery(query,"createTime"); // 按创建时间降序排列
        return queryListsByQuery(query,pageIndex,pageSize);
    }



    @Override
    public List<User> getNearbyUser(NearbyUser model, Integer userId, int telephoneSearchUser, int nicknameSearchUser) {
        List<User> data = Lists.newArrayList();
        Query query = createQuery();
        int distance = model.getDistance();
        Double d = 0d;
        if (0 == distance){
            distance = ConstantUtil.getAppDefDistance();
        }
        // 0.180180180.....
        //d = distance / KConstants.LBS_KM;

        Criteria idCriter = Criteria.where("_id").gt(100050);
        //排除系统号


        if (0 != model.getLatitude() && 0 != model.getLongitude()){
            query.addCriteria(Criteria.where("loc").within(
               new Circle(new Point(model.getLongitude(),model.getLatitude()),new Distance(distance, Metrics.KILOMETERS)))
            );

            // 附近的人排除自己
            idCriter.ne(userId);

        }
        query.addCriteria(idCriter);

        if (!StringUtil.isEmpty(model.getNickname())) {
            if (0 == telephoneSearchUser) { //手机号搜索关闭

                if(0 == nicknameSearchUser) { //昵称搜索关闭
                    addToQuery(query,"account",model.getNickname());
                }else if(1 == nicknameSearchUser) { //昵称精准搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            Criteria.where("nickname").is(model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);

                }else if(2 == nicknameSearchUser) { //昵称模糊搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            containsIgnoreCase("nickname",model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);
                }

            }else if(1 == telephoneSearchUser){ //手机号精确搜索
                if(0 == nicknameSearchUser) { //昵称搜索关闭
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            Criteria.where("phone").is(model.getNickname()).and("settings.phoneSearch").ne(0)
                    );
                    query.addCriteria(criteria);

                }else if(1 == nicknameSearchUser) { //昵称精准搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            Criteria.where("phone").is(model.getNickname()).and("settings.phoneSearch").ne(0),
                            Criteria.where("nickname").is(model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);

                }else if(2 == nicknameSearchUser) { //昵称模糊搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            Criteria.where("phone").is(model.getNickname()).and("settings.phoneSearch").ne(0),
                            containsIgnoreCase("nickname",model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);

                }

            }else if(2 == telephoneSearchUser){ //手机号模糊搜索

                if(0 == nicknameSearchUser) { //昵称搜索关闭
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            containsIgnoreCase("phone",model.getNickname()).and("settings.phoneSearch").ne(0)
                    );
                    query.addCriteria(criteria);


                }else if(1 == nicknameSearchUser) { //昵称精准搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            Criteria.where("phone").is(model.getNickname()).and("settings.phoneSearch").ne(0),
                            Criteria.where("nickname").is(model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);

                }else if(2 == nicknameSearchUser) { //昵称模糊搜索
                    Criteria criteria = createCriteria().orOperator(
                            Criteria.where("account").is(model.getNickname()),
                            containsIgnoreCase("phone",model.getNickname()).and("settings.phoneSearch").ne(0),
                            containsIgnoreCase("nickname",model.getNickname()).and("settings.nameSearch").ne(0)
                    );
                    query.addCriteria(criteria);
                }

            }
        }else if(0 == model.getLatitude() && 0 == model.getLongitude()) { //搜索关键字为空，且坐标没传的情况下不返回数据
            return data;
        }

        if (null != model.getUserId()) {
            addToQuery(query,"_id",model.getUserId());
        }
        if (null != model.getSex()) {
            addToQuery(query,"sex",model.getSex());
        }
        if (null != model.getActive() && 0 != model.getActive()) {
            long seconds = DateUtil.currentTimeSeconds();
            query.addCriteria(
                    Criteria.where("active").
                    gt(seconds - model.getActive() * 86400000).lt(seconds)
            );

        }

        query.fields().include("sex")
                .include("account")
                .include("nickname")
                .include("loc")
                .include("createTime");


        return queryListsByQuery(query,model.getPageIndex(),model.getPageSize());
    }

    @Override
    public void deleteUserById(Integer userId) {
        deleteById(userId);
    }

//    @Override
//    public List<OfflineOperation> getOfflineOperation(Integer userId, long startTime) {
//        Query<OfflineOperation> query = getDatastore().createQuery(OfflineOperation.class);
//        query.field("userId").equal(userId).field("operationTime").greaterThanOrEq(startTime);
//        return query.asList();
//    }


    @Override
    public long getAllUserCount() {

        return count();
    }

    @Override
    public Object getOneFieldById(String key, int userId) {
        return queryOneFieldById(key,userId);
    }


    @Override
    public User.LoginDevices getLoginDevices(int userId) {
        Query query = createQuery("userId",userId);
        return getDatastore().findOne(query,User.LoginDevices.class);
    }

    @Override
    public void addLoginDevices(User.LoginDevices loginDevices) {
        getDatastore().save(loginDevices);
    }

    @Override
    public List<User> exprotExcelPhone(long startTime, long endTime, String onlinestate, String keyWord) {
        Query query = createQuery();
        if (!StringUtil.isEmpty(onlinestate)) {
            addToQuery(query,"onlinestate", Integer.valueOf(onlinestate));
        }
        if (!StringUtil.isEmpty(keyWord)) {
            // Integer 最大值2147483647
            boolean flag = NumberUtil.isNum(keyWord);
            if(flag){
                Integer length = keyWord.length();
                if(length > 9){
                    Criteria criteria = createCriteria().orOperator(
                            containsIgnoreCase("nickname", keyWord),
                            containsIgnoreCase("telephone", keyWord));
                    query.addCriteria(criteria);
                }else{
                    Criteria criteria = createCriteria().orOperator(
                            containsIgnoreCase("nickname", keyWord),
                            containsIgnoreCase("telephone", keyWord),
                            Criteria.where("_id").is(Integer.valueOf(keyWord)));
                    query.addCriteria(criteria);

                }
            }else{
                Criteria criteria = createCriteria().orOperator(
                        containsIgnoreCase("nickname", keyWord),
                        containsIgnoreCase("telephone", keyWord));
                query.addCriteria(criteria);

            }
        }
        if(startTime !=0 && endTime !=0){

            query.addCriteria(Criteria.where("createTime").gt(startTime).lte(endTime));
        }
        return  queryListsByQuery(query);
    }

    @Override
    public void savePushToken(Integer userId, User.DeviceInfo info) {
        Query query1=createQuery();
        addToQuery(query1,"pushServer", info.getPushServer());
        addToQuery(query1,"pushToken", info.getPushToken());
        addToQuery(query1,"deviceKey", info.getDeviceKey());
        PushInfo pushInfo = getDatastore().findOne(query1,PushInfo.class);
        if(null!=pushInfo) {
            if(!userId.equals(pushInfo.getUserId())) {
                cleanPushToken(pushInfo.getUserId(), info.getDeviceKey());
                Update ops = createUpdate();
                ops.set("userId",userId);
                ops.set("time", DateUtil.currentTimeSeconds());
                update(query1, ops);
            }else {
                Update ops =createUpdate();
                ops.set("time", DateUtil.currentTimeSeconds());
               getDatastore().updateFirst(query1, ops,PushInfo.class);
            }
        }else {
            pushInfo=new PushInfo();
            pushInfo.setUserId(userId);
            pushInfo.setPushServer(info.getPushServer());
            pushInfo.setPushToken(info.getPushToken());
            pushInfo.setDeviceKey(info.getDeviceKey());
            pushInfo.setTime(DateUtil.currentTimeSeconds());
            getDatastore().save(pushInfo);
        }

        Query query=createQuery("_id", userId);
        Update ops = createUpdate();
        try {
            if(!StringUtil.isEmpty(info.getDeviceKey()))	{
                ops.set("deviceMap."+info.getDeviceKey()+".pushServer",info.getPushServer());
                ops.set("deviceMap."+info.getDeviceKey()+".pushToken",info.getPushToken());
            }
            if(KConstants.DeviceKey.IOS.equals(info.getDeviceKey())) {
                if(!StringUtil.isEmpty(info.getAppId()))
                    ops.set("deviceMap."+info.getDeviceKey()+".appId",info.getAppId());
            }
           getDatastore().updateFirst(query, ops, User.UserLoginLog.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<User> queryPublicUser(int page, int limit, String keyWorld) {
        Query query =createQuery("userType", 2);
        if (null!=keyWorld&&keyWorld.length()>0) {
            // 是否为数字
            if(StringUtil.isNumeric(keyWorld)){
                if(keyWorld.length()<9){
                    int userId = Integer.valueOf(keyWorld);
                    Criteria criteria = createCriteria().orOperator(Criteria.where("_id").is(userId),
                            containsIgnoreCase("nickname", keyWorld));
                    query.addCriteria(criteria);
                }else{
                    Criteria criteria = createCriteria().orOperator(containsIgnoreCase("telephone", keyWorld),
                            containsIgnoreCase("nickname", keyWorld));
                    query.addCriteria(criteria);

                }

            }else if(StringUtil.isEscapeChar(keyWorld)){
                // 特殊字符开头 .*+ 会导致异常，这里做一下特殊处理
                keyWorld = keyWorld.replaceAll("^[+*.](.*?)","");
                if(StringUtil.isEmpty(keyWorld)){
                    return new ArrayList<>();
                }
                query.addCriteria(containsIgnoreCase("nickname",keyWorld));
            }else{
                query.addCriteria(containsIgnoreCase("nickname",keyWorld));
            }
        }
        List<User> list = queryListsByQuery(query,page,limit);
        System.out.println(list.size()+" ===== ");
        return list;
    }

    @Override
    public List<User> findUserList(int pageIndex, int pageSize, Integer notId) {
        Query query = createQuery();
        List<Integer> ids = new ArrayList<Integer>() {{
            add(10000);
            add(10005);
            add(10006);
            add(notId);
        }};
        query.addCriteria(Criteria.where("_id").nin(ids));
        descByquery(query, "_id");
        return queryListsByQuery(query, pageIndex, pageSize);
    }

    public void cleanPushToken(Integer userId, String devicekey) {

        try {
            if(KConstants.DeviceKey.Android.equals(devicekey)){
                userCoreRedisRepository.removeAndroidPushToken(userId);
            }else if (KConstants.DeviceKey.IOS.equals(devicekey)) {
                userCoreRedisRepository.removeIosPushToken(userId);
            }
            updateDeviceMap(userId,devicekey);
        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    @Override
    public void updateIpInfo(int userId, User.IpInfo ipInfo) {
        Update ops = createUpdate();
        ops.addToSet("ipInfo", ipInfo);
        updateAttributeByOps(userId, ops);
    }
}

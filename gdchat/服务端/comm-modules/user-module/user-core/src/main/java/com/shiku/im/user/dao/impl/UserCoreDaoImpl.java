package com.shiku.im.user.dao.impl;


import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;
import com.mongodb.BasicDBObject;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.repository.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.UserCoreDao;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.utils.MoneyUtils;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.Md5Util;
import com.shiku.utils.StringUtil;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository(value = "userCoreDao")
public class UserCoreDaoImpl extends MongoRepository<User, Integer> implements UserCoreDao {

    private final String USER_DBNAME="user";


    @Autowired(required = false)
    private UserCoreRedisRepository userCoreRedisRepository;




    @Override
    public Class<User> getEntityClass() {
        return User.class;
    }


    @Override
    public void addUser(User user) {
        getDatastore().save(user);
    }





    @Override
    public List<User> findByTelephone(List<String> telephoneList) {
        Query query = createQuery();
        query.addCriteria(Criteria.where("telephone").in(telephoneList));

        return queryListsByQuery(query);
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
    public Double updateUserBalanceSafe(Integer userId,double balance) {
        Query query =createQuery(userId);
        Update ops =createUpdate();
        ops.set("balanceSafe", MoneyUtils.encrypt(balance,userId.toString()));

        update(query, ops);
        userCoreRedisRepository.deleteUserByUserId(userId);
        return balance;
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
    public List<User> getUserlimit(int pageIndex, int pageSize, int isAuth) {
        Query query = createQuery();

        if (1 == isAuth) {
            addToQuery(query,"isAuth",isAuth);
        }
        descByquery(query,"createTime"); // 按创建时间降序排列
        return queryListsByQuery(query,pageIndex,pageSize);
    }



    @Override
    public void deleteUserById(Integer userId) {
        deleteById(userId);
    }




    @Override
    public long getAllUserCount() {

        return count();
    }

    @Override
    public Object getOneFieldById(String key, int userId) {
        return queryOneFieldById(key,userId);
    }

    @Override
    public User updateSettings(int userId, User.UserSettings userSettings) {
        Query query = createQuery(userId);
        User user = findOne(query);
        Update ops = createUpdate();
        if (-1 != userSettings.getAllowAtt()) {
            ops.set("settings.allowAtt", userSettings.getAllowAtt());
        }
        if (-1 != userSettings.getAllowGreet()) {
            ops.set("settings.allowGreet", userSettings.getAllowGreet());
        }
        if (-1 != userSettings.getFriendsVerify()) {
            ops.set("settings.friendsVerify", userSettings.getFriendsVerify());
        }
        //是否开启客服模式
        if (-1 != userSettings.getOpenService()) {
            ops.set("settings.openService", userSettings.getOpenService());
        }
        if (-1 != userSettings.getCloseTelephoneFind()) {
            ops.set("settings.closeTelephoneFind", userSettings.getCloseTelephoneFind());
        }
        if (!"0".equals(userSettings.getChatRecordTimeOut())) {
            ops.set("settings.chatRecordTimeOut", userSettings.getChatRecordTimeOut());
        }
        if (0 != userSettings.getChatSyncTimeLen()) {
            ops.set("settings.chatSyncTimeLen", userSettings.getChatSyncTimeLen());
        }
        if (-1 != userSettings.getIsEncrypt()) {
            ops.set("settings.isEncrypt", userSettings.getIsEncrypt());
        }
        if (-1 != userSettings.getIsTyping()) {
            ops.set("settings.isTyping", userSettings.getIsTyping());
        }
        if (-1 != userSettings.getIsUseGoogleMap())
            ops.set("settings.isUseGoogleMap", userSettings.getIsUseGoogleMap());
        if (-1 != userSettings.getIsVibration()) {
            ops.set("settings.isVibration", userSettings.getIsVibration());
        }
        if (-1 != userSettings.getMultipleDevices()) {
            ops.set("settings.multipleDevices", userSettings.getMultipleDevices());
        }
        if (-1 != userSettings.getIsKeepalive()) {
            ops.set("settings.isKeepalive", userSettings.getIsKeepalive());
        }
        if (-1 != userSettings.getPhoneSearch()) {
            ops.set("settings.phoneSearch", userSettings.getPhoneSearch());
        }
        if (-1 != userSettings.getNameSearch()) {
            ops.set("settings.nameSearch", userSettings.getNameSearch());
        }
        if (0 != userSettings.getShowLastLoginTime()) {
            ops.set("settings.showLastLoginTime", userSettings.getShowLastLoginTime());
        }
        if (0 != userSettings.getShowTelephone()) {
            ops.set("settings.showTelephone", userSettings.getShowTelephone());
        }
        if (null != userSettings.getFriendFromList()) {
            ops.set("settings.friendFromList", userSettings.getFriendFromList());
        }
        if (null != userSettings.getFilterCircleUserIds()) {
            ops.set("settings.filterCircleUserIds", userSettings.getFilterCircleUserIds());
        }
        if (null != userSettings.getNotSeeFilterCircleUserIds()) {
            ops.set("settings.notSeeFilterCircleUserIds", userSettings.getNotSeeFilterCircleUserIds());
        }
        if (-1 != userSettings.getAuthSwitch()) {
            ops.set("settings.authSwitch", userSettings.getAuthSwitch());
        }
        if (-1 != userSettings.getIsOpenPrivacyPosition()) {
            if (1 == userSettings.getIsOpenPrivacyPosition()) {
                if (1 == SKBeanUtils.getImCoreService().getClientConfig().getIsOpenPositionService()) {
                    throw new ServiceException(KConstants.ResultCode.NOAUTHORITYOPENPOSITION);
                }
            }
            ops.set("settings.isOpenPrivacyPosition", userSettings.getIsOpenPrivacyPosition());
        }
        if (-1 != userSettings.getIsSkidRemoveHistoryMsg())
            ops.set("settings.isSkidRemoveHistoryMsg", userSettings.getIsSkidRemoveHistoryMsg());
        if (-1 != userSettings.getIsShowMsgState()) {
            ops.set("settings.isShowMsgState", userSettings.getIsShowMsgState());
        }
        return getDatastore().findAndModify(query, ops, getEntityClass());
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



}

package com.shiku.im.user.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.user.entity.AuthKeys;
import com.shiku.im.user.entity.Emoji;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.model.UserLoginTokenKey;
import com.shiku.redisson.AbstractRedisson;
import org.redisson.api.RBucket;
import org.redisson.api.RList;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service(value ="userRedisService" )
public class UserRedisService extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }

    @Autowired(required=false)
    public UserCoreRedisRepository userCoreRedis;

    @Lazy
    @Autowired(required=false)
    public UserHandler userHandler;

    /**
     * 用户名
     */
    public static final String STATIC_NICKNAME="static:nickname:%s";

    public static final String GET_USER_BY_ACCOUNT = "user:account:%s";


    /**
     * 用户在线状态
     */
    public static final String USER_ONLINE="user_online:%s";

    /**
     * 用户的收藏列表
     */
    public static final String USER_COLLECT_COMMON="user_collect:common:%s";

    /**
     * 用户的自定义表情列表
     */
    public static final String USER_COLLECT_EMOTICON="user_collect:emoticon:%s";

    /**
     * 设备授权
     */
    public static final String AUTH_KEY = "authKey:%s";




    //public static final String AUTH_KEY = "authKey:%s:%s";



    /**
     * 用户随机码 key
     */
    public static final String USER_RANDOM_STR_KEY = "userRandomStr:%s";

    public static final String QRCODE_KEY = "qrCodeKey:%s";



    /**
     * 保存二维码对应的key
     * @param qrCodeKey
     * @param map
     */
    public void saveQRCodeKey(String qrCodeKey, Map<String, String> map){
        String key = String.format(QRCODE_KEY, qrCodeKey);
        RBucket<Object> rbBucket = redissonClient.getBucket(key);
        rbBucket.set(map, 120, TimeUnit.SECONDS);
    }



    /**
     * 通过key获取数据
     */
    public Object queryQRCodeKey(String qrCodeKey){
        String key = String.format(QRCODE_KEY, qrCodeKey);
        RBucket<Object> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }



    /*
     * 缓存用户在线状态
     */
    public void saveUserNickName(String userId,String nickName) {
        String key = String.format(STATIC_NICKNAME,userId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        if(!StringUtil.isEmpty(nickName))
            bucket.set(nickName, KConstants.Expire.DAY1, TimeUnit.SECONDS);
        bucket.deleteAsync();
    }
    public String queryUserNickName(Integer userId) {
        String key = String.format(STATIC_NICKNAME,userId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    /*
     * 通讯好 查询用户
     */
    public User queryUserByAccount(String account) {
        String key = String.format(GET_USER_BY_ACCOUNT, account);
        RBucket<User> bucket = redissonClient.getBucket(key);
        return bucket.get();

    }
    public  void saveUserByAccount(String account,User user) {
        String key = String.format(GET_USER_BY_ACCOUNT, account);
        RBucket<User> bucket = redissonClient.getBucket(key);
        bucket.setAsync(user, KConstants.Expire.HOUR12, TimeUnit.SECONDS);

    }
    public  void deleteUserByAccount(String account) {
        String key = String.format(GET_USER_BY_ACCOUNT, account);
        RBucket<User> bucket = redissonClient.getBucket(key);
        bucket.deleteAsync();
    }

    /*
     * 缓存用户在线状态
     */
    public void saveUserOnline(String userId,int status) {
        String key = String.format(USER_ONLINE,userId);
        RBucket<Integer> bucket = redissonClient.getBucket(key);
        if(1==status)
            bucket.set(1, KConstants.Expire.DAY1*2, TimeUnit.SECONDS);
        else
            bucket.deleteAsync();
    }
    public int queryUserOnline(Integer userId) {
        String key = String.format(USER_ONLINE,userId);
        RBucket<Integer> bucket = redissonClient.getBucket(key);
        if(bucket.isExists())
            return 1;
        return 0;
    }


    /**
     * 保存用戶随机码
     */
    public void saveUserRandomStr(int userId,String userRandomStr){
        RBucket<String> bucket = redissonClient.getBucket(String.format(USER_RANDOM_STR_KEY, userId));
        bucket.set(userRandomStr,KConstants.Expire.HOUR,TimeUnit.SECONDS); //有效期一小时
    }

    /**
     * 获取用户随机码
     */
    public String getUserRandomStr(int userId){
        RBucket<String> bucket = redissonClient.getBucket(String.format(USER_RANDOM_STR_KEY, userId));
        return bucket.get();
    }
    /**
     * 删除用户随机码
     */
    public boolean deleteUserRandomStr(int userId){
        RBucket<String> bucket = redissonClient.getBucket(String.format(USER_RANDOM_STR_KEY, userId));
        return bucket.delete();
    }


    public static final String AUTHKEYS_KEY = "authkeys:%s";

    public AuthKeys getAuthKeys(int userId){
        String key = String.format(AUTHKEYS_KEY, userId);
        RBucket<AuthKeys> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public AuthKeys saveAuthKeys(int userId,AuthKeys authKeys){
        String key = String.format(AUTHKEYS_KEY, userId);
        RBucket<AuthKeys> bucket = redissonClient.getBucket(key);
        bucket.set(authKeys,KConstants.Expire.DAY1,TimeUnit.SECONDS);
        return bucket.get();
    }


    public void savaAuthKey(String authKey , Map<String, Object> mapResultStatus){
        String key = String.format(AUTH_KEY, authKey);
        RBucket<Object> rbBucket = redissonClient.getBucket(key);
        rbBucket.set(mapResultStatus, 5, TimeUnit.MINUTES);
    }


    public boolean deleteAuthKeys(int userId){
        String key = String.format(AUTHKEYS_KEY, userId);
        RBucket<AuthKeys> bucket = redissonClient.getBucket(key);
        return bucket.delete();
    }
    public static final String LOGINCODES_KEY = "LOGINCODES:%s";

    /**
     * @param userId
     * @param code
     */
    public void saveLoginCode(int userId,String deviceId,String code){
        String key = String.format(LOGINCODES_KEY, userId,deviceId);
        RBucket<Object> rbucket = redissonClient.getBucket(key);
        rbucket.set(code,KConstants.Expire.MINUTE, TimeUnit.SECONDS);
    }

    /**
     * @param userId
     * @param code
     * @return
     */
    public String queryLoginSignCode(int userId,String deviceId){
        String key = String.format(LOGINCODES_KEY, userId,deviceId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public boolean cleanLoginCode(int userId,String deviceId){
        String key = String.format(LOGINCODES_KEY, userId,deviceId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return bucket.delete();
    }

    /**
     *
     */
    public static final String GET_LOGIN_TOKEN_KEY = "login:loginToken:%s:%s";

    public static final String LOGIN_TOKEN_KEY = "login:loginTokenKeys:%s";


    /**
     * 根据 userId 和设备号保存  登陆token
     * @param userId
     * @param deviceId
     * @param loginToken  登陆token  用于自动登陆使用
     */
    private void saveLoginToken(int userId, String deviceId,String loginToken){
        String key = String.format(GET_LOGIN_TOKEN_KEY, userId,deviceId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        String oldToken=bucket.get();
        /**
         * 上次登陆的  信息 需要清空
         */
        if(!StringUtil.isEmpty(oldToken)){
            cleanLoginTokenKeys(oldToken);
        }

		/*UserLoginTokenKey oldLoginToken = bucket.get();
		if(null!=oldLoginToken){
			cleanLoginTokenKeys(oldLoginToken.getLoginToken());
		}*/
        bucket.set(loginToken,KConstants.Expire.DAY7*7,TimeUnit.SECONDS);
    }
    public String queryLoginToken(int userId, String deviceId){
        String key = String.format(GET_LOGIN_TOKEN_KEY, userId,deviceId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        return  bucket.get();
    }
    public boolean cleanLoginToken(int userId, String deviceId){
        String key = String.format(GET_LOGIN_TOKEN_KEY, userId,deviceId);
        RBucket<String> bucket = redissonClient.getBucket(key);
        cleanLoginTokenKeys(bucket.get());
        return bucket.delete();
    }
    /**
     * 根据 loginToken  保存 登陆信息  用于自动登陆使用
     * @param loginKey
     */
    public void saveLoginTokenKeys(UserLoginTokenKey loginKey){
        String key = String.format(LOGIN_TOKEN_KEY,loginKey.getLoginToken());
        RBucket<UserLoginTokenKey> bucket = redissonClient.getBucket(key);

        bucket.set(loginKey,KConstants.Expire.DAY7*7,TimeUnit.SECONDS);
        saveLoginToken(loginKey.getUserId(),loginKey.getDeviceId(),loginKey.getLoginToken());
    }

    public UserLoginTokenKey queryLoginTokenKeys(String loginToken){
        String key = String.format(LOGIN_TOKEN_KEY, loginToken);
        RBucket<UserLoginTokenKey> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }
    public boolean cleanLoginTokenKeys(String loginToken){
        if(StringUtil.isEmpty(loginToken))
            return true;
        String key = String.format(LOGIN_TOKEN_KEY,loginToken);
        RBucket bucket = redissonClient.getBucket(key);
        return bucket.delete();
    }

    public static final String GET_SESSON_KEY = "sesson:%s";
    public void saveUserSesson(KSession session){
        String key = String.format(GET_SESSON_KEY,session.getAccessToken());
        RBucket<KSession> bucket = redissonClient.getBucket(key);
        bucket.set(session,KConstants.Expire.DAY1*30,TimeUnit.SECONDS);
        saveMessageKey(session.getUserId(),session.getDeviceId(),session.getMessageKey());
    }
    public KSession queryUserSesson(String accessToken){
        String key = String.format(GET_SESSON_KEY,accessToken);
        RBucket<KSession> bucket = redissonClient.getBucket(key);
        return bucket.get();

    }
    public boolean cleanUserSesson(String accessToken){
        KSession session = queryUserSesson(accessToken);
        if(null!=session) {
            cleanMessageKey(session.getUserId(), session.getDeviceId());
            userCoreRedis.removeAccessTokenByDeviceId(session.getUserId(),session.getDeviceId());
        }
        userHandler.clearUserSessionHandler(accessToken);
        return deleteBucket(GET_SESSON_KEY,accessToken);
    }


    public static final String USER_TOKENKEYS = "loginToken:token:%s:*";
    /**
     * 清除一个用户的所有登陆信息  包括 loginKey
     * @param userId
     * @return
     */
    public boolean cleanUserAllLoginInfo(int userId){
        String patternKey=buildRedisKey(USER_TOKENKEYS,userId);
        redissonClient.getKeys().getKeysStreamByPattern(patternKey)
                .forEach(key->{
                    String token =(String) redissonClient.getBucket(key).get();
                    KSession session = queryUserSesson(token);
                    if(null!=session) {
                        cleanLoginToken(session.getUserId(),session.getDeviceId());
                        cleanMessageKey(session.getUserId(), session.getDeviceId());
                        userCoreRedis.removeAccessTokenByDeviceId(session.getUserId(),session.getDeviceId());
                    }
                    deleteBucket(GET_SESSON_KEY,token);
                });
        return  true;
    }

    /**
     * @Description:删除用户清除相关缓存信息
     * @param userId
     * @return
     *
     */
    public void cleanUserInfo(int userId){
        String patternKey=buildRedisKey(USER_TOKENKEYS,userId);
        redissonClient.getKeys().getKeysStreamByPattern(patternKey).forEach(key->{
                    String token =(String) redissonClient.getBucket(key).get();
                    KSession session = queryUserSesson(token);
                    if(null!=session) {
                        cleanLoginToken(session.getUserId(),session.getDeviceId());
                        cleanMessageKey(session.getUserId(), session.getDeviceId());
                        userCoreRedis.removeAccessTokenByDeviceId(session.getUserId(),session.getDeviceId());
                        cleanUserSesson(session.getAccessToken());
                        userCoreRedis.deleteUserByUserId(userId);
                    }
                    deleteBucket(GET_SESSON_KEY,token);
                });
    }

    public static final String GET_MESSAGEKEY_KEY = "messageKey:%s:%s";

    public void saveMessageKey(int userId,String deviceId,String messageKey){
        String key=buildRedisKey(GET_MESSAGEKEY_KEY,userId,deviceId);
        setBucket(key,messageKey,KConstants.Expire.DAY1*30);
    }
    public void cleanMessageKey(int userId,String deviceId){
        deleteBucket(GET_MESSAGEKEY_KEY,userId,deviceId);
    }


    /**
     * 通过authKey获取数据
     * @param authKey 钥匙
     * @return
     */
    public Object queryAuthKey(String authKey){
        String key = String.format(AUTH_KEY, authKey);
        RBucket<Object> bucket = redissonClient.getBucket(key);
        return bucket.get();
    }




    public List<Emoji> getUserCollectCommon(Integer userId){
        String key = String.format(USER_COLLECT_COMMON, userId);
        RList<Emoji> rList = redissonClient.getList(key);
        return rList;
    }

    /** @Description:用户收藏分页列表
     * @param userId
     * @param pageIndex
     * @param pageSize
     * @return
     **/
    public List<Emoji> getUserCollectCommonLimit(Integer userId,Integer pageIndex,Integer pageSize){
        String key = String.format(USER_COLLECT_COMMON, userId);
        List<Emoji> redisPageLimit = redisPageLimit(key, pageIndex, pageSize);
        return redisPageLimit;
    }

    /** @Description: 删除用户收藏
     * @param userId
     **/
    public void deleteUserCollectCommon(Integer userId){
        String key = String.format(USER_COLLECT_COMMON, userId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 维护用户收藏
     * @param userId
     * @param emojis
     **/
    public void saveUserCollectCommon(Integer userId, List<Emoji> emojis){
        String key = String.format(USER_COLLECT_COMMON,userId);
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(emojis);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    public List<Emoji> getUserCollectEmoticon(Integer userId){
        String key = String.format(USER_COLLECT_EMOTICON, userId);
        RList<Emoji> rList = redissonClient.getList(key);
        return rList;
    }

    /** @Description:用户自定义表情分页列表
     * @param userId
     * @param pageIndex
     * @param pageSize
     * @return
     **/
    public List<Emoji> getUserCollectEmoticonLimit(Integer userId,Integer pageIndex,Integer pageSize){
        String key = String.format(USER_COLLECT_EMOTICON, userId);
        List<Emoji> redisPageLimit = redisPageLimit(key, pageIndex, pageSize);
        return redisPageLimit;
    }

    /** @Description: 删除用户自定义表情
     * @param userId
     **/
    public void deleteUserCollectEmoticon(Integer userId){
        String key = String.format(USER_COLLECT_EMOTICON, userId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 维护用户自定义表情
     * @param userId
     * @param emojis
     **/
    public void saveUserCollectEmoticon(Integer userId,List<Emoji> emojis){
        String key = String.format(USER_COLLECT_EMOTICON,userId);
        RList<Object> bucket = redissonClient.getList(key);
        bucket.clear();
        bucket.addAll(emojis);
        bucket.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }





}

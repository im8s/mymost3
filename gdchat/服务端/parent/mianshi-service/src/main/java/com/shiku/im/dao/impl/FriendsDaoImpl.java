package com.shiku.im.dao.impl;


import com.mongodb.client.MapReduceIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.constants.DBConstants;
import com.shiku.im.friends.dao.FriendsDao;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.entity.NewFriends;
import com.shiku.im.friends.service.FriendsRedisRepository;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Repository
public class FriendsDaoImpl extends MongoRepository<Friends, Integer> implements FriendsDao {

    @Autowired
    private FriendsRedisRepository firendsRedisRepository;

    @Autowired
    private UserCoreService userCoreService;


    @Override
    public Class<Friends> getEntityClass() {
        return Friends.class;
    }

    @Autowired
    @Qualifier(value = "mongoTemplateFriends")
    private MongoTemplate mongoTemplateFriends;


    @Autowired
    @Qualifier(value = "mongoNewFriends")
    private MongoTemplate mongoNewFriends;

    @Override
    public MongoTemplate getDatastore() {
        return mongoTemplateFriends;
    }

    /**
     * 获取 分库  分表 表名  分表 逻辑需要继承实现
     * 分表 的类 必须实现 这个方法
     *
     * @param userId
     * @return
     */
    @Override
    public String getCollectionName(int userId) {
        int remainder = 0;
        if (userId > MIN_USERID) {
            remainder = userId / KConstants.DB_REMAINDER.FIRENDS;
        }
        return String.valueOf(remainder);
    }

    @Override
    public String getCollectionName() {
        return DBConstants.FRIENDSDBNAME;
    }


    public Query createQuery(int userId, int toUserId) {
        Query query = createQuery("userId", userId);
        addToQuery(query, "toUserId", toUserId);
        return query;
    }

    public Query createQuery(int userId) {
        Query query = createQuery("userId", userId);
        return query;
    }

    @Override
    public Friends deleteFriends(int userId, int toUserId) {

        Query query = createQuery("userId", userId);
        addToQuery(query, "toUserId", toUserId);

        return getDatastore().findAndRemove(query, getEntityClass(), getCollectionName(userId));
    }

    @Override
    public void deleteFriends(int userId) {

        List<Integer> list = queryFollowId(userId);
        list.forEach(toUserId -> {
            deleteFriends(toUserId, userId);
            firendsRedisRepository.deleteFriends(toUserId);
            firendsRedisRepository.deleteFriendsUserIdsList(toUserId);
        });

        Query query = createQuery("userId", userId);
        deleteByQuery(query, getCollectionName(userId));
        firendsRedisRepository.deleteFriends(userId);
        firendsRedisRepository.deleteFriendsUserIdsList(userId);
    }


    @Override
    public Friends getFriends(int userId, int toUserId) {
        Query query = createQuery(userId, toUserId);
        Friends friends = findOne(query, getCollectionName(userId));
        Query toQuery = createQuery(toUserId, userId);

        Friends tofriends = findOne(toQuery, getCollectionName(toUserId));
        if (null == friends)
            return friends;
        else if (null == tofriends)
            friends.setIsBeenBlack(0);
        else
            friends.setIsBeenBlack(tofriends.getBlacklist());
        return friends;
    }

    @Override
    public List<Friends> queryBlacklist(int userId, int pageIndex, int pageSize) {
        Query query = createQuery(userId);
        addToQuery(query, "blacklist", 1);
        return queryListsByQuery(query, pageIndex, pageSize, getCollectionName(userId));
    }


    @Override
    public List<Friends> queryFriendsList(int userId, int status, int pageIndex, int pageSize) {
        Query query = createQuery(userId);
        if (0 < status) {
            addToQuery(query, "status", status);
        } else {
            query.addCriteria(Criteria.where("status").ne(0));
        }
        // q.or(q.criteria("status").equal(Friends.Status.Attention),
        // q.criteria("status").equal(Friends.Status.Friends));
        if (0 != pageSize) {
            query.with(createPageRequest(pageIndex, pageSize));
        }
        return queryListsByQuery(query, getCollectionName(userId));
    }

    @Override
    public List<Integer> queryFollowId(int userId) {
        Query query = createQuery(userId);
        query.addCriteria(Criteria.where("status").ne(0));
        query.fields().include("toUserId");
        List<Integer> result = getDatastore().findDistinct(query, "toUserId", getCollectionName(userId), Integer.class);
        return result;
    }

    @Override
    public List<Friends> queryFriends(int userId) {
        Query query = createQuery(userId);
        addToQuery(query, "status", Friends.Status.Friends);
        query.addCriteria(Criteria.where("blacklist").ne(1));
        query.addCriteria(Criteria.where("isBeenBlack").ne(1));
        return queryListsByQuery(query, getCollectionName(userId));
    }

    @Override
    public List<Integer> queryFriendUserIdList(int userId) {
        Query query = createQuery(userId);
        addToQuery(query, "status", Friends.Status.Friends);
        query.addCriteria(Criteria.where("blacklist").ne(1));
        query.addCriteria(Criteria.where("isBeenBlack").ne(1));

        query.fields().include("toUserId");

        return getDatastore().findDistinct(query, "toUserId", getCollectionName(userId), Integer.class);
    }

    @Override
    public PageResult<Friends> queryFollowByKeyWord(int userId, int status, String keyWord, int pageIndex, int pageSize) {
        Query q = createQuery(userId);
        if (0 < status) {
            addToQuery(q, "status", status);
        }
        if (!StringUtil.isEmpty( keyWord)) {

            Criteria criteria = createCriteria().orOperator( containsIgnoreCase("toNickname",keyWord));
            q.addCriteria(criteria);
        }
        PageResult<Friends> result = new PageResult<>();
        result.setCount(count(q,getCollectionName(userId)));
        result.setData(queryListsByQuery(q, pageIndex, pageSize, getCollectionName(userId)));
        return result;
    }

    @Override
    public List<Friends> queryAllFriends(Integer userId) {
        return getEntityListsByKey("userId", userId, getCollectionName(userId));
    }

    @Override
    public List<Friends> friendsOrBlackList(int userId, String type) {
        Query query = createQuery(userId);
        if ("friendList".equals(type)) {  //返回好友和单向关注的用户列表
            query.addCriteria(Criteria.where("status").ne(Friends.Status.Stranger));
            query.addCriteria(Criteria.where("blacklist").ne(1));
            //返回非陌生人列表(好友和单向关注)
            //排除加入黑名单的用户
        } else if ("blackList".equals(type)) { //返回黑名单的用户列表
            addToQuery(query, "blacklist", 1);
        }
        return queryListsByQuery(query, getCollectionName(userId));
    }

    @Override
    public Object saveFriends(Friends friends) {
        String chatRecordTimeOut = userCoreService.getSettings(friends.getUserId()).getChatRecordTimeOut();
        friends.setChatRecordTimeOut(Double.valueOf(chatRecordTimeOut));
        return getDatastore().save(friends, getCollectionName(friends.getUserId()));
    }

    @Override
    public Friends updateFriends(Friends friends) {
        Query query = createQuery(friends.getUserId(), friends.getToUserId());

        Update ops = createUpdate();
        ops.set("modifyTime", DateUtil.currentTimeSeconds());
        if (null != friends.getBlacklist()) {
            ops.set("blacklist", friends.getBlacklist());
        }
        if (null != friends.getIsBeenBlack()) {
            ops.set("isBeenBlack", friends.getIsBeenBlack());
        }
        if (null != friends.getStatus()) {
            ops.set("status", friends.getStatus());
        }
        if (!StringUtil.isEmpty(friends.getToNickname())) {
            ops.set("toNickname", friends.getToNickname());
        }
		/*if (!StringUtil.isEmpty(friends.getRemarkName()))
			ops.set("remarkName", friends.getRemarkName());*/
        if (0 != friends.getChatRecordTimeOut()) {
            ops.set("chatRecordTimeOut", friends.getChatRecordTimeOut());
        }
        if (null != friends.getToFriendsRole()) {
            ops.set("toFriendsRole", friends.getToFriendsRole());
        }
        if (0 != friends.getToUserType()) {
            ops.set("toUserType", friends.getToUserType());
        }
        ops.set("modifyTime", DateUtil.currentTimeSeconds());
        return getDatastore().findAndModify(query, ops, getEntityClass(), getCollectionName(friends.getUserId()));
    }

    @Override
    public void updateFriends(int userId, int toUserId, Map<String, Object> map) {
        Query query = createQuery();
        if (0 != userId) {
            addToQuery(query, "userId", userId);
        }
        if (0 != toUserId) {
            addToQuery(query, "toUserId", toUserId);
        }
        Update ops = createUpdate();
        map.forEach((key, value) -> {
            ops.set(key, value);
        });
        update(query, ops, getCollectionName(userId));
    }

    @Override
    public void updateFriendsAttribute(int userId, int toUserId, String key, Object value) {
        Query query = createQuery();
        if (0 != userId) {
            addToQuery(query, "userId", userId);
        }
        if (0 != toUserId) {
            addToQuery(query, "toUserId", toUserId);
        }
        Update ops = createUpdate().set(key, value);
        if (0 != userId) {
            update(query, ops, getCollectionName(userId));
        } else {
            getDatastore().getCollectionNames().forEach(name -> {
                update(query, ops, name);
            });
        }

    }

    @Override
    public Friends updateFriendsReturn(int userId, int toUserId, Map<String, Object> map) {
        Query query = createQuery(userId, toUserId);
        Update ops = createUpdate();
        map.forEach((key, value) -> {
            ops.set(key, value);
        });
        return getDatastore().findAndModify(query, ops, getEntityClass(), getCollectionName(userId));
    }

    @Override
    public void updateFriendsEncryptType(int userId, int toUserId, byte type) {
        Query query = createQuery(userId, toUserId);
        Update ops = createUpdate();
        ops.set("encryptType", type);
        update(query, ops, getCollectionName(userId));
    }

    @Override
    public List<Friends> queryBlacklistWeb(int userId, int pageIndex, int pageSize) {
        Query query = createQuery(userId);
        addToQuery(query, "blacklist", 1);

        return queryListsByQuery(query, pageIndex, pageSize, getCollectionName(userId));
    }


    @Override
    public PageResult<Friends> consoleQueryFollow(int userId, int toUserId, int status, int page, int limit) {
        PageResult<Friends> result = new PageResult<Friends>();
        Query query = createQuery(userId);
        if (0 < status)
            addToQuery(query, "status", status);
        query.addCriteria(Criteria.where("status").ne(0));
        if (0 != toUserId)
            addToQuery(query, "toUserId", toUserId);
        query.addCriteria(Criteria.where("toUserId").ne(10000));
        descByquery(query, "createTime");
        // 系统号好友不返回
        result.setCount(getFriendsCount(userId));
        result.setData(queryListsByQuery(query, page, limit, 1, getCollectionName(userId)));

        return result;
    }


    @Override
    public Friends updateFriendRemarkName(Integer userId, Integer toUserId, String remarkName, String describe) {
        Query query = createQuery(userId, toUserId);
        if (userCoreService.isOpenMultipleDevices(userId)) {
            userCoreService.multipointLoginUpdateUserInfo(userId, userCoreService.getNickName(userId), toUserId, userCoreService.getNickName(toUserId), 1);
        }
        Friends one = findOne(query, getCollectionName(userId));
        // 陌生人备注
        if (null == one) {
            // 添加陌生人
            Friends friends = new Friends();
            friends.setUserId(userId);
            friends.setToUserId(toUserId);
            friends.setRemarkName(remarkName);
            friends.setStatus(Friends.Status.Stranger);
            friends.setCreateTime(DateUtil.currentTimeSeconds());
            // 描述
            friends.setDescribe(describe);
            getDatastore().save(friends, getCollectionName(userId));
            return friends;
        } else {
            Update ops = createUpdate();
            ops.set("modifyTime", DateUtil.currentTimeSeconds());
            if (null == remarkName) {
                ops.set("remarkName", one.getToNickname());
            } else {
                ops.set("remarkName", remarkName);
            }
            // 描述
            ops.set("describe", describe);
            // 维护reids好友数据
            firendsRedisRepository.deleteFriends(userId);
            return getDatastore().findAndModify(query, ops, getEntityClass(), getCollectionName(userId));
        }
    }

    @Override
    public List<Object> getAddFriendsCount(long startTime, long endTime, String mapStr, String reduce) {
        List<Object> countData = new ArrayList<>();
        Document queryTime = new Document("$ne", null);

        if (startTime != 0 && endTime != 0) {
            queryTime.append("$gt", startTime);
            queryTime.append("$lt", endTime);
        }

        Document query = new Document("createTime", queryTime);

        //获得用户集合对象

        List<String> collectionList = getCollectionList();
        MongoCollection<Document> collection = null;
        MapReduceIterable<Document> mapReduceIter = null;
        MongoCursor<Document> iterator = null;
        Double value = null;
        String id = null;
        Map<String, Double> map = new HashMap<String, Double>();
        for (String str : collectionList) {
            collection = getDatastore().getCollection(str);
            mapReduceIter = collection.mapReduce(mapStr, reduce);
            mapReduceIter.filter(query);
            iterator = mapReduceIter.iterator();
            while (iterator.hasNext()) {
                Document obj = iterator.next();
                id = (String) obj.get("_id");
                value = (Double) obj.get("value");
                if (null != map.get(id)) {
                    map.put(id, map.get(id) + value);
                } else {
                    map.put(id, value);
                }

            }

        }
        countData = map.entrySet().stream().collect(Collectors.toList());
        return countData;
    }

    @Override
    public List<NewFriends> getNewFriendsList(int userId, int pageIndex, int pageSize) {
        Query query = createQuery("userId", userId + "");
        query.with(Sort.by(Sort.Order.desc("modifyTime")));
        query.with(PageRequest.of(pageIndex, pageSize));
        return mongoNewFriends.find(query, NewFriends.class, getCollectionName(userId));
    }

    @Override
    public NewFriends getNewFriendLast(int userId, int toUserId){
        Query query = createQuery("userId",userId + "");
        addToQuery(query,"toUserId",toUserId+"");
        descByquery(query,"modifyTime");
        return mongoNewFriends.findOne(query,NewFriends.class,getCollectionName(userId));
    }

    @Override
    public long getFriendsCount(int userId) {
        Query query = createQuery(userId);
        query.addCriteria(Criteria.where("status").ne(0));
        query.addCriteria(Criteria.where("toUserId").ne(10000));
        return count(query, getCollectionName(userId));
    }

    @Override
    public long queryAllFriendsCount() {
        long count = 0;
        for (String name : getCollectionList()) {
            count += getDatastore().getCollection(name).count();
        }
        return count;
    }
}

package com.shiku.im.msg.dao.impl;

import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.entity.Collect;
import com.shiku.im.msg.entity.Comment;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.entity.Praise;
import com.shiku.im.msg.model.AddMsgParam;
import com.shiku.im.msg.model.MessageExample;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/6 16:14
 */
@Repository
public class MsgDaoImpl extends MongoRepository<Msg, ObjectId> implements MsgDao {



    @Override
    public Class<Msg> getEntityClass() {
        return Msg.class;
    }


    @Autowired
    private FriendsManagerImpl friendsManager;

    @Autowired
    private  MsgRedisRepository msgRedisRepository;
    @Autowired
    private UserCoreService userCoreService;

    @Override
    public void add(Msg msg) {
        getDatastore().save(msg);
    }
  
    @Override
    public boolean delete(String... msgIds) {
        for(String msgId : msgIds){
            ObjectId objMsgId = new ObjectId(msgId);
            Query query=createQuery(objMsgId);
            Msg msg = findOne(query);
            Msg.Body body=null;
            if(null!=msg)
                body=msg.getBody();
            else {
                throw new ServiceException(KConstants.ResultCode.DataNotExists);
            }
            try {
                // 删除消息主体
                deleteByQuery(query);
                if(null!=body){
                    if(null!=body.getImages())
                        deleteResource(body.getImages());
                    if(null!=body.getAudios())
                        deleteResource(body.getAudios());
                    if(null!=body.getVideos())
                        deleteResource(body.getVideos());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            ThreadUtils.executeInThread((Callback) obj -> {
                // TODO Auto-generated method stub
                if(null!=msg){
                    Query query1=createQuery("msgId",objMsgId);
                    // 删除评论
                    getDatastore().remove(query, Comment.class);
                    // 删除赞
                    getDatastore().remove(query, Praise.class);
                    // 删除礼物
                    //getDatastore().remove(query,Givegift.class);
                }
                msgRedisRepository.deleteMsgComment(msgId);
                msgRedisRepository.deleteMsgPraise(msgId);
                msgRedisRepository.deleteMsg(msgId);
            });
        }
        return true;
    }

    public List<Msg.Resource> deleteResource(List<Msg.Resource> resources){
        for (Msg.Resource resource : resources) {
            try {
                ConstantUtil.deleteFile(resource.getOUrl());
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return resources;
    }


    @Override
    public List<Msg> findByExample(int userId, MessageExample example) {
        List<Integer> userIdList =friendsManager.queryFollowId(userId);
        userIdList.add(userId);

        Query query = createQuery();

        if (!StringUtil.isEmpty(example.getBodyTitle()))
            query.addCriteria(Criteria.where("body.title").regex(example.getBodyTitle()));
        if (0 != example.getCityId())
            addToQuery(query,"cityId",example.getCityId());
        if (0 != example.getFlag())
            addToQuery(query,"flag",example.getFlag());
        if (ObjectId.isValid(example.getMsgId()))
            query.addCriteria(Criteria.where("_id").gt(new ObjectId(example.getMsgId())));

        query.addCriteria(Criteria.where("userId").in(userIdList));

        query.addCriteria(Criteria.where("visible").gt(0));
        descByquery(query,"_id");

        return queryListsByQuery(query);
    }

    @Override
    public List<Msg> gets(int userId, String ids) {
        List<ObjectId> idList = Lists.newArrayList();
        JSON.parseArray(ids, String.class).forEach(id -> {
            idList.add(new ObjectId(id));
        });

        Query query = createQuery();
        query.addCriteria(Criteria.where("_id").in(idList));
        descByquery(query,"_id");


        return queryListsByQuery(query);
    }

    @Override
    public List<Msg> getUserMsgList(Integer userId, Integer toUserId, ObjectId msgId,int pageIndex, Integer pageSize) {
        // 不让他看
        User toUser = userCoreService.getUser(toUserId);
//        if(null != toUser.getSettings().getNotSeeFilterCircleUserIds()){
//            if(toUser.getSettings().getNotSeeFilterCircleUserIds().contains(userId)){
//                throw new ServiceException(KConstants.ResultCode.DontVisitFriendsMsg);
//            }
//        }
        // 我不看他
        User user = userCoreService.getUser(userId);
        if(null != user.getSettings().getFilterCircleUserIds()){
            if(user.getSettings().getFilterCircleUserIds().contains(toUserId)){
                return null;
            }
        }
        List<Msg> list = Lists.newArrayList();

        // 获取登录用户最新消息
        if (null == toUserId || userId.intValue() == toUserId.intValue()) {
            list = findByUser(userId,toUserId, msgId,pageIndex, pageSize);
        }
        // 获取某用户最新消息
        else {
            // 获取BA关系
            Friends friends = friendsManager.getFriends(new Friends(toUserId, userId));

            // 陌生人
            if (null == friends || (Friends.Blacklist.No == friends.getBlacklist() && Friends.Status.Stranger == friends.getStatus())) {
                list = findByUser(userId,toUserId, msgId,pageIndex, 10);
            }
            // 关注或好友
            else if (Friends.Blacklist.No == friends.getBlacklist()) {
                list = findByUser(userId,toUserId, msgId,pageIndex, pageSize);
            }
            // 黑名单
            else {
                // 不返回
            }
        }

        return list;
    }

    @Override
    public List<Msg> findByUser(Integer userId,Integer toUserId, ObjectId msgId,int pageIndex, Integer pageSize) {
        Query query = createQuery("userId",toUserId);
        if (null != msgId)
           query.addCriteria(Criteria.where(ID_KEY).lt(msgId));

        List<Integer> users=new ArrayList<Integer>();
        users.add(userId);


        Criteria criteria1 = Criteria.where("visible").is(1).and("userNotLook").nin(users);
        Criteria criteria2=Criteria.where("userId").is(userId);
        Criteria criteria3=Criteria.where("visible").is(3).and("userLook").in(users);
        Criteria criteria4=Criteria.where("visible").is(4).and("userNotLook").nin(users);

        Criteria criteria=createCriteria().orOperator(criteria1,criteria2,criteria3,criteria4);
        query.addCriteria(criteria);
        descByquery(query,ID_KEY);

        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public List<Msg> getUserMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize) {
        Query query =createQuery("userId",userId);
        query.fields().include("userId");
        query.fields().include("nickname");
        if (null != msgId)
            query.addCriteria(Criteria.where(ID_KEY).lt(msgId));
        descByquery(query,ID_KEY);

        return queryListsByQuery(query);
    }

    @Override
    public boolean forwarding(Integer userId, AddMsgParam param) {
        return true;
    }

    @Override
    public Msg get(int userId, ObjectId msgId) {
        return get(msgId);
    }

    //    @Override
//    public Msg get(int userId, ObjectId msgId) {
//        String key = String.format(RedisServiceImpl.S_MSG_MSGID, msgId.toString());
//        boolean exists = SKBeanUtils.getRedisCRUD().keyExists(key);
//        if (!exists) {
//            Msg msg = getDatastore().createQuery(getEntityClass()).field(Mapper.ID_KEY).equal(msgId).
//            );
//            if(null==msg)
//                return msg;
//            else if(0==userId)
//                return msg;
//
//            String value = msg.toString();
//            SKBeanUtils.getRedisCRUD().setWithExpireTime(key, value, 43200);
//
//        }
//
//        String text =SKBeanUtils.getRedisCRUD().get(key);
//
//        Msg msg;
//        // 缓存未命中、超出缓存范围
//        if (null == text || "".equals(text)) {
//            msg = getDatastore().createQuery(getEntityClass()).field(Mapper.ID_KEY).equal(msgId).get();
//            if(null==msg)
//                return msg;
//        } else {
//            // msg = JSON.parseObject(text, getEntityClass());
//            try {
//                msg = new ObjectMapper().readValue(text, getEntityClass());
//            } catch (Exception e) {
//                throw new ServiceException(KConstants.ResultCode.MsgCacheParsingFaliure);
//            }
//        }
//
//        msg.setComments(SKBeanUtils.getMsgCommentRepository().find(msg.getMsgId(), null, 0, 20));
//        msg.setPraises(SKBeanUtils.getMsgPraiseRepository().find(msg.getMsgId(), null, 0, 20));
//        msg.setGifts(SKBeanUtils.getMsgGiftRepository().find(msg.getMsgId(), null, 0, 20));
//        msg.setIsPraise(SKBeanUtils.getMsgPraiseRepository().exists(userId, msg.getMsgId()) ? 1 : 0);
//        msg.setIsCollect(SKBeanUtils.getMsgPraiseRepository().existsCollect(ReqUtil.getUserId(), msg.getMsgId()) ? 1 : 0);
//        return msg;
//    }

    @Override
    public List<Msg> getMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize) {
        List<Integer> userIdList = friendsManager.queryFollowId(userId);
        userIdList.add(userId);

        Query query =createQuery();
        query.addCriteria(Criteria.where("userId").in(userIdList));

        /*query.fields().include("userId");
        query.fields().include("nickname");*/

        if (null != msgId)
            query.addCriteria(Criteria.where(ID_KEY).lt(msgId));
        descByquery(query,ID_KEY);

        return queryListsByQuery(query);
    }

    @Override
    public List<Msg> getMsgList(Integer userId, ObjectId msgId, Integer pageIndex,Integer pageSize) {
        List<Integer> userIdList = friendsManager.queryFriendUserIdList(userId);

        userIdList.add(userId);

        List<Integer> users=new ArrayList<Integer>();
        users.add(userId);

        Query query =createQuery();
        Criteria userIdCriteria = Criteria.where("userId").in(userIdList);

        query.addCriteria(Criteria.where("state").ne(1));

        Query userQuery = createQuery().addCriteria(Criteria.where("settings.notSeeFilterCircleUserIds").is(userId));
        List<User> asList = getDatastore().find(userQuery,User.class);
        List<Integer> userNotLookList = new ArrayList<Integer>();
        if(null != asList && asList.size() > 0){
            asList.forEach(user ->{
                userNotLookList.add(user.getUserId());
            });
            userIdCriteria.nin(userNotLookList);
        }
        User user=userCoreService.getUser(userId);
        if(null!=user.getSettings()&&null!=user.getSettings().getFilterCircleUserIds()) {
            userIdCriteria.nin(user.getSettings().getFilterCircleUserIds());
        }
        if (null != msgId)
            query.addCriteria(Criteria.where(ID_KEY).lt(msgId));

        Criteria criteria1 = Criteria.where("visible").is(1).and("userNotLook").nin(users);
        Criteria criteria2=Criteria.where("userId").is(userId);
        Criteria criteria3=Criteria.where("visible").is(3).and("userLook").in(users);
        Criteria criteria4=Criteria.where("visible").is(4).and("userNotLook").nin(users);
        query.addCriteria(userIdCriteria);
        Criteria criteria=createCriteria().orOperator(criteria1,criteria2,criteria3,criteria4);
        query.addCriteria(criteria);

        descByquery(query,"time");
        return queryListsByQuery(query,pageIndex,pageSize);
    }

    /** @Description:（后台获取朋友圈列表）
     * @param
     * @param
     * @return
     **/
//    public PageResult<Msg> getMsgList(Integer page, Integer limit, String nickname, Integer userId) {
//        PageResult<Msg> result=new PageResult<Msg>();
//        try {
//            Query query = getDatastore().createQuery(getEntityClass()).order("-time");
//            if(!StringUtil.isEmpty(nickname))
//                query.criteria("nickname").contains(nickname);
//            else if(0 != userId)
//                query.field("userId").equal(userId);
//            List<Msg> msgList = query.asList(pageFindOption(page, limit, 1));
//            for(Msg msg : msgList){
//                User user = userCoreService.get(msg.getUserId());
//                if(null == user){
//                    // 过滤废弃的测试账号朋友圈数据
//                    ThreadUtil.executeInThread(new Callback() {
//
//                        @Override
//                        public void execute(Object obj) {
//                            Query erryQuery = getDatastore().createQuery(getEntityClass()).field("userId").equal(msg.getUserId());
//                            getDatastore().delete(erryQuery);
//                        }
//                    });
//
//                }else{
//                    msg.setUserStatus(user.getStatus());
//                }
//            }
//            result.setCount(query.count());
//            result.setData(msgList);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return result;
//    }

    /** @Description: 短视频查询
     * @param pageIndex
     * @param pageSize
     * @param lable 1：美食，2：景点，3：文化，4：玩乐，5：酒店，6：购物，7：运动，8：其他 (包含旧视频)
     * @return
     **/
    @Override
    public List<Msg> getPureVideo(Integer pageIndex,Integer pageSize,String lable){
        Query query = createQuery();
        User user=userCoreService.getUser(ReqUtil.getUserId());
        if(null!=user.getSettings()&&null!=user.getSettings().getFilterCircleUserIds()) {
            query.addCriteria(Criteria.where("userId").nin(user.getSettings().getFilterCircleUserIds()));
        }
        query.addCriteria(Criteria.where("visible").ne(2));
        query.addCriteria(Criteria.where("body.videos").ne(null));
        if(!StringUtil.isEmpty(lable) && "8".equals(lable))
            query.addCriteria(Criteria.where("body.lable").is(null));
        else if(!StringUtil.isEmpty(lable))
            query.addCriteria(Criteria.where("body.lable").is(lable));
        descByquery(query,"time");

        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public List<Msg> getSquareMsgList(int userId, ObjectId msgId, Integer pageSize) {
        Query query =createQuery();
        if (null != msgId)
            query.addCriteria(Criteria.where(ID_KEY).lt(msgId));
        descByquery(query,ID_KEY);

        return queryListsByQuery(query,0,pageSize);
    }

    @Override
	public synchronized void update(ObjectId msgId, Msg.Op op, int activeValue) {
        Query query =createQuery(msgId);
		Msg msg = findOne(query);
		if(null==msg){
			return;
		}
		if(-1==activeValue){
			if(Msg.Op.Comment.getKey().equals(op.getKey())){
				if(0>=msg.getCount().getComment())
					throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
			}else if(Msg.Op.Praise.getKey().equals(op.getKey())){
				if(0>=msg.getCount().getPraise())
					throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
			}else if(Msg.Op.Collect.getKey().equals(op.getKey())){
				if(0>=msg.getCount().getCollect())
					throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
			}
		}

        Update ops = createUpdate().inc(op.getKey(), activeValue).inc("count.total", activeValue);
        // 更新消息
		update(query, ops);
    }

    /** @Description:（锁定解锁朋友圈）
     * @param msgId
     **/
    @Override
    public void lockingMsg(ObjectId msgId,int state){
        Query query=createQuery(msgId);
        if(null == query)
            throw new ServiceException("Msg is null, msgId:"+msgId);
        Update ops =createUpdate();
        ops.set("state", state);
        update(query, ops);
    }

    /** @Description:（朋友圈评论）
     * @param msgId
     **/
    public PageResult<Comment> commonListMsg(ObjectId msgId,Integer page,Integer limit){
        PageResult<Comment> result = new PageResult<Comment>();
        Query query=createQuery("msgId",msgId);
		/*if(null == query)
			throw new ServiceException("Comment is null, msgId:"+msgId);*/

        descByquery(query,"time");
        result.setCount(count(query));
        query.with(createPageRequest(page,limit,1));

        result.setData(getDatastore().find(query,Comment.class));
        return result;
    }

    /** @Description:（朋友圈点赞）
     * @param msgId
     **/
    public PageResult<Praise> praiseListMsg(ObjectId msgId, Integer page, Integer limit){
        PageResult<Praise> result = new PageResult<Praise>();
        Query query=createQuery("msgId", msgId);
		/*if(null == query)
			throw new ServiceException("Comment is null, msgId:"+msgId);*/
        query.with(createPageRequest(page,limit,1));
        result.setCount(count());
        result.setData(getDatastore().find(query,Praise.class));
        return result;
    }

    @Override
    public void updateMsg(int userId, Map<String, Object> map) {
        Query query =createQuery("userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public List<Msg> getMsgList(int userId, String nickName, int pageIndex, int pageSize) {
        Query query = createQuery();
            if(!StringUtil.isEmpty(nickName))
                query.addCriteria(Criteria.where("nickname").regex(nickName));
            else if(0 != userId)
                query.addCriteria(Criteria.where("userId").is(userId));
        descByquery(query,"time");
        return queryListsByQuery(query,pageIndex,pageSize,1);
    }

    @Override
    public void deleteMsg(int userId) {
        Query query = createQuery("userId",userId);
        deleteByQuery(query);
    }

    @Override
    public PageResult<Msg> getMsgListResult(int userId, String nickName, int pageIndex, int pageSize) {
        PageResult<Msg> pageResult = new PageResult<>();
        Query query = createQuery();
        if(!StringUtil.isEmpty(nickName))
            query.addCriteria(Criteria.where("nickname").regex(nickName));
        else if(0 != userId)
            query.addCriteria(Criteria.where("userId").is(userId));

        descByquery(query,"time");
        pageResult.setCount(count(query));
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,1));
        return pageResult;
    }


    @Override
    public void addCollect(Collect collect) {
        getDatastore().save(collect);
    }

    @Override
    public void deleteCollect(ObjectId msgId) {
        Query query =createQuery("msgId",msgId);
        getDatastore().remove(query,Collect.class);
    }

    @Override
    public void deleteCollect(ObjectId msgId, int userId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"msgId",msgId);
        getDatastore().remove(query,Collect.class);
    }

    @Override
    public boolean existsCollect(int userId, ObjectId msgId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"msgId",msgId);
        return getDatastore().exists(query,Collect.class);
    }

}

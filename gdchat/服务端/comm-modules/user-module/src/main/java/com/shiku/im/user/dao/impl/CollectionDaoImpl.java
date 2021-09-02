package com.shiku.im.user.dao.impl;

import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.msg.entity.Collect;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.support.Callback;
import com.shiku.im.user.dao.CollectionDao;
import com.shiku.im.user.entity.Emoji;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.utils.ConstantUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CollectionDaoImpl extends MongoRepository<Emoji,Integer> implements CollectionDao {

    @Override
    public Class<Emoji> getEntityClass() {
        return Emoji.class;
    }


    @Autowired
    private UserRedisService userRedisService;


    @Override
    public void addEmoji(Emoji emoji) {
        getDatastore().save(emoji);
    }

    @Override
    public void deleteEmoji(ObjectId emojiId, Integer userId) {
        Query query =createQuery("_id",emojiId);
        addToQuery(query,"userId",userId);
             deleteByQuery(query);
    }

    @Override
    public void deleteEmoji(String collectMsgId, int userId) {
        Query query =createQuery("collectMsgId",collectMsgId);
        addToQuery(query,"userId",userId);
        deleteByQuery(query);
    }

    @Override
    public Emoji getEmoji(ObjectId emojiId, Integer userId) {
        Query query =createQuery("_id",emojiId);
        addToQuery(query,"userId",userId);
        return findOne(query);
    }

    @Override
    public Emoji getEmoji(String msgId, Integer userId) {
        Query query =createQuery("msgId",msgId);
        addToQuery(query,"userId",userId);
        return findOne(query);
    }

    @Override
    public Emoji getEmoji(Integer userId, String url) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"url",url);
        return findOne(query);
    }

    @Override
    public Emoji getEmoji(String msg, int type, Integer userId, String msgId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"type",type);
        addToQuery(query,"msg",msg);
        if(!StringUtil.isEmpty(msgId)){
            addToQuery(query,"msgId",msgId);
        }
        return findOne(query);
    }

    @Override
    public Emoji getEmoji(String collectMsgId, int userId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"collectMsgId",collectMsgId);
        return findOne(query);

    }

    @Override
    public List<Emoji> queryEmojiList(Integer userId, int type) {
        Query query =createQuery("userId",userId);
        if(0 != type){
            addToQuery(query,"type",type);
        }else{
            query.addCriteria(Criteria.where("type").lt(6));
        }
        query.with(Sort.by(Sort.Order.desc("createTime")));
        return queryListsByQuery(query);
    }

    @Override
    public List<Emoji> queryEmojiListOrType(Integer userId) {
        Query query =createQuery("userId",userId);
        Criteria criteria = createCriteria().orOperator(Criteria.where("type").lt(7), Criteria.where("type").is(7));
        query.addCriteria(criteria);
        query.addCriteria(Criteria.where("type").ne(6));
        query.with(Sort.by(Sort.Order.desc("createTime")));
//        query.addCriteria(Criteria.where("msgId").ne(null));
        return queryListsByQuery(query);
    }

    @Override
    public Emoji queryEmojiByUrlAndType(String url,int type,Integer userId) {
        Query query =createQuery("userId",userId);
        addToQuery(query,"type",type);
        addToQuery(query,"url",url);
       return findOne(query);
    }

    public void deleteCollectInfo(int userId, String msgId) {
        Query query =createQuery("msgId",new ObjectId(msgId));
        addToQuery(query,"userId",userId);
        getDatastore().remove(query,Collect.class);
    }

    public void deleteCollect(int userId, String msgId) {
        // 删除收藏
        deleteCollectInfo(userId,msgId);
        deleteEmoji(msgId,userId);
        Emoji emoji = getEmoji(msgId,userId);
        userRedisService.deleteUserCollectCommon(userId);
        userRedisService.deleteUserCollectEmoticon(userId);
        ThreadUtils.executeInThread((Callback) obj -> {
            if(null != emoji)
                ConstantUtil.deleteFile(emoji.getUrl());
        });
    }


}

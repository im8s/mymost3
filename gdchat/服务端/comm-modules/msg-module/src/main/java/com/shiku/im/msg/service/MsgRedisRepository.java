package com.shiku.im.msg.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.msg.entity.*;
import com.shiku.redisson.AbstractRedisson;
import org.redisson.api.RBucket;
import org.redisson.api.RList;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.concurrent.TimeUnit;

@Repository
public class MsgRedisRepository extends AbstractRedisson {

    @Autowired(required=false)
    private RedissonClient redissonClient;

    @Override
    public RedissonClient getRedissonClient() {
        return redissonClient;
    }


    /**
     * 某条朋友圈最近20 条评论列表
     */
    public static final String S_MSG_COMMENT_MSGID="s_msg:comment_msgId:%s";

    /**
     * 某条朋友圈最近20条点赞列表
     */
    public static final String S_MSG_PRAISE_MSGID="s_msg:praise_msgId:%s";

    /**
     * 某条朋友圈最近20条播放量列表
     */
    public static final String S_MSG_PLAY_MSGID = "s_msg:play_msgId:%s";

    /**
     * 某条朋友圈最近20条转发量列表
     */
    public static final String S_MSG_FORWARD_MSGID = "s_msg:forward_msgId:%s";

    /**
     * 某条朋友圈详情
     */
    public static final String S_MSG_MSGID="s_msg:msg_msgId:%s";

    public void saveMsg(Msg msg){
        String key = String.format(S_MSG_MSGID,msg.getMsgId());
        RBucket<Msg> bucket = redissonClient.getBucket(key);
        bucket.set(msg, KConstants.Expire.DAY7,TimeUnit.SECONDS);
    }
    public Msg getMsg(String msgId){
        String key = String.format(S_MSG_MSGID,msgId);
        RBucket<Msg> bucket1 = redissonClient.getBucket(key);
        return bucket1.get();
    }

    public void deleteMsg(String msgId){
        String keys = String.format(S_MSG_MSGID, msgId);
        deleteBucket(keys);
    };

    /** @Description: 删除某条朋友圈最近二十条评论
     * @param msgId
     **/
    public void deleteMsgComment(String msgId){
        String key = String.format(S_MSG_COMMENT_MSGID, msgId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 维护某条朋友圈最近二十条评论
     * @param msgId
     * @param msgs
     **/
    public void saveMsgComment(String msgId,List<Comment> msgs){
        String key = String.format(S_MSG_COMMENT_MSGID, msgId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(msgs);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    /** @Description: 获取某条朋友 圈最近二十条评论
     * @param userId
     * @return
     **/
    public List<Comment> getMsgComment(String msgId){
        String key = String.format(S_MSG_COMMENT_MSGID, msgId);
        RList<Comment> list = redissonClient.getList(key);
        return list.readAll();
    }


    /** @Description: 删除某条朋友圈最近二十条点赞
     * @param msgId
     **/
    public void deleteMsgPraise(String msgId){
        String key = String.format(S_MSG_PRAISE_MSGID, msgId);
        redissonClient.getBucket(key).delete();
    }

    /** @Description: 维护某条朋友圈最近二十条点赞
     * @param msgId
     * @param msgs
     **/
    public void saveMsgPraise(String msgId,List<Praise> msgs){
        String key = String.format(S_MSG_PRAISE_MSGID, msgId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(msgs);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    /** @Description: 获取某条朋友圈最近二十条点赞
     * @param userId
     * @return
     **/
    public List<Praise> getMsgPraise(String msgId){
        String key = String.format(S_MSG_PRAISE_MSGID, msgId);
        RList<Praise> list = redissonClient.getList(key);
        return list.readAll();
    }

    /**
     * 保存某条朋友圈最近二十条播放量
     * @param msgId
     * @param playAmounts
     */
    public void saveMsgPlay(String msgId,List<PlayAmount> playAmounts){
        String key = String.format(S_MSG_PLAY_MSGID, msgId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(playAmounts);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);
    }

    /**
     * 删除某条朋友圈最近二十条播放量
     * @param msgId
     */
    public void deleteMsgPlay(String msgId){
        String key = String.format(S_MSG_PLAY_MSGID, msgId);
        redissonClient.getBucket(key).delete();
    }

    /**
     * 获取某条朋友圈最近二十条播放量
     * @param msgId
     * @return
     */
    public List<PlayAmount> getMsgPlay(String msgId){
        String key = String.format(S_MSG_PLAY_MSGID, msgId);
        RList<PlayAmount> list = redissonClient.getList(key);
        return list.readAll();
    }

    /**
     * 保存某条朋友圈最近二十条转发量
     * @param msgId
     * @param forwardAmounts
     */
    public void saveMsgForward(String msgId,List<ForwardAmount> forwardAmounts){
        String key = String.format(S_MSG_FORWARD_MSGID, msgId);
        RList<Object> list = redissonClient.getList(key);
        list.clear();
        list.addAll(forwardAmounts);
        list.expire(KConstants.Expire.DAY7, TimeUnit.SECONDS);

    }

    /**
     * 删除某条朋友圈最近二十条转发量
     * @param msgId
     */
    public void deleteMsgForward(String msgId){
        String key = String.format(S_MSG_FORWARD_MSGID, msgId);
        redissonClient.getBucket(key).delete();
    }

    /**
     * 获取某条朋友圈最近二十条转发量
     * @param msgId
     * @return
     */
    public List<ForwardAmount> getMsgForward(String msgId){
        String key = String.format(S_MSG_FORWARD_MSGID, msgId);
        RList<ForwardAmount> list = redissonClient.getList(key);
        return list.readAll();
    }
}

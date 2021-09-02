package com.shiku.im.msg.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.entity.Collect;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.model.AddMsgParam;
import com.shiku.im.msg.model.MessageExample;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface MsgDao extends IMongoDAO<Msg, ObjectId> {
    //	ObjectId add(int userId, AddMsgParam param);
    void add(Msg msg);

    boolean delete(String... msgId);

    List<Msg> gets(int userId, String ids);

    /**
     * 获取用户最新商务圈消息
     *
     * @param userId
     * @param toUserId
     * @param msgId
     * @param pageSize
     * @return
     */
    List<Msg> getUserMsgList(Integer userId, Integer toUserId, ObjectId msgId, int pageIndex, Integer pageSize);

    /**
     * 获取用户最新商务圈消息
     *
     * @param userId
     * @param msgId
     * @param pageSize
     * @return
     */
    List<Msg> findByUser(Integer userId, Integer toUserId, ObjectId msgId, int pageIndex, Integer pageSize);

    /**
     * 获取当前登录用户及其所关注用户的最新商务圈消息
     *
     * @param userId
     * @param
     * @param msgId
     * @param pageSize
     * @return
     */
    List<Msg> getMsgList(Integer userId, ObjectId msgId, Integer pageIndex, Integer pageSize);

    /**
     * 获取用户最新商务圈消息Id
     *
     * @param userId
     * @param toUserId
     * @param msgId
     * @param pageSize
     * @return
     */
    List<Msg> getUserMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize);

    /**
     * 获取当前登录用户及其所关注用户的最新商务圈消息Id
     *
     * @param userId
     * @param toUserId
     * @param msgId
     * @param pageSize
     * @return
     */
    List<Msg> getMsgIdList(int userId, int toUserId, ObjectId msgId, int pageSize);

    List<Msg> findByExample(int userId, MessageExample example);

    boolean forwarding(Integer userId, AddMsgParam param);

    Msg get(int userId, ObjectId msgId);

    List<Msg> getSquareMsgList(int userId, ObjectId msgId, Integer pageSize);

    void update(ObjectId msgId, Msg.Op op, int activeValue);

    void updateMsg(int userId, Map<String, Object> map);

    List<Msg> getMsgList(int userId, String nickName, int pageIndex, int pageSize);

    void deleteMsg(int userId);

    PageResult<Msg> getMsgListResult(int userId, String nickName, int pageIndex, int pageSize);

    List<Msg> getPureVideo(Integer pageIndex, Integer pageSize, String lable);

    void lockingMsg(ObjectId msgId, int state);


    void addCollect(Collect collect);

    void deleteCollect(ObjectId msgId);

    void deleteCollect(ObjectId msgId,int userId);

    boolean existsCollect(int userId, ObjectId msgId);
}

package com.shiku.im.message.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import org.bson.Document;

import java.util.List;

public interface TigaseMsgDao extends IMongoDAO<Object,Integer> {

    Document getLastBody(int sender, int receiver);
    List<Object> getMsgList(int userId,int pageIndex,int pageSize);

    Object getMsgList(int sender,int receiver,int pageIndex,int pageSize);


    void updateMsgIsReadStatus(int userId, String msgId);

    /**
     * 清除最后一条聊天记录
     * @param userId
     * @param jid
     */
    void deleteLastMsg(String userId,String jid);

    /**
     * 清除某个用户的所有的最后一条聊天记录
     * @param userId
     */
    void deleteUserAllLastMsg(String userId);

    long getMsgCountNum();

    List<Object> getChatMsgCount(String startDate, String endDate,int counType);

    /**
     * 清除用户好友的历史消息
     * 及清空最后一条消息记录
     * * @param userId
     * @param serverName
     */
    void cleanUserFriendHistoryMsg(int userId,String serverName);

    void destroyUserMsgRecord(int userId);

    /**
     * 清空好友聊天记录
     *
     * @param userId 自己的用户ID
     * @param toUserId 好友用户Id
     */
    void cleanFriendMessage(int userId,int toUserId,int type);

//    void deleteFriendMessage(int userId,int toUserId);

    List<Object> getGroupMsgCount(String roomId, String startDate, String endDate, short counType);

    /**
     * 查询条聊天记录用于收藏
     * @param roomJid
     * @param messageId
     * @return
     */
    Document queryCollectMessage(int userId,String roomJid, String messageId);


    List<Document> queryLastChatList(int userId ,long startTime, int pageSize);

    /**
     * 查询条聊天记录
     * @param roomJid
     * @param messageId
     * @return
     */
    Document queryMessage(int userId,String roomJid, String messageId);

    /**
     * 查询指定群组或单聊的聊天记录
     * @param userId
     * @param roomJid 不指定则查询单聊
     * @param messageIds
     * @return
     */
    List<Document> queryMsgDocument(int userId,String roomJid, List<String> messageIds);

    /**
     * 删除指定时间内的群聊聊天记录
     * @param startTime
     * @param endTime
     * @param room_jid_id
     */
    void deleteGroupMsgBytime(long startTime, long endTime, String room_jid_id);
    /**
     删除过期的 群组聊天消息
     */
    void deleteOutTimeMucMsg();
    /**
     漫游好友聊天记录
     */
    List<Document> queryChatMessageRecord(int userId,int toUserId,long startTime,
                                          long endTime,int pageIndex,
                                          int pageSize, int maxType);

    /**
     漫游群组聊天记录
     */
    List<Document> queryMucMsgs( String roomJid,  long startTime,
                                long endTime,  int pageIndex,
                                 int pageSize,int maxType,boolean flag);
    /**
     * 查询好友的聊天记录
     * @param sender 自己的用户ID
     * @param receiver 好友的用户ID
     * @param page
     * @param limit
     * @return
     */
    PageResult<Document> queryFirendMsgRecord(Integer sender, Integer receiver, Integer page, Integer limit);

    /**
     删除 tigase 超过100条的聊天历史记录
     */
    void deleteMucHistory();

    /**
     * 清除群组历史聊天记录
     * @param roomJid  群组jid
     */
    void dropRoomChatHistory(String roomJid);
    /**
     * 删除tigase 自己的群组历史聊天记录
     * @param roomJid
     */
    void cleanTigaseMuc_History(String roomJid);


    void cleanRoomTigase_Nodes(String roomJid);

    /***
     *
     * @param roomJid
     */
    //void deleteLastMucMsg(String roomJid);

    List<Document> queryLastChatList(String userId,long startTime, long endTime, int pageSize, List<String> roomJidList);

    /**
     定时删除  过期的单聊聊天记录
     */
    void deleteTimeOutChatMsgRecord();

    /*删除消息接口
    type 1 单聊 2 群聊
    delete 1 删除属于自己的消息记录 2：撤回 删除 整条消息记录
    */
    void deleteMsgUpdateLastMessage(int sender, String roomJid, String messageId,int delete, int type);


    /**
     * 更新单聊好友聊天消息状态
     * @param messageId
     */
    void changeMsgReadStatus(String messageId,int userId,int toUserId);

    PageResult<Document> chat_logs_all(long startTime, long endTime, int sender,
                                       int receiver, int page, int limit, String keyWord) throws Exception;

    void chat_logs_all_del(long startTime, long endTime, int sender,
                           int receiver, int pageIndex, int pageSize)throws Exception;

    void deleteChatMsgs(String msgId, int type);

    PageResult<Document>  groupchat_logs_all(long startTime, long endTime, String room_jid_id,
                                             int page, int limit, String keyWord);

    void groupchat_logs_all_del(long startTime, long endTime,
                                String msgId, String room_jid_id)throws Exception;

    void groupchatMsgDel(String roomJid,
                         int type);

    PageResult<Document> roomDetail(int page, int limit, String room_jid_id);

    void deleteGroupMsgByUid(int userId, String room_jid_id);
}

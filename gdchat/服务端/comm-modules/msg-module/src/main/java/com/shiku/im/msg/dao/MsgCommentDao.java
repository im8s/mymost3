package com.shiku.im.msg.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.model.AddCommentParam;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.msg.entity.Comment;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface MsgCommentDao extends IMongoDAO<Comment, ObjectId> {

    ObjectId add(int userId, String nickName, AddCommentParam param);

    Comment getComment(ObjectId id);

    boolean delete(ObjectId msgId, String commentId);

    List<Comment> find(ObjectId msgId, ObjectId commentId, int pageIndex, int pageSize);

    void update(int userId, Map<String, Object> map);

    List<ObjectId> getCommentIds(Integer userId);

    void deleteComment(ObjectId id);

    PageResult<Comment> commonListMsg(ObjectId msgId, Integer page, Integer limit);
}

package com.shiku.im.msg.service;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.entity.Comment;
import com.shiku.im.msg.model.AddCommentParam;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgCommentManager {

    ObjectId add(int userId, AddCommentParam param);

    boolean delete(ObjectId msgId, String commentId);

    List<Comment> find(ObjectId msgId, ObjectId commentId, int pageIndex, int pageSize);

    PageResult<Comment> commonListMsg(ObjectId msgId, Integer page, Integer limit);
}

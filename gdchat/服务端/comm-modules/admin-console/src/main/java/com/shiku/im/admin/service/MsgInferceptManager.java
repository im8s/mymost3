package com.shiku.im.admin.service;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.KeyWord;
import com.shiku.im.admin.entity.MsgIntercept;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgInferceptManager {
	
	public void addKeyword(String word, String id);

	public void deleteKeyword(ObjectId id);

	public List<KeyWord> queryKeywordList(String word, int pageIndex, int pageSize);

	public List<MsgIntercept> queryMsgInterceptList(Integer userId, String toUserId, int pageIndex, int pageSize, int type, String content);
	
	public void deleteMsgIntercept(ObjectId id);

	public PageResult<MsgIntercept> webQueryMsgInterceptList(Integer userId, String toUserId, int pageIndex, int pageSize, int type, String content);
}

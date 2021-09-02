package com.shiku.im.admin.service.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.MsgInferceptDAO;
import com.shiku.im.admin.entity.KeyWord;
import com.shiku.im.admin.entity.MsgIntercept;
import com.shiku.im.admin.service.MsgInferceptManager;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MsgInferceptManagerImpl implements MsgInferceptManager {
	
	@Autowired
	private MsgInferceptDAO msgInferceptDAO;
	
	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private  RoomManagerImplForIM roomManager;
	
	@Override
	public void addKeyword(String word,String id) {
		KeyWord keyword = null;
		if (StringUtil.isEmpty(id)) {
			keyword = new KeyWord();
			keyword.setWord(word);
			keyword.setCreateTime(DateUtil.currentTimeSeconds());
			msgInferceptDAO.saveKeyword(keyword);
		}else{
			msgInferceptDAO.updateKeyword(word, new ObjectId(id));
		}
	}

	@Override
	public void deleteKeyword(ObjectId id) {
		msgInferceptDAO.deleteKeyword(id);
	}

	@Override
	public List<KeyWord> queryKeywordList(String word, int pageIndex, int pageSize) {
		return msgInferceptDAO.queryKeywordList(word, pageIndex, pageSize);
	}

	@Override
	public List<MsgIntercept> queryMsgInterceptList(Integer userId, String toUserId, int pageIndex, int pageSize,
													int type, String content) {
		List<MsgIntercept> data = msgInferceptDAO.queryMsgInerceptList(userId, toUserId, pageIndex, pageSize, type, content);
		
		for(MsgIntercept keyWordIntercept : data){
			keyWordIntercept.setSenderName(userCoreService.getNickName(Integer.valueOf(keyWordIntercept.getSender())));
			if(!StringUtil.isEmpty(keyWordIntercept.getReceiver())){
				keyWordIntercept.setReceiverName(userCoreService.getNickName(Integer.valueOf(keyWordIntercept.getReceiver())));
			}else if(!StringUtil.isEmpty(keyWordIntercept.getRoomJid())){
				keyWordIntercept.setRoomName(roomManager.getRoomName(keyWordIntercept.getRoomJid()));
			}
		}
		return data;
	}

	@Override
	public void deleteMsgIntercept(ObjectId id) {
		msgInferceptDAO.deleteMsgIntercept(id);
	}

	@Override
	public PageResult<MsgIntercept> webQueryMsgInterceptList(Integer userId, String toUserId, int pageIndex, int pageSize,
															int type, String content) {
		PageResult<MsgIntercept> data = msgInferceptDAO.webQueryMsgInterceptList(userId, toUserId, pageIndex, pageSize, type, content);

		for(MsgIntercept keyWordIntercept : data.getData()){
			keyWordIntercept.setSenderName(userCoreService.getNickName(Integer.valueOf(keyWordIntercept.getSender())));
			if(!StringUtil.isEmpty(keyWordIntercept.getReceiver())){
				keyWordIntercept.setReceiverName(userCoreService.getNickName(Integer.valueOf(keyWordIntercept.getReceiver())));
			}else if(!StringUtil.isEmpty(keyWordIntercept.getRoomJid())){
				keyWordIntercept.setRoomName(roomManager.getRoomName(keyWordIntercept.getRoomJid()));
			}
		}
		return data;
	}
	
}

package com.shiku.im.mpserver.service.impl;

import com.shiku.common.model.PageVO;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.dao.TigaseMsgDao;
import com.shiku.im.mpserver.service.MPService;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MPServiceImpl implements MPService {

	@Autowired
	private TigaseMsgDao tigaseMsgDao;


	@Autowired
	private IMessageRepository messageRepository;




	Document getLastBody(int sender, int receiver) {
		return tigaseMsgDao.getLastBody(sender,receiver);
	}

	/**
	 *  消息分组分页查询
	 */
	@Override
	public PageVO getMsgList(int userId, int pageIndex, int pageSize) {
//		List<BasicDBObject> msgList = Lists.newArrayList();
//		DBCollection dbCollection = SKBeanUtils.getTigaseDatastore().getDB().getCollection("shiku_msgs");
//		// 分组条件
//		DBObject groupFileds =new BasicDBObject();
//		groupFileds.put("sender", "$sender");
//		// 过滤条件
//		Map<String, Integer> map =new HashMap<>();
//		map.put("receiver", userId);
//		map.put("direction", 0);
//		map.put("isRead", 0);
//		DBObject macth=new BasicDBObject("$match",new BasicDBObject(map));
//
//		DBObject fileds = new BasicDBObject("_id", groupFileds);
//		fileds.put("count", new BasicDBObject("$sum",1));
//		DBObject group = new BasicDBObject("$group", fileds);
//		DBObject limit=new BasicDBObject("$limit",pageSize);
//		DBObject skip=new BasicDBObject("$skip",pageIndex*pageSize);
		long total =0;
//		AggregationOutput out= dbCollection.aggregate(Arrays.asList(macth,group,skip,limit));
//		Iterable<DBObject> result=out.results();
//		List<DBObject> list=(List<DBObject>) result;
//
//		for(int i=0;i<list.size();i++){
//			try {
//				BasicDBObject dbObj=(BasicDBObject) list.get(i).get("_id");
//				dbObj.append("count", list.get(i).get("count"));
//				int sender = dbObj.getInt("sender");
//				int receiver = userId;
//				String nickname="";
//				if(null!=SKBeanUtils.getUserManager().getUser(sender))
//					nickname = SKBeanUtils.getUserManager().getUser(sender).getNickname();
//				else
//					continue;
//				int count = dbObj.getInt("count");
//
//				dbObj.put("nickname", nickname);
//				dbObj.put("count", count);
//				dbObj.put("sender", sender);
//				dbObj.put("receiver", receiver);
//				DBObject lastBody = getLastBody(sender, receiver);
//				dbObj.put("body", lastBody.get("content"));
//				String unescapeHtml3 = StringEscapeUtils.unescapeHtml3((String) lastBody.get("body"));
//				JSONObject body = JSONObject.parseObject(unescapeHtml3);
//				if (null != body.get("isEncrypt") && "1".equals(body.get("isEncrypt").toString())) {
//					dbObj.put("isEncrypt", 1);
//				} else {
//					dbObj.put("isEncrypt", 0);
//				}
//				dbObj.put("messageId", lastBody.get("messageId"));
//				dbObj.put("timeSend", lastBody.get("timeSend"));
//				msgList.add(dbObj);
//			} catch (ServiceException e) {
//				e.printStackTrace();
//			}catch (Exception e) {
//				e.printStackTrace();
//			}
//		}

//		return msgList;

		return new PageVO(tigaseMsgDao.getMsgList(userId,pageIndex,pageSize),total,pageIndex,pageSize);
	}

	@Override
	public Object getMsgList(int sender, int receiver, int pageIndex, int pageSize) {
		return tigaseMsgDao.getMsgList(sender,receiver,pageIndex,pageSize);
	}


	public List<Document> queryLastChatList(int userId ,long startTime, int pageSize) {
		//Integer userId = ReqUtil.getUserId();
		return tigaseMsgDao.queryLastChatList(userId,startTime,pageSize);

	}
}

package com.shiku.xmpppush.server;

import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.friends.service.FriendsManager;
import com.shiku.im.friends.service.FriendsRedisRepository;
import com.shiku.im.push.server.AbstractMessagePushService;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.imclient.BaseClientHandler;
import com.shiku.imclient.BaseClientListener;
import com.shiku.imclient.BaseIMClient;
import com.shiku.imserver.common.message.AuthMessage;
import com.shiku.imserver.common.message.ChatMessage;
import com.shiku.imserver.common.message.MessageHead;
import com.shiku.imserver.common.packets.ChatType;
import com.shiku.imserver.common.utils.StringUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import com.shiku.xmpppush.config.IMConfig;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;
import org.tio.core.ChannelContext;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

@Service
public class MessagePushService extends AbstractMessagePushService {


	private Map<String,Object> messageMap=new ConcurrentHashMap<>();


	@Autowired(required = false)
	protected IMConfig imConfig;


	@Autowired(required = false)
	protected FriendsRedisRepository friendsRedisRepository;

	@Autowired(required = false)
	protected FriendsManager friendsManager;


	@Autowired(required = false)
	protected UserRedisService userRedisService;



	private List<String> sysUserList=null;
	private synchronized List<String> getUserList(){
		if(null!=sysUserList)
			return sysUserList;


		sysUserList= Collections.synchronizedList(new ArrayList<String>());
		for (String string : systemAdminMap.keySet()) {
			sysUserList.add(string);
		}
		return sysUserList;
	}


	// ????????????
	private ConcurrentLinkedQueue<ChatMessage> queue = new ConcurrentLinkedQueue<ChatMessage>();

	@Override
	public void afterPropertiesSet() throws Exception {
		initThread();
	}




	public  void initThread(){
		ImPushQueueThread work =null;
		IMClient client=null;
		/*for(int i=0;i<getUserList().size();i++){
			if(getUserList().get(i)=="10000"){
				continue ;
			}*/
		try {
			client =getIMClient("10005");
		} catch (Exception e) {
			e.printStackTrace();
		}
		work=new ImPushQueueThread(client);
		work.start();
		/*}*/


	}

	public ChatMessage bulidChatMessage(MessageBean messageBean){
		ChatMessage message=null;
		MessageHead messageHead=null;
		try {
			message=new ChatMessage();
			messageHead=new MessageHead();
			if(!StringUtil.isEmpty(messageBean.getTo())){
				messageHead.setTo(messageBean.getTo());
			}else{
				messageHead.setTo(messageBean.getToUserId());
			}

			byte chatType= ChatType.CHAT;
			if(1==messageBean.getMsgType()) {
				chatType=ChatType.GROUPCHAT;
				messageHead.setTo(messageBean.getRoomJid());
				//messageBean.setToUserId(messageBean.getRoomJid());
			}else if(2==messageBean.getMsgType()) {
				chatType=ChatType.ALL;
			}

			messageHead.setChatType(chatType);
			if(null!=messageBean.getMessageId())
				messageHead.setMessageId(messageBean.getMessageId());
			else {
				messageHead.setMessageId(StringUtils.newStanzaId());
			}
			if(null!=messageBean.getContent())
				message.setContent(messageBean.getContent().toString());
			message.setFromUserId(messageBean.getFromUserId());
			message.setFromUserName(messageBean.getFromUserName());
			message.setToUserId(messageBean.getToUserId());
			message.setToUserName(messageBean.getToUserName());
			message.setType((short)messageBean.getType());

			//messageBean.setTimeSend(timeSend);
			if (null != messageBean.getTimeSend()) {
				message.setTimeSend((long) messageBean.getTimeSend());
			}

			if (null != messageBean.getObjectId()) {
				message.setObjectId(messageBean.getObjectId().toString());
			}
			if (null != messageBean.getFileName()) {
				message.setFileName(messageBean.getFileName());
			}
			message.setOther(messageBean.getOther());
			message.setMessageHead(messageHead);
		} catch (Exception e) {
			log.error(e.getMessage(),e);
		}
		return message;
	}


	private void setTimeSend(com.shiku.im.comm.model.MessageBean messageBean){
		if(null==messageBean.getTimeSend()){
			messageBean.setTimeSend((System.currentTimeMillis()));
		}
	}
	@Override
	public void onMessage(MessageBean messageBean) {
		ChatMessage message=null;

		String body=null;
		try {
			setTimeSend(messageBean);
			message=bulidChatMessage(messageBean);
			if(null==message) {
				return;
			}
			if(2==messageBean.getMsgType()){
				sendBroadCast(messageBean);
				return;
			}
			queue.offer(message);
		} catch (Exception e) {
			log.error("=== "+body+" ===> "+e.getMessage());
		}
	}

	/**
	 * ??????????????????
	 * @param body
	 */
	public void send(MessageBean body){
		try {

			// ???????????????queue?????????

		} catch (Exception e) {
			e.printStackTrace();
			log.error("??????????????????! ==="+e.getMessage());
		}
	}



	/**
	 * ??????????????????
	 * @param body
	 * @throws Exception
	 */
	public void sendGroup(MessageBean body)  {
        setTimeSend(body);
        ChatMessage message=bulidChatMessage(body);
        if(null!=message)
		try {

			// ???????????????queue?????????
			queue.offer(message);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("??????????????????!" + (null!=message?message.toString():""));
		}

	}

	@Override
	public void sendBroadCast(MessageBean messageBean){
		List<Integer> list;
		/*list = friendsRedisRepository.getFriendsUserIdsList(Integer.valueOf(messageBean.getFromUserId()));
		if(list.size()==0){
			list =friendsManager.queryFansId(Integer.valueOf(messageBean.getFromUserId()));
			//SKBeanUtils.getRedisService().saveFriendsUserIdsList(Integer.valueOf(messageBean.getFromUserId()),list);
		}*/

		if(Integer.valueOf(messageBean.getFromUserId())>10200){
			list = friendsRedisRepository.getFriendsUserIdsList(Integer.valueOf(messageBean.getFromUserId()));
			if(list.size()==0){
				list = friendsManager.queryFollowId(Integer.valueOf(messageBean.getFromUserId()));
				//SKBeanUtils.getRedisService().saveFriendsUserIdsList(Integer.valueOf(body.getFromUserId()),list);
			}
		}else{
			//list = userRedisService.getNoSystemNumUserIds();
			Query query = new Query().addCriteria(Criteria.where("_id").gt(10200));
			list=SKBeanUtils.getDatastore().findDistinct(query,"_id","user",Integer.class);
				//SKBeanUtils.getRedisService().saveNoSystemNumUserIds(list);


		}
		for(Integer userId:list){
			ChatMessage message=null;
			MessageHead messageHead=null;
			try {
				message=new ChatMessage();
				messageHead=new MessageHead();
				messageHead.setFrom(messageBean.getFromUserId());
				messageHead.setTo(userId.toString());
				messageHead.setChatType(ChatType.CHAT);
				message.setFromUserId(messageBean.getFromUserId());
				message.setFromUserName(messageBean.getFromUserName());
				message.setToUserId(userId.toString());
				message.setToUserName(messageBean.getToUserName());
				message.setType((short)messageBean.getType());

				message.setTimeSend(System.currentTimeMillis());
				message.setContent(messageBean.getContent().toString());
				if(null!=messageBean.getMessageId())
					messageHead.setMessageId(messageBean.getMessageId());
				else {
					messageHead.setMessageId(StringUtils.newStanzaId());
				}
				message.setMessageHead(messageHead);
				// ???????????????queue?????????
				queue.offer(message);
			} catch (Exception e) {
				log.error(e.getMessage(),e);


			}

		}
	}


	private IMClient getIMClient(String userId) {
		IMClient client=new IMClient();
		client.setUserId(userId);

		client.setPingTime(imConfig.getPingTime());

		BaseClientHandler clientHandler=new BaseClientHandler() {

			@Override
			public void handlerReceipt(String messageId) {
				//System.out.println("handlerReceipt ===> "+messageId);
				messageMap.remove(messageId);
			}
		};
		BaseClientListener clientListener=new BaseClientListener() {

			@Override
			public AuthMessage authUserMessage(ChannelContext channelContext, BaseIMClient client) {
				MessageHead messageHead=new MessageHead();

				messageHead.setChatType((byte)1);
				channelContext.userid=userId;
				messageHead.setFrom(userId+"/Server");

				AuthMessage authMessage=new AuthMessage();
				authMessage.setToken(imConfig.getServerToken());
				authMessage.setMessageHead(messageHead);
				return authMessage;
			}
		};

		client.initIMClient(imConfig.getHost(),imConfig.getPort(),clientHandler,clientListener);

		return client;
	}



	/**
	 * ??????Queue??????????????????
	 * @throws InterruptedException
	 */
	public void runQueuePush(IMClient client)
			throws Exception{
		ChatMessage message=queue.poll();

		if(message==null){
			return;
		}
		try {
			if(null==client)
				Thread.sleep(500);
			message.getMessageHead().setFrom(client.getUserId()+"/Server");
			ChatMessageVo messageVo=new ChatMessageVo();
			messageVo.setCreateTime(DateUtil.currentTimeSeconds());
			messageVo.setMessage(message);
			client.sendMessage(message);
			messageMap.put(message.getMessageHead().getMessageId(), messageVo);
			log.info("????????????????????? to {},",message.getToUserId());
		}  catch (Exception e) {
			queue.offer(message);
			log.error(e.getMessage(),e);
		}
	}



	/**
	 *
	 * @Description: TODO(????????????????????????????????????)
	 *
	 * @date 2018???12???26??? ??????11:26:22
	 * @version V1.0
	 */
	public class ImPushQueueThread extends Thread {
		private IMClient client=null;

		public ImPushQueueThread() {}

		public ImPushQueueThread(IMClient client) {
			this.client=client;
		}

		@Override
		public void run() {
			while (true) {
				if(!queue.isEmpty()){
					try {
						runQueuePush(client);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}else{
					try {
						Thread.sleep(100);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		}

	}


	@Getter
	@Setter
	public class ChatMessageVo {
		private long createTime;
		private ChatMessage message;
	}


	/**
	 * ????????????
	 * @throws InterruptedException
	 */
	/*public void timer(){
		new Thread(new Runnable() {

			@Override
			public void run() {
				while(true){
					Long startTime=System.currentTimeMillis();
					if(messageMap.size()>10){
						log.info("????????????"+DateUtil.currentTimeSeconds()+"   map??????   "+messageMap.size());
					}
					Set<Map.Entry<String, ChatMessageVo>> set=messageMap.entrySet();
					for (Map.Entry<String, ChatMessageVo> entry : set) {
						ChatMessageVo messageVo=entry.getValue();
						if(messageVo!=null){
							if(DateUtil.currentTimeSeconds()-messageVo.getCreateTime()>=30){
								queue.offer(messageVo.getMessage());
							}
						}else {
							return;
						}
					}

					Long endTime=System.currentTimeMillis();
					if((endTime-startTime)>1000){
						log.info("??????map??????????????????========"+(endTime-startTime));
					}
					try {
						Thread.sleep(30000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}

			}

		}).start();

	}*/
}

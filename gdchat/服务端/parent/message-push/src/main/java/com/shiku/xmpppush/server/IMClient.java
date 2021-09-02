package com.shiku.xmpppush.server;

import com.shiku.im.comm.model.MessageBean;
import com.shiku.imclient.BaseClientHandler;
import com.shiku.imclient.BaseClientListener;
import com.shiku.imclient.BaseIMClient;
import com.shiku.imserver.common.message.AuthMessage;
import com.shiku.imserver.common.message.ChatMessage;
import com.shiku.imserver.common.message.MessageHead;
import com.shiku.imserver.common.packets.ChatType;
import com.shiku.imserver.common.utils.StringUtils;
import com.shiku.utils.StringUtil;
import org.tio.core.ChannelContext;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledThreadPoolExecutor;

/**
 *
 *
 */
public class IMClient extends BaseIMClient{


	/**
	 *
	 * @param ip  IM 服务器Ip
	 * @param port IM 服务器端口
	 * @param clientHandler 客户端消息处理监听
	 * @param clientListener 客户端事件处理监听
	 */
    @Override
	public void initIMClient(String ip,int port,BaseClientHandler clientHandler,BaseClientListener clientListener) {
		
		try {
			setExecutor((ScheduledThreadPoolExecutor)Executors.newScheduledThreadPool(10));
			clientHandler.setImClient(this);
			clientListener.setImClient(this);
			setPingTime(80000);
			super.initIMClient(ip, port,clientHandler,clientListener);
		} catch (Exception e) {
			log.error(e.toString(), e);
		}
	}
	
	public void sendMessage(MessageBean messageBean) {
		ChatMessage message=new ChatMessage();
		MessageHead messageHead=new MessageHead();
		messageHead.setFrom("10005");

		byte chatType=ChatType.CHAT;
		if(0==messageBean.getMsgType()){
            if(StringUtil.isEmpty(messageBean.getTo()))
                messageHead.setTo(messageBean.getToUserId());
            else
                messageHead.setTo(messageBean.getTo());
        }else if(1==messageBean.getMsgType()) {
			chatType=ChatType.GROUPCHAT;
			messageHead.setTo(messageBean.getRoomJid());
		}else if(2==messageBean.getMsgType()) {
			chatType=ChatType.ALL;
		}
		
		messageHead.setChatType(chatType);
		messageHead.setMessageId(StringUtils.newStanzaId());
		
		message.setContent(messageBean.getContent().toString());
		message.setFromUserId(messageBean.getFromUserId());
		message.setFromUserName(messageBean.getFromUserName());
		message.setToUserId(messageBean.getToUserId());
		message.setToUserName(messageBean.getToUserName());
		message.setType((short)messageBean.getType());
		message.setObjectId(messageBean.getObjectId().toString());
		message.setFileName(messageBean.getFileName());
		message.setTimeSend(System.currentTimeMillis());
		message.setMessageHead(messageHead);
		sendMessage(message);
		
	}
	
	public static class ClientMessageHandler extends BaseClientHandler{
        @Override
		public void handlerReceipt(String messageId) {
			
		};
	}
	public static class ClientListener extends BaseClientListener{

		@Override
		public AuthMessage authUserMessage(ChannelContext arg0, BaseIMClient arg1) {
			// TODO Auto-generated method stub
			return null;
		}

		
		
	}
}

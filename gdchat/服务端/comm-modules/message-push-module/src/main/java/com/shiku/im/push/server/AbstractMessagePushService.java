package com.shiku.im.push.server;

import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.config.XMPPConfig;
import com.shiku.im.message.IMessageRepository;
import org.apache.commons.codec.digest.DigestUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.Resource;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public abstract class AbstractMessagePushService implements InitializingBean {

	protected final Logger log = LoggerFactory.getLogger(this.getClass());
	/**
	 * 获取系统号
	 */
	@Resource(name="systemAdminMap")
	protected Map<String,String> systemAdminMap;

	@Autowired
	protected IMessageRepository messageRepository;

	@Autowired(required = false)
	protected XMPPConfig xmppConfig;



	public void initSystemUser(){
		Map<String, String> systemMap = systemAdminMap;
		List<String> mapKeyList = new ArrayList<String>(systemMap.keySet());
		for(int i = 0; i < mapKeyList.size(); i++){
			try {
				messageRepository.registerSystemNo(mapKeyList.get(i), DigestUtils.md5Hex(systemMap.get(mapKeyList.get(i))));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	



	private byte[] generateId(String username) throws NoSuchAlgorithmException {
		MessageDigest md = MessageDigest.getInstance("SHA-256");
		return md.digest(username.getBytes());
	}

	public abstract void onMessage(MessageBean message);



	public abstract void sendGroup(MessageBean message);

	public abstract void sendBroadCast(MessageBean message);

	public abstract void send(MessageBean message);
}

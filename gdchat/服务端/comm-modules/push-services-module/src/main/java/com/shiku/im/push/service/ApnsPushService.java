package com.shiku.im.push.service;

import com.notnoop.apns.APNS;
import com.notnoop.apns.ApnsService;
import com.notnoop.apns.ApnsServiceBuilder;
import com.notnoop.apns.PayloadBuilder;
import com.shiku.im.push.autoconfigure.PushConfig;
import com.shiku.im.push.vo.MsgNotice;
import com.shiku.utils.StringUtil;
import org.springframework.core.io.ClassPathResource;

public class ApnsPushService extends PushServiceUtils{
	

	
	
	private static ApnsService apnsService;
	
	private static ApnsService betaApnsService;
	
	private static ApnsService viopService;
	
	
	private static ApnsServiceBuilder getApnsServiceBuilder(PushConfig pushConfig, ApnsHttp2PushService.PushEnvironment environment) {
		try {
			String pkpath=null;
			switch (environment) {
				case BETA:
					pkpath=pushConfig.getBetaApnsPk();
					break;
				case Pro:
					pkpath=pushConfig.getAppStoreApnsPk();
					break;
				case VOIP:
					pkpath=pushConfig.getVoipPk();
					break;
				default:
					break;
			}
			if(pkpath.startsWith("classpath:")) {
				ClassPathResource resource = new ClassPathResource(pkpath);
				String path = resource.getClassLoader().getResource(pkpath.replace("classpath:", "")).getPath();
				pkpath=path;
			}
			ApnsServiceBuilder builder =  APNS.newService().asPool(10)//.asBatched()
			.withCert(pkpath, pushConfig.getPkPassword());
			
			if(1==pushConfig.getIsApnsSandbox())
				builder.withSandboxDestination();
			else
				builder.withProductionDestination();
			
			return builder;
		} catch (Exception e) {
			log.error("getApnsClientBuilder Exception {} "+e.getMessage());
			return null;
		}
		
	}
	private static ApnsService getBataApnsService(){
		if (null==betaApnsService){
			PushConfig pushConfig=PushServiceUtils.pushConfig;
			synchronized (pushConfig) {
				if(null!=betaApnsService)
					return betaApnsService;
				
				ApnsServiceBuilder builder =getApnsServiceBuilder(pushConfig, ApnsHttp2PushService.PushEnvironment.BETA);
			   betaApnsService=builder.build();
				log.info("====getBataApnsService======》");
			}
		}
		return betaApnsService;
	}
	private static ApnsService getApnsService(){
		if (null==apnsService){
			PushConfig pushConfig=PushServiceUtils.pushConfig;
			synchronized (pushConfig) {
				if(null!=apnsService)
					return apnsService;
				ApnsServiceBuilder builder =getApnsServiceBuilder(pushConfig, ApnsHttp2PushService.PushEnvironment.Pro);
				apnsService=builder.build();
				log.info("====getApnsService======》");
			}
		}
		return apnsService;
	}
	private static ApnsService getVoipService(){
		if (null==viopService){
			PushConfig pushConfig=PushServiceUtils.pushConfig;
			synchronized (pushConfig) {
				if(null!=viopService)
					return viopService;
				ApnsServiceBuilder builder =getApnsServiceBuilder(pushConfig, ApnsHttp2PushService.PushEnvironment.VOIP);
				viopService=builder.build();
				log.info("====getViopService======》");
			}
		}
		return viopService;
	}
	
	public  static void pushMsgToUser(String token, MsgNotice notice, ApnsHttp2PushService.PushEnvironment env){
		
		String payload=null;
		
		PayloadBuilder builder = APNS.newPayload();
		/*String payload = APNS.newPayload()
		            .badge(3)
		            .customField("secret", "what do you think?")
		            .localizedKey("GAME_PLAY_REQUEST_FORMAT")
		            .localizedArguments("Jenna", "Frank")
		            .actionKey("Play").build();*/
		
		 builder.alertBody(notice.getText()+"");
		 builder.badge(notice.getMsgNum());
		 
		 builder.sound("default");
		 builder.customField("from",notice.getFrom()+"");
		 builder.customField("fromUserName",notice.getName());
		 builder.customField("messageType", notice.getType()+"");
		 builder.customField("to", notice.getTo()+"");
		 if(!StringUtil.isEmpty(notice.getRoomJid())){
				builder.customField("roomJid", notice.getRoomJid());
			 }
		  
		 /* if(120==notice.getType()||115==notice.getType()){
			  builder.customField("callNum", callNum);
		  }*/
	    
		  	/*
		            .localizedKey("localizedKey")
		            .alertBody("alertBody")
		            .localizedArguments("localizedArguments", "localizedArguments")*/
		  
		  payload =builder.build();
		           

		 //int now =  (int)(new Date().getTime()/1000);

		/* EnhancedApnsNotification notification = new EnhancedApnsNotification(EnhancedApnsNotification.INCREMENT_ID()  Next ID ,
		     now + 60 * 60  Expire in one hour ,
		     token  Device Token ,
		     payload);*/
		 try {
			log.info("{} apns push to > {}  {} ",notice.getMessageId(),notice.getTo(),token);
			 if(ApnsHttp2PushService.PushEnvironment.VOIP!=env) {
				 if(ApnsHttp2PushService.PushEnvironment.BETA!=env)
					 getApnsService().push(token, payload);
				 else
					 getBataApnsService().push(token, payload);
			 }else
				getVoipService().push(token, payload);
		} catch (Exception e) {
			log.error(" apns push error "+e.getMessage());
			e.printStackTrace();
		} 
		 
		
	}

	
	

}

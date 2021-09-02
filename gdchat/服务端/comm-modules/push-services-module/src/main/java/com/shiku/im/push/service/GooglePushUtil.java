package com.shiku.im.push.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

import org.springframework.core.io.ClassPathResource;

public class GooglePushUtil extends PushServiceUtils{
	
	public InputStream getJson() throws FileNotFoundException{
		if(pushConfig.getFCM_keyJson().startsWith("classpath:")) {
			ClassPathResource resource = new ClassPathResource(pushConfig.getFCM_keyJson());
			String path = resource.getClassLoader().getResource(pushConfig.getFCM_keyJson().replace("classpath:", "")).getPath();
			pushConfig.setFCM_keyJson(path);
			return this.getClass().getResourceAsStream(pushConfig.getFCM_keyJson());
		}
		return new FileInputStream(new File(pushConfig.getFCM_keyJson()));
	}
}

package com.shiku.im.push;

import com.shiku.im.push.model.KAdminProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
public class CommAutoConfiguration {

	
	@Autowired
	private KAdminProperties props;
	

	private static Map<String,String> dataConversion(Map<String, String> map,String[] data){
		for (String t : data) {
			String[] user = t.split(":");
			//System.out.println(user.toString());
			map.put(user[0], user[1]);
		}
		return map;
	}
}

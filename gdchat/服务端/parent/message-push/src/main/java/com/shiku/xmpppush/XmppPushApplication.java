package com.shiku.xmpppush;

import com.shiku.im.push.model.KAdminProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ApplicationContextEvent;

import java.util.HashMap;
import java.util.Map;


@Configuration
@EnableAutoConfiguration(exclude = { MongoAutoConfiguration.class, RedisAutoConfiguration.class,
		DataSourceAutoConfiguration.class, DataSourceTransactionManagerAutoConfiguration.class
		})
@ComponentScan(basePackages = {"cn.xyz","com.shiku"})
public class XmppPushApplication extends SpringBootServletInitializer implements ApplicationListener<ApplicationContextEvent>{
	
	@Autowired
	private KAdminProperties props;

	private static final Logger log = LoggerFactory.getLogger(XmppPushApplication.class);
	
	public static void main(String... args) {
		/**
		 * 内置Tomcat版本导致的 The valid characters are defined in RFC 7230 and RFC 3986 
		 * 修改 系统参数${spring-boot.version}
		 */
		try {
			System.setProperty("tomcat.util.http.parser.HttpParser.requestTargetAllow","|{}");
			System.setProperty("rocketmq.client.logLevel", "WARN");
			SpringApplication.run(XmppPushApplication.class, args);
			
			 log.info("xmpp推送服务启动成功...=======>");
		} catch (Exception e) {
			log.error("启动报错",e);
		}
		
		  
	}
	
	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		try {
			return application.sources(new Class[] { XmppPushApplication.class });
		} catch (Exception e) {
			log.error("启动报错",e);
			return null;
		}
		
	}
	
	@Override
	public void onApplicationEvent(ApplicationContextEvent event) {
		if(null!=event.getApplicationContext().getParent())
			 return;
		
	}
	
	@Bean(name = "systemAdminMap")
	public Map<String, String> systemAdminMap() {
		Map<String, String> systemAdminMap = new HashMap<>();
		return dataConversion(systemAdminMap, props.getSystemUsers().split(","));
	}
	
	private static Map<String,String> dataConversion(Map<String, String> map,String[] data){
		for (String t : data) {
			String[] user = t.split(":");
			//System.out.println(user.toString());
			map.put(user[0], user[1]);
		}
		return map;
	}
}

package com.shiku.im.push.autoconfigure;


import com.mongodb.*;
import com.shiku.im.push.service.PushServiceUtils;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.mongodb.springdata.MongoConfig;
import com.shiku.utils.StringUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.convert.MappingMongoConverter;

@Configuration
@EnableConfigurationProperties(MongoConfig.class)
public class CommAutoConfiguration {


	/*@Autowired
	private ApplicationProperties config;*/



	private MongoClient imRoomMongoClient;

	@Autowired(required=false)
	private MongoConfig mongoConfig;

	@Autowired(required=false)
	private PushConfig pushConfig;

	@Autowired(required=false)
	private UserCoreService userCoreService;

	@Autowired
	private MappingMongoConverter mappingMongoConverter;


	private MongoClientOptions options=null;
	public MongoClientOptions getMongoClientOptions() {
		if(null==options) {
			MongoClientOptions.Builder builder = MongoClientOptions.builder();
			builder.socketKeepAlive(true);
			builder.connectTimeout(mongoConfig.getConnectTimeout());
			builder.socketTimeout(mongoConfig.getSocketTimeout());
			builder.maxWaitTime(mongoConfig.getMaxWaitTime());
			builder.heartbeatFrequency(10000);// 心跳频率

			builder.readPreference(ReadPreference.nearest());
			options= builder.build();

		}
		return options;
	}


	//imRoom
	@Bean(name = "imRoomMongoClient", destroyMethod = "close")
	public MongoClient getImRoomMongoClient()  {
		try {
			PushServiceUtils.setPushConfig(pushConfig);
			PushServiceUtils.setUserCoreService(userCoreService);
			MongoCredential credential =null;
			//是否配置了密码
			if(!StringUtil.isEmpty(mongoConfig.getUsername())&&!StringUtil.isEmpty(mongoConfig.getPassword()))
				credential = MongoCredential.createScramSha1Credential(mongoConfig.getUsername(), mongoConfig.getRoomDbName(),
						mongoConfig.getPassword().toCharArray());
			MongoClientURI mongoClientURI=new MongoClientURI(mongoConfig.getUri());
			imRoomMongoClient = new MongoClient(mongoClientURI);
			return imRoomMongoClient;


		} catch (Exception e) {
			e.printStackTrace();
			return imRoomMongoClient;
		}


	}

	@Bean(name = "mongoTemplateForRoom")
	public MongoTemplate mongoTemplateForRoom() {
		//MongoTemplate	mongoTemplateForRoom = new MongoTemplate(new SimpleMongoDbFactory(getImRoomMongoClient(),mongoConfig.getRoomDbName()),mappingMongoConverter);
		MongoTemplate	mongoTemplateForRoom = new MongoTemplate(getImRoomMongoClient(),mongoConfig.getRoomDbName());

		return mongoTemplateForRoom;
	}



	
	

}

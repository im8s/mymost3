package com.shiku.im.mpserver.autoconfigure;

import com.mongodb.*;
import com.shiku.im.config.XMPPConfig;
import com.shiku.mongodb.springdata.MongoConfig;
import com.shiku.utils.StringUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.data.mongodb.core.MongoTemplate;

//@Configuration
public class KMongoAutoConfiguration {
	private MongoClient tigMongoClient;


	@Autowired(required=false)
	private MongoConfig mongoConfig;

	@Autowired(required=false)
	private XMPPConfig xmppConfig;

	/*@Autowired
	private MappingMongoConverter mappingMongoConverter;*/


	private  MongoClientOptions options=null;
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





	@Bean(name = "tigMongoClient", destroyMethod = "close")
	public MongoClient getTigMongoClient() {
		try {
			if(null==tigMongoClient){
				String dbUri=null;
				String dbName=null;
				String dbUserName=null;
				String dbPwd=null;
				if(null==xmppConfig) {
					dbUri=mongoConfig.getUri();
					dbName="tigase";
					dbUserName=mongoConfig.getUsername();
					dbPwd=mongoConfig.getPassword();
				}else {
					dbUri=xmppConfig.getDbUri();
					dbName=xmppConfig.getDbName();
					dbUserName=xmppConfig.getDbUsername();
					dbPwd=xmppConfig.getDbPassword();
				}
				MongoClientURI mongoClientURI = new MongoClientURI(dbUri);
				MongoCredential credential =null;
				//是否配置了密码
				if(!StringUtil.isEmpty(dbUserName)&&!StringUtil.isEmpty(dbPwd))
					credential = MongoCredential.createScramSha1Credential(dbUserName, dbName,
							dbPwd.toCharArray());
				tigMongoClient = new MongoClient(mongoClientURI);
				return tigMongoClient;
			}else
				return tigMongoClient;
		} catch (Exception e) {
			e.printStackTrace();
			return tigMongoClient;
		}

	}



	@Bean(name = "mongoTemplateForTigase")
	public MongoTemplate mongoTemplateForTigase() {
		//MongoTemplate mongoTemplateForTigase = new MongoTemplate(new SimpleMongoDbFactory(getTigMongoClient(),xmppConfig.getDbName()),mappingMongoConverter);
		MongoTemplate mongoTemplateForTigase = new MongoTemplate(getTigMongoClient(),xmppConfig.getDbName());
		return mongoTemplateForTigase;
	}




}

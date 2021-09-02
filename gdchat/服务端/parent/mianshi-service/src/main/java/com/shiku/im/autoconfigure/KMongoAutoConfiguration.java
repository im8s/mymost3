package com.shiku.im.autoconfigure;

import com.mongodb.*;
import com.shiku.im.config.XMPPConfig;
import com.shiku.im.constants.DBConstants;
import com.shiku.im.friends.entity.Friends;
import com.shiku.mongodb.springdata.MongoConfig;
import com.shiku.utils.StringUtil;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoDbFactory;
import org.springframework.data.mongodb.core.convert.DefaultMongoTypeMapper;
import org.springframework.data.mongodb.core.convert.MappingMongoConverter;
import org.springframework.data.mongodb.core.convert.MongoConverter;
import org.springframework.data.mongodb.core.query.Query;

@Configuration
@EnableConfigurationProperties(MongoConfig.class)
public class KMongoAutoConfiguration implements InitializingBean {

	



	@Autowired
	@Qualifier(value ="mongoClient")
	private MongoClient mongoClient;
	private MongoClient imRoomMongoClient;
	
	@Autowired(required=false)
	private MongoConfig mongoConfig;
	
	@Autowired(required=false)
	private XMPPConfig xmppConfig;

	@Autowired
	private MappingMongoConverter mappingMongoConverter;
	
	
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



	/*@Bean(name = "tigMongoClient", destroyMethod = "close")
	public MongoClient getTigMongoClient() {
		MongoClient tigMongoClient=null;
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

	}*/


	//imRoom
	@Bean(name = "imRoomMongoClient", destroyMethod = "close")
	public MongoClient getImRoomMongoClient()  {
		try {
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

	private MongoTemplate createMongoTemplate(MongoClient mongoClient,String dbname){
		//MongoTemplate	mongoTemplateForRoom = new MongoTemplate(new SimpleMongoDbFactory(mongoClient,dbname),mappingMongoConverter);

		MongoTemplate	mongoTemplate = new MongoTemplate(getImRoomMongoClient(),dbname);

		if (mongoTemplate.getConverter().getTypeMapper().isTypeKey("_class")) {
			((MappingMongoConverter) mongoTemplate.getConverter()).setTypeMapper(new DefaultMongoTypeMapper(null));
		}
		return mongoTemplate;
	}

	@Bean(name = "mongoTemplateForRoom")
	public MongoTemplate mongoTemplateForRoom() {
		MongoTemplate mongoTemplateForRoom=createMongoTemplate(getImRoomMongoClient(),mongoConfig.getRoomDbName());
		return mongoTemplateForRoom;
	}


	@Bean(name = "mongoTemplateFriends")
	public MongoTemplate mongoTemplateFriends() {
		MongoTemplate	mongoTemplateFriends = createMongoTemplate(mongoClient, DBConstants.FRIENDSDBNAME);
		return mongoTemplateFriends;
	}
	@Bean(name = "mongoNewFriends")
	public MongoTemplate mongoNewFriends() {
		MongoTemplate	mongoNewFriends = createMongoTemplate(mongoClient, DBConstants.NEWFIREND);

		return mongoNewFriends;
	}
	@Bean(name = "mongoTemplateContact")
	public MongoTemplate mongoTemplateContact() {
		MongoTemplate mongoTemplateContact = createMongoTemplate(mongoClient,"addressbook");

		return mongoTemplateContact;
	}
	@Bean(name = "mongoTemplateRoomMember")
	public MongoTemplate mongoTemplateRoomMember() {
		MongoTemplate mongoTemplateRoomMember =createMongoTemplate(mongoClient,"shiku_room_member");

		return mongoTemplateRoomMember;
	}
	@Bean(name = "mongoRoomMemberJid")
	public MongoTemplate mongoRoomMemberJid() {
		MongoTemplate mongoRoomMemberJid =createMongoTemplate(mongoClient,DBConstants.SHIKU_ROOMJIDS_USERID);

		return mongoRoomMemberJid;
	}

	@Bean(name = "mongoLiveMember")
	public MongoTemplate mongoLiveMember() {
		MongoTemplate mongoLiveMember =createMongoTemplate(mongoClient,"liveRoomMember");

		return mongoLiveMember;
	}


	@Override
	public void afterPropertiesSet() throws Exception {

	}
}

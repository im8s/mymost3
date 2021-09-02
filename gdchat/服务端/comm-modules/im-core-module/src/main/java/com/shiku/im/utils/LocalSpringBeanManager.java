package com.shiku.im.utils;

import com.mongodb.MongoClient;
import com.shiku.im.jedis.RedisCRUD;
import com.shiku.im.repository.CoreRedisRepository;
import com.shiku.im.repository.IMCoreRepository;
import com.shiku.im.service.IMCoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

/**
* @Description: TODO(单例类管理)
*
* @date 2018年7月21日 
*/
@Service
public class LocalSpringBeanManager {


	
	@Resource(name="mongoClient")
	@Qualifier(value = "mongoClient")
	private MongoClient mongoClient;

	public MongoClient getMongoClient() {
		return mongoClient;
	}


	@Autowired
	private MongoTemplate mongoTemplate;

	public  MongoTemplate getDatastore() {
		return mongoTemplate;
	}

	@Autowired(required = false)
	@Qualifier(value = "mongoTemplateForRoom")
	protected MongoTemplate dsForRoom;

	public MongoTemplate getRoomDatastore() {
		return dsForRoom;
	}



	@Autowired(required=false)
	private RedisCRUD redisCRUD;
	public RedisCRUD getRedisCRUD() {
		return redisCRUD;
	}


	@Autowired
	private IMCoreService imCoreService;

	@Autowired
	private IMCoreRepository imCoreRepository;


	@Autowired
	private CoreRedisRepository coreRedisRepository;

	public IMCoreRepository getImCoreRepository() {
		return imCoreRepository;
	}

	public CoreRedisRepository getCoreRedisRepository() {
		return coreRedisRepository;
	}

	public IMCoreService getImCoreService() {
		return imCoreService;
	}

}


package com.shiku.im.api;

import com.alibaba.fastjson.JSONObject;
import com.mongodb.BasicDBObject;

import com.shiku.im.admin.dao.ErrorMessageDao;
import com.shiku.im.admin.dao.PayConfigDao;
import com.shiku.im.admin.service.AdminManager;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.config.AppConfig;
import com.shiku.im.entity.PayConfig;
import com.shiku.im.message.MessageService;
import com.shiku.im.model.ErrorMessage;
import com.shiku.im.user.config.WXConfig;
import com.shiku.im.user.config.WXPublicConfig;
import com.shiku.im.user.dao.UserDao;
import com.shiku.im.user.entity.Role;
import com.shiku.im.user.service.UserHandler;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.user.utils.WXUserUtils;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.Md5Util;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.io.Resource;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;

/** @version:（1.0） 
* @ClassName	InitializationData
* @Description: （初始化数据） 
*
* @date:2018年8月25日下午4:07:23  
*/
@Component
@Slf4j
public class InitializationData  implements CommandLineRunner {
	
	
	
	@Value("classpath:data/message.json")
	private Resource resource;

	@Autowired
	private MongoTemplate mongoTemplate;

	@Autowired
    @Lazy
	private ErrorMessageDao errorMessageDao;

	@Autowired
	@Lazy
	private UserDao userDao;

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private AppConfig appConfig;

	@Autowired
	private WXConfig wxConfig;

	@Autowired
	private WXPublicConfig wxPublicConfig;
	
	@Autowired
    private MessageService messageService;
	

	@Autowired
	private UserHandler userHandler;

	@Autowired
	private PayConfigDao payConfigDao;
	@Autowired
	private AdminManager adminManager;

	@Autowired(required = false)
	private PaymentManager paymentManager;


	@Override
	public void run(String... args) throws Exception {


		ConstantUtil.setMongoTemplate(mongoTemplate);
		ConstantUtil.setAppConfig(appConfig);
		//AliPayUtil.setAppConfig(aliPayConfig);
		WXUserUtils.setConfig(wxConfig,wxPublicConfig);
		//HttpUtils.setWxConfig(wxConfig);

		if(1==appConfig.getOpenClearAdminToken())
			//启动时清空 redis 里的
			SKBeanUtils.getRedisCRUD().deleteKeysByPattern("adminToken:*");

		createDBIndex();

		initSuperAdminData();

		initErrorMassageData();

		initPayConfig();
		
	}

	private void createDBIndex(){
		try {
			BasicDBObject keys = new BasicDBObject();
			keys.put("loc", "2d");
			keys.put("nickname", 1);
			keys.put("sex", 1);
			keys.put("birthday", 1);
			keys.put("active", 1);

			mongoTemplate.getCollection("user").createIndex(keys);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	/**
       * 初始化异常信息数据
	* @throws Exception
	*/
	private void initErrorMassageData() throws Exception{
		if(null==resource) {
			System.out.println("error initErrorMassageData  resource is null");
			return;
		}
		//DBCollection errMsgCollection = getDatastore().getCollection(ErrorMessage.class);
		
		BufferedReader br = new BufferedReader(new InputStreamReader(resource.getInputStream()));
		StringBuffer message = new StringBuffer();
		String line = null;
		while ((line = br.readLine()) != null) {
			message.append(line);
		}
		String defaultString = message.toString();
		if(!StringUtil.isEmpty(defaultString)){
			List<ErrorMessage> errorMessages = JSONObject.parseArray(defaultString, ErrorMessage.class);
			errorMessages.stream().filter(msg->!StringUtil.isEmpty(msg.getCode())).forEach(errorMessage ->{
				ErrorMessage code = errorMessageDao.queryOne("code", errorMessage.getCode());
				if(null==code) {
					log.info("insert error msg {}",errorMessage.toString());
					errorMessageDao.save(errorMessage);
				}
			});
			
		}
		log.info(">>>>>>>>>>>>>>> 异常信息数据初始化完成  <<<<<<<<<<<<<");

		ConstantUtil.initMsgMap();
	}
	/**
        * 初始化默认超级管理员数据
	*/
	private void initSuperAdminData() {

		if (mongoTemplate.count(new Query(),Role.class) == 0) {
			try {
				// 初始化后台管理超级管理员
				userManager.addUser(1000, "1000");
				userHandler.registerToIM("1000", Md5Util.md5Hex("1000"));
				Role role = new Role(1000, "1000", (byte) 6, (byte) 1, 0);
				mongoTemplate.save(role);
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			// 初始化10000号
			try {
				userManager.addUser(10000, "10000");
				userHandler.registerToIM("10000", Md5Util.md5Hex("10000"));
			} catch (Exception e) {
				e.printStackTrace();
			}
			log.info("\n" + ">>>>>>>>>>>>>>> 默认管理员数据初始化完成  <<<<<<<<<<<<<");
		}
		
		if(userDao.getUser(1100)==null){
			// 初始化1100号 作为金钱相关通知系统号码
			try {
				userManager.addUser(1100, "1100");
				userHandler.registerToIM("1100", Md5Util.md5Hex("1100"));
			} catch (Exception e) {
				e.printStackTrace();
			}
			log.info("\n" + ">>>>>>>>>>>>>>> 默认系统通知数据初始化完成  <<<<<<<<<<<<<");
		}
		
		
	}

	private void initPayConfig(){
		PayConfig payConfig = payConfigDao.getPayConfig();
		if(null == payConfig){
			payConfig = adminManager.initPayConfig();
		}
//		ConstantUtil.setPayConfig(payConfig);
		SKBeanUtils.getImCoreService().setPayConfig(payConfig);
	}
}

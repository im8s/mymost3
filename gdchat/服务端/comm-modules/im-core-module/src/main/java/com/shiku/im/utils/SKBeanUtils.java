package com.shiku.im.utils;

import com.shiku.im.entity.Config;
import com.shiku.im.jedis.RedisCRUD;
import com.shiku.im.repository.CoreRedisRepository;
import com.shiku.im.repository.IMCoreRepository;
import com.shiku.im.service.IMCoreService;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

/**
* @Description: TODO(单例类获取   工具类)
*
* @date 2018年7月21日 
*/

@Component
public class SKBeanUtils implements ApplicationContextAware {
	
    private static ApplicationContext ctx;
    
    private static LocalSpringBeanManager localSpringBeanManager;

  	public static LocalSpringBeanManager getLocalSpringBeanManager() {
  		return localSpringBeanManager;
  	}

	public static MongoTemplate getDatastore() {
  		return localSpringBeanManager.getDatastore();
	}

	public MongoTemplate getRoomDatastore() {
		return localSpringBeanManager.getRoomDatastore();
	}
	@Override
    public void setApplicationContext(ApplicationContext arg0)throws BeansException {
        ctx = arg0;
        localSpringBeanManager=ctx.getBean(LocalSpringBeanManager.class);
        
        System.out.println("SKBeanUtils ===> init end  ===> localSpringBeanManager > "+localSpringBeanManager.getClass().getSimpleName());
    }

    public static Object getBean(String beanName) {
        if(ctx == null){
            throw new NullPointerException();
        }
        return ctx.getBean(beanName);
    }
	
  
	

	public static Config getSystemConfig() {
		return getImCoreService().getConfig();
	}
  



	
	public static RedisCRUD getRedisCRUD() {
		return getLocalSpringBeanManager().getRedisCRUD();
	}


	public static IMCoreRepository getImCoreRepository() {
		return getLocalSpringBeanManager().getImCoreRepository();
	}

	public static CoreRedisRepository getCoreRedisRepository() {
		return getLocalSpringBeanManager().getCoreRedisRepository();
	}
	public static IMCoreService getImCoreService() {
		return getLocalSpringBeanManager().getImCoreService();
	}



}


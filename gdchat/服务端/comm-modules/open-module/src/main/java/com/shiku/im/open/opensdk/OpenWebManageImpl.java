package com.shiku.im.open.opensdk;

import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
@Service
public class OpenWebManageImpl extends MongoRepository<SkOpenApp, ObjectId> {



	@Override
	public Class<SkOpenApp> getEntityClass() {
		// TODO Auto-generated method stub
		return SkOpenApp.class;
	}


	
	/**
	 * 申请获取权限
	 * @param skOpenWeb
	 */
	public void openAccess(SkOpenApp skOpenWeb){
		Query query=createQuery("_id",skOpenWeb.getId());
		if(!StringUtil.isEmpty(skOpenWeb.getAccountId()))
			addToQuery(query,"accountId",skOpenWeb.getAccountId());
		Update ops=createUpdate();
		if(skOpenWeb.getIsAuthShare()!=0)
			ops.set("isAuthShare", skOpenWeb.getIsAuthShare());
		if(skOpenWeb.getIsAuthLogin()!=0)
			ops.set("isAuthLogin", skOpenWeb.getIsAuthLogin());
		if(skOpenWeb.getIsAuthPay()!=0){
			ops.set("isAuthPay", skOpenWeb.getIsAuthPay());
			ops.set("payCallBackUrl", skOpenWeb.getPayCallBackUrl());
		}
			
		update(query, ops);
	}
	
	// 校验网页APP
	public SkOpenApp checkWebAPPByAppId(String appId){
		return findOne("appId",appId);
	}
}

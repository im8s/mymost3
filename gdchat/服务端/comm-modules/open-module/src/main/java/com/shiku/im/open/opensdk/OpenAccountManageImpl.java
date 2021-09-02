package com.shiku.im.open.opensdk;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.LoginPassword;
import com.shiku.im.open.opensdk.entity.SkOpenAccount;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;


@Service(value="openAccountManage")
public class OpenAccountManageImpl extends MongoRepository<SkOpenAccount,ObjectId> {


	@Autowired
	private UserCoreService userCoreService;

	@Override
	public Class<SkOpenAccount> getEntityClass() {
		return SkOpenAccount.class;
	}
	/*public Object loginAccount(String account,String password) {
		Object result=null;
		if(account.contains("@")) {
			
			
		}else {
			result=loginUserAccount(account, password);
		}
	}*/
	
	
	
	public SkOpenAccount loginUserAccount(String telephone,String password) {
		SkOpenAccount account=null;
		User user = null;
		try {
			account=queryOne("telephone", telephone);
			if(null==account){
				user= userCoreService.getUser(telephone);
				if(!user.getPassword().equals(password)){
					password= LoginPassword.encodeFromOldPassword(password);
					if(!user.getPassword().equals(password)){
						throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);
					}
				}
				//request.getSession().setAttribute("openadmin", user);
				account = queryOne("userId", user.getUserId());
				 account=new SkOpenAccount();
				 account.setUserId(user.getUserId());
				 account.setCreateTime(DateUtil.currentTimeSeconds());
				 account.setTelephone(user.getTelephone());
				 account.setPassword(user.getPassword());
				 account.setId(new ObjectId());
				 save(account);
			}
			if(null!=account.getStatus()){
				if(account.getStatus()==-1)
					throw new ServiceException("该账号已被禁用");
			}

			// 账号密码登录
			if (!password.equals(account.getPassword()) ){
				password= LoginPassword.encodeFromOldPassword(password);
				if(!password.equals(account.getPassword()))
					throw new ServiceException(KConstants.ResultCode.AccountOrPasswordIncorrect);
			}
			return account;
		} catch (ServiceException e) {
			throw e; 
		}catch (Exception e) {
			logger.error(e.getMessage(),e);
			return account;
		}
		
		
	}
	
	/**
	 * 完善个人资料
	 * @param skOpenAccount
	 */
	public void perfectUserInfo(SkOpenAccount skOpenAccount){
		Query query=createQuery("userId",skOpenAccount.getUserId());
		Update ops=createUpdate();
		if(!StringUtil.isEmpty(skOpenAccount.getMail()))
			ops.set("mail", skOpenAccount.getMail());
		if(!StringUtil.isEmpty(skOpenAccount.getIdCard()))
			ops.set("idCard", skOpenAccount.getIdCard());
		if(!StringUtil.isEmpty(skOpenAccount.getTelephone()))
			ops.set("telephone", skOpenAccount.getTelephone());
		if(!StringUtil.isEmpty(skOpenAccount.getAddress()))
			ops.set("address", skOpenAccount.getAddress());
		if(!StringUtil.isEmpty(skOpenAccount.getRealName()))
			ops.set("realName", skOpenAccount.getRealName());
		if(!StringUtil.isEmpty(skOpenAccount.getCompanyName()))
			ops.set("companyName", skOpenAccount.getCompanyName());
		if(!StringUtil.isEmpty(skOpenAccount.getBusinessLicense()))
			ops.set("businessLicense", skOpenAccount.getBusinessLicense());
		
		update(query, ops);
	}
	
	/**
	 * 修改密码
	 * @param userId
	 * @param oldPassword
	 * @param newPassword
	 * @throws Exception 
	 */
	public void updatePassword(Integer userId,String oldPassword,String newPassword) throws Exception{
		Query query=createQuery("userId",userId);
		Update ops=createUpdate();
		SkOpenAccount one = findOne(query);
		if(one.getPassword().equals(oldPassword)){
			ops.set("password",newPassword);
		}else{
			oldPassword= LoginPassword.encodeFromOldPassword(oldPassword);
			if(!one.getPassword().equals(oldPassword)){
				throw new ServiceException(KConstants.ResultCode.OldPasswordIsWrong);
			}
			ops.set("password",newPassword);
		}
		update(query, ops);
	}
	
	/**
	 * 校验用户信息
	 * @param telephone
	 * @param password
	 * @return
	 */
	public SkOpenAccount ckeckOpenAccount(String telephone,String password){
		Query query=createQuery("telephone",telephone);
		SkOpenAccount openAccount = null;
		SkOpenAccount one = findOne(query);
		if(null != one){
			if(!password.equals(one.getPassword())){
				password= LoginPassword.encodeFromOldPassword(password);
				if(password.equals(one.getPassword())){
					openAccount = one;
				}
			}else{
				openAccount = one;
			}
		}
		return openAccount;
	}
	
	/**
	 * 获取用户信息
	 * @param userId
	 * @return
	 */
	public SkOpenAccount getOpenAccount(Integer userId){
		return findOne("userId",userId);
	}
	
	/**
	 * 申请成为开发者
	 * @param userId
	 * @param status
	 */
	public void applyDeveloper(Integer userId,int status){
		Query query=createQuery("userId",userId);
		Update ops=createUpdate();
		ops.set("status", status);
		ops.set("modifyTime", DateUtil.currentTimeSeconds());
		update(query, ops);
	}
	
	/**
	 * 开发者列表
	 * @param pageIndex
	 * @param pageSize
	 * @param status
	 * @return
	 */
	public PageResult<SkOpenAccount> developerList(int pageIndex,int pageSize,int status,String keyWorld){
		Query query=createQuery();
		if(status!=-2){
			addToQuery(query,"status",status);
		}
		if(!StringUtil.isEmpty(keyWorld)){
			Criteria criteria = createCriteria().orOperator(contains("userId", keyWorld), contains("telephone", keyWorld));
			query.addCriteria(criteria);
		}
		descByquery(query,"createTime");
		PageResult<SkOpenAccount> data=new PageResult<>();
		data.setCount(count(query));
		data.setData(queryListsByQuery(query,pageIndex, pageSize, 1));
		return data;
	}
	
	public void deleteDeveloper(ObjectId id){
		deleteById(id);
	}
	
	/**
	 * 审核开发者
	 * @param id
	 * @param status
	 */
	public void checkDeveloper(ObjectId id,int status){
		Query query=createQuery(id);
		Update ops=createUpdate();
		ops.set("status", status);
		ops.set("verifyTime", DateUtil.currentTimeSeconds());
		update(query, ops);
		
	}


}

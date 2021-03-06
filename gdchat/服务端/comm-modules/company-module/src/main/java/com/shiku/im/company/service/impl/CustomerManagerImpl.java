package com.shiku.im.company.service.impl;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.company.CompanyConstants;
import com.shiku.im.company.dao.CommonTextDao;
import com.shiku.im.company.dao.CustomerDao;
import com.shiku.im.company.dao.EmployeeDao;
import com.shiku.im.company.entity.CommonText;
import com.shiku.im.company.entity.Customer;
import com.shiku.im.company.service.CustomerManager;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.service.UserCoreRedisRepository;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.service.UserHandler;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.lang3.RandomUtils;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomerManagerImpl implements CustomerManager {

	@Autowired
	private CustomerDao customerDao;
	@Autowired
	private EmployeeDao employeeDao;
	@Autowired
	private CommonTextDao commonTextDao;
	
	@Autowired
	private UserCoreService userCoreService;
	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;


	@Autowired
	private UserHandler userHandler;
	@Override
	public Map<String, Object> registerUser(String ip) {

		String companyId = SKBeanUtils.getSystemConfig().getCustomer_companyId();
		String departmentId = SKBeanUtils.getSystemConfig().getCustomer_departmentId();
		if(StringUtil.isEmpty(companyId) || StringUtil.isEmpty(departmentId)){
			throw new ServiceException(CompanyConstants.ResultCode.NoCompanyIdOrDepartmentId);
		}

		Map<String, Object> data = new HashMap<String, Object>();
		Integer customerId = 0;
//		customerId = getCustomerRepository().findUserByIp(ip);
		ip=DigestUtils.md5Hex(ip);

		customerId = customerDao.findUserByIp(ip);
		if (customerId!=null && customerId!=0){ //??????ip?????????????????????
			try {
				//2??????????????????????????????
				data = userCoreRedisRepository.loginSaveAccessToken(customerId,customerId,null);
				data.put("customerId", customerId);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}else{ //????????????
            ip=DigestUtils.md5Hex(ip);
			//??????userId
			customerId = userCoreService.createUserId();
			Customer customer = new Customer();
			customer.setCustomerId(customerId);
			customer.setIp(ip);
			customer.setCompanyId(companyId);

			customer.setUserKey( DigestUtils.md5Hex(customer.getIp()));
			customer.setCreateTime(DateUtil.currentTimeSeconds());
			// ????????????
			//data = getCustomerRepository().addCustomer(customer);
			customerDao.addCustomer(customer);
			try {
				//2??????????????????????????????
				data = userCoreRedisRepository.loginSaveAccessToken(customer.getCustomerId(),customer.getCustomerId(), null);
				data.put("customerId", customer.getCustomerId());
				//data.put("nickname",jo.getString("nickname"));

				KSession session = new KSession(customerId,"zh","web");
				session.setAccessToken((String) data.get("access_token"));
				session.setHttpKey(com.shiku.utils.Base64.encode(RandomUtils.nextBytes(16)));
				userCoreRedisRepository.saveUserSesson(session);
				data.put("httpKey", session.getHttpKey());

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		//???????????????
		Integer serviceId =  allocation(companyId,departmentId);
		if (null != data) {
			data.put("serviceId", serviceId);
			try {
				//?????????tigsae
				userHandler.registerToIM(customerId.toString(), DigestUtils.md5Hex(customerId.toString()));
			} catch (Exception e){
				e.printStackTrace();
			}
			return data;
		}
		throw new ServiceException(KConstants.ResultCode.FailedRegist);
	}
	
	
	
	/**
	 * ???????????????
	 * @param companyId
	 * @param departmentId
	 * @return
	 */
	public synchronized Integer  allocation(String companyId,String departmentId) {    
		ObjectId compId = new ObjectId(companyId);
		ObjectId departId = new ObjectId(departmentId);
		//???????????????????????????????????????????????????   map  key???userId  value:????????????????????????
//		Map<Integer,Integer> map = getCustomerRepository().findWaiter(compId, departId);
		Map<Integer,Integer> map = employeeDao.findWaiter(compId,departId);
		int minValue = -1; //????????????map????????????value???
		int minKey = 0; //???????????????value?????????key
		
		for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
			if(userCoreService.getOnlinestateByUserId(entry.getKey())==0){ //?????????????????????0  ?????? 1
				continue;
			}else{
				
				if(minValue == -1){ //??????????????????value????????????maxValue
					minValue = entry.getValue();
					minKey = entry.getKey();
				}
				if(entry.getValue()==0){ //??????????????????????????????0????????????????????????
					minValue = entry.getValue();
					minKey = entry.getKey();
					break;
				}
				if(entry.getValue()<minValue){ //?????????????????????????????????????????????
					minValue = entry.getValue();
					minKey = entry.getKey();
				}
				
			}	
		}
		
		return minKey;
		
	}





	/**
	 * ???????????????
	 */
	@Override
	public CommonText commonTextAdd(CommonText commonText) {
		if (!StringUtil.isEmpty(commonText.toString())) {
//			getCustomerRepository().commonTextAdd(commonText);
			commonTextDao.addCommonText(commonText);
			return commonText;
		}else{
			// ????????????????????????
			throw new ServiceException(KConstants.ResultCode.AddFailure);
		}
	}


	/**
	 * ???????????????
	 */
	@Override
	public boolean deleteCommonTest(String commonTextId) {
//		boolean a = getCustomerRepository().deleteCommonText(commonTextId);
		boolean a = commonTextDao.deleteCommonText(commonTextId);
		if (true == a) {
			return true;
		}else {
			// ????????????????????????
			throw new ServiceException(KConstants.ResultCode.DeleteFailure);
		}
	}

	/**
	 * ????????????id???????????????
	 */
	@Override
	public List<CommonText> commonTextGetByCompanyId(String companyId, int pageIndex, int pageSize) {
//		List<CommonText> commonTextList = getCustomerRepository().commonTextGetByCommpanyId(companyId, pageIndex, pageSize);
		List<CommonText> commonTextList = commonTextDao.commonTextGetByCommpanyId(companyId,pageIndex,pageSize);
		return commonTextList;
		
	}
	
	/**
	 * ??????userId ???????????????
	 */
	@Override
	public List<CommonText> commonTextGetByUserId(int userId, int pageIndex, int pageSize) {
//		List<CommonText> commonTextList = getCustomerRepository().commonTextGetByUserId(userId,  pageIndex,  pageSize);
		List<CommonText> commonTextList = commonTextDao.commonTextGetByUserId(userId,pageIndex,pageSize);
	    return commonTextList;
	}
	

	/**
	 * ???????????????
	 */
	@Override
	public CommonText commonTextModify(CommonText commonText) {
		if (null!=commonTextDao.commonTextModify(commonText)) {
			return commonText;
		}else {
			// ????????????????????????
			throw new ServiceException(0);
		}
	}



	@Override
	public User getUser(String customerId) {
		
		return null;
	}

	
	

}
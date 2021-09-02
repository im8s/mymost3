package com.shiku.im.user.service;


import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.user.dao.RoleDao;
import com.shiku.im.user.entity.Role;
import com.shiku.im.utils.SKBeanUtils;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class RoleCoreService {

	@Autowired
	private RoleDao roleDao;
	public RoleDao getRoleDao(){
		return roleDao;
	}
	@Autowired
	private UserCoreService userCoreService;


	@Autowired
	private UserCoreRedisRepository userCoreRedisRepository;




	public int getUserRoleByUserId(Integer userId){
		Object roleQuery = getRoleDao().queryOneField("role", new Document("userId", userId));
		return null == roleQuery ? 0 : (int) roleQuery;
	}

	public Role getUserRole(Integer userId,String phone,Integer type){
		Role role = getRoleDao().getUserRole(userId,phone,type);
		return role;
	}

	public List<Role> getUserRoles(Integer userId,String phone,Integer type){
		return getRoleDao().getUserRoleList(userId,phone,type);
	}

	public List<Integer> getUserRoles(Integer userId){
		List<Integer> roleType = new ArrayList<Integer>();
		List<Role> asList = getRoleDao().getUserRoleList(userId,null,null);
		asList.forEach(role -> {
			roleType.add((int) role.getRole());
		});
		return roleType;
	}


	
	private String promotionUrl(Integer userId){
		/**
		 * 示例：http://www.duoyewu.com/tn/?pid=10000&com=2
			pid后面的数字是你的推广ID,该ID很重要。
			com后面的数字有3个参数：
			1. 直接跳转到招商页面
			2. 直接跳转到首页
			3 .直接跳转到注册页面
		 */
		String promotionUrl = SKBeanUtils.getSystemConfig().getPromotionUrl();
		if(StringUtil.isEmpty(promotionUrl))
			throw new ServiceException("请先在后台管理中设置在线咨询链接");
		return new StringBuffer().append(promotionUrl).append(userId).toString();
	}
	


	public void deleteAllRoles(Integer userId){
		getRoleDao().deleteRole(userId);
	}
}

package com.shiku.im.api.controller;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.config.AppConfig;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.NearbyUser;
import com.shiku.im.user.service.impl.UserManagerImpl;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

/**
 * 附近接口
 * 
 *
 *
 */
@Api(value="NearbyController",tags="附近接口")
@RestController
@RequestMapping(value="/nearby",method={RequestMethod.GET,RequestMethod.POST})
public class NearbyController {

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private AppConfig appConfig;

	//附近的用户
	@ApiOperation("附近的用户")
	@RequestMapping(value = "/user")
	public JSONMessage nearbyUser(@ModelAttribute NearbyUser poi) {
		try {
			if(StringUtil.isEmpty(poi.getNickname())){
				byte disableNearbyUser =appConfig.getDisableNearbyUser();
				if(1==disableNearbyUser){
					if(0==poi.getPageIndex()){
						User user =userManager.getUser("8618938880001");
						if(null!=user){
							List<User> dataList=new ArrayList<>();
							user.buildNoSelfUserVo(ReqUtil.getUserId());
							user.setLoc(new User.Loc(poi.getLongitude(),poi.getLatitude()));
							dataList.add(user);
							return JSONMessage.success(dataList);
						}
					}else{
						 return JSONMessage.success(new ArrayList<>());
					}

				}
			}
			List<User> nearbyUser=userManager.nearbyUser(poi);
				return JSONMessage.success(nearbyUser);
			
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
	}
	
	
	//附近的用户（用于web版分页）
	@ApiOperation("附近的用户")
	@RequestMapping(value = "/nearbyUserWeb")
	public JSONMessage nearbyUserWeb(@ModelAttribute NearbyUser poi) {
		try {
			Object nearbyUser =userManager.nearbyUserWeb(poi);
			return JSONMessage.success(nearbyUser);
		} catch (Exception e) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.UserNotExist);
		}
		
	}
	
	
	//最新的用户
	@RequestMapping("/newUser")
	@ApiOperation("最新的用户")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="String")
	})
	public JSONMessage newUser(@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="12") int pageSize,@RequestParam(defaultValue="0") int isAuth) {
		JSONMessage jMessage = null;
		try {
			String phone =userManager.getUser(ReqUtil.getUserId()).getPhone();
			if(!StringUtil.isEmpty(phone) && !phone.equals("18938880001")) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
			}
			List<User> dataList =userManager.getUserlimit(pageIndex, pageSize,isAuth);
			if(null != dataList && dataList.size()>0){
				User.LoginLog loginLog=null;
				for (User user : dataList) {
					loginLog=userManager.getLogin(user.getUserId());
					user.setLoginLog(loginLog);
				}
				jMessage = JSONMessage.success(null,dataList);
			}
		} catch (ServiceException e) {
			return  JSONMessage.failureByException(e);
		}

		return jMessage;
	}
	
}

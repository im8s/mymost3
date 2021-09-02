package com.shiku.im.api.controller;

import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.friends.entity.AddressBook;
import com.shiku.im.friends.service.impl.AddressBookManagerImpl;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@ApiIgnore
@Api(value=" AddressBookController",tags="通讯录好友接口")
@RestController
@RequestMapping(value="",method={RequestMethod.GET,RequestMethod.POST})
public class AddressBookController extends AbstractController {

	@Autowired
	private AddressBookManagerImpl addressBookManager;

	@Autowired
	private UserCoreService userCoreService;

	@ApiOperation("添加通讯录")
	@RequestMapping(value = "/addressBook/upload")
	public JSONMessage upload(HttpServletRequest request, @RequestParam(defaultValue="")String deleteStr, @RequestParam(defaultValue="")String uploadStr, @RequestParam(defaultValue="")String uploadJsonStr){
		Integer userId = ReqUtil.getUserId();
		List<AddressBook> uploadTelephone = null;
		/*配置客户端不显示通讯录好友功能 不需要上传通讯录*/
		if(0== KSessionUtil.getClientConfig().getShowContactsUser()){
			return JSONMessage.success();
		}
		if(StringUtil.isEmpty(deleteStr) && StringUtil.isEmpty(uploadStr) && StringUtil.isEmpty(uploadJsonStr))
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsLack);
		if(!StringUtil.isEmpty(uploadStr) && !StringUtil.isEmpty(uploadJsonStr))
			return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsLack);
		User user =userCoreService.getUser(userId);
		uploadTelephone = addressBookManager.uploadTelephone(user,deleteStr, uploadStr, uploadJsonStr);
		return JSONMessage.success(null,uploadTelephone);
	}
	
	
	/** @Description:（查询通讯录好友） 
	* @param pageIndex
	* @param pageSize
	* @return
	**/ 
	@ApiOperation("查询通讯录好友")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="当前页大小",dataType="int",required=true)
	})
	@RequestMapping(value = "/addressBook/getAll")
	public JSONMessage getAll(@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="20") int pageSize) {
		/*配置客户端不显示通讯录好友功能 */
		if(null != KSessionUtil.getClientConfig()){
			if(0 == KSessionUtil.getClientConfig().getShowContactsUser()){
				return JSONMessage.success();
			}
		}
		Integer userId = ReqUtil.getUserId();
		User user = userCoreService.getUser(userId);
		List<AddressBook> data=addressBookManager.getAll(user.getUserId(),pageIndex, pageSize);
		if(null==data){
			return JSONMessage.failureByErrCode(KConstants.ResultCode.NotAdressBookFriends);
		}else {
			return JSONMessage.success(data);
		}
			
	}
	/** @Description:（查询已注册的通讯录好友） 
	* @param pageIndex
	* @param pageSize
	* @return
	**/
	@ApiOperation("查询已注册的通讯录好友")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="access_token" , value="授权钥匙",dataType="String",required=true),
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="当前页大小",dataType="int",required=true)
	})
	@RequestMapping(value = "/addressBook/getRegisterList")
	public JSONMessage getRegisterList(@RequestParam(defaultValue="0") int pageIndex,@RequestParam(defaultValue="20") int pageSize) {
		/*配置客户端不显示通讯录好友功能 */
		if(0== KSessionUtil.getClientConfig().getShowContactsUser()){
			return JSONMessage.success();
		}
		List<AddressBook> data=addressBookManager.findRegisterList(ReqUtil.getUserId(), pageIndex, pageSize);
		return JSONMessage.success(data);
	}
	

}

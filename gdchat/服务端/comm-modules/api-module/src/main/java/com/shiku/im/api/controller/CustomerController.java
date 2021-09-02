package com.shiku.im.api.controller;

import com.shiku.im.api.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.company.entity.CommonText;
import com.shiku.im.company.service.CustomerManager;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
/**
 * 
 *
 *
 */

@Api(value="CustomerController",tags="客服相关操作接口")
@RestController
@RequestMapping(value="/CustomerService",method={RequestMethod.GET,RequestMethod.POST})
public class CustomerController extends AbstractController {
	private static Logger logger = LoggerFactory.getLogger(CustomerController.class);
	
	@Autowired
	private CustomerManager customerManager;
	/**
	 * 客服模块-客户注册
	 * @return
	 */
	@ApiOperation("客服模块-客户注册")
	@RequestMapping(value = "/register")
	public JSONMessage customerRegister() {

		String requestIp = getRequestIp(); //获取注册用户ip地址
		//String macAddress = getMACAddress(requestIp);   //根据ip获取用户mac地址
		Object data = customerManager.registerUser(requestIp);
		return JSONMessage.success(data);
	}
	
	/**
	* @Title: commonTextAdd
	* @Description: 创建常用语
	* @param @param commonText
	* @param @return    参数
	* @return JSONMessage    返回类型
	* @throws
	*/
	@ApiOperation("创建常用语")
	@RequestMapping("/commonText/add")
	public JSONMessage commonTextAdd( CommonText commonText){

		try {
			if (!StringUtil.isEmpty(commonText.toString())) {
				commonText = customerManager.commonTextAdd(commonText);
				return JSONMessage.success("", commonText);
			}else{
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			}
		} catch (Exception e) {
			logger.error("添加关键字失败 ==> " + e.getStackTrace());
			return JSONMessage.failure(e.getMessage());
		}
	}

	/**
	* @Title: deleteCommonText
	* @Description: 删除常用语
	* @param @param commonTextId
	* @param @return    参数
	* @return JSONMessage    返回类型
	* @throws
	*/
	@ApiOperation("删除常用语")
	@ApiImplicitParam(paramType="query" , name="commonTextId" , value="常用语Id",dataType="String",required=true)
	@RequestMapping("/commonText/delete")
	public JSONMessage deleteCommonText(@RequestParam String commonTextId){

		try {
			customerManager.deleteCommonTest(commonTextId);
			return JSONMessage.success();

		} catch (Exception e) {
			logger.error("删除关键字失败 ===> "+ e.getStackTrace());
			return JSONMessage.failureByException(e);
		}
	}
	
	/**
	* @Title: commonTextGet
	* @Description: 根据公司id查询常用语
	* @param @param companyId
	* @param @param pageIndex
	* @param @param pageSize
	* @param @return    参数
	* @return JSONMessage    返回类型
	* @throws
	*/
	@ApiOperation("根据公司id查询常用语")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="companyId" , value="公司Id",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="当前页数据量",dataType="int",required=true,defaultValue = "10")
	})
	@RequestMapping("/commonText/get")
	public JSONMessage commonTextGetByCompanyId(@RequestParam String companyId,@RequestParam(defaultValue = "0") int pageIndex,@RequestParam(defaultValue = "10") int pageSize){

		try {
			List<CommonText> commonTextList = customerManager.commonTextGetByCompanyId(companyId, pageIndex, pageSize);

			return JSONMessage.success(commonTextList);

		} catch (Exception e) {
			logger.error("查询常用语失败 ===> "+e.getStackTrace());
			return JSONMessage.failureByException(e);
		}
	}
	
	/**
	* @Title: commonTextGetByUserId
	* @Description: 根据userId查询常用语
	* @param @param pageIndex   页码
	* @param @param pageSize    每页数量
	* @param @return    参数
	* @return JSONMessage    返回类型
	* @throws
	*/
	@ApiOperation("根据userId查询常用语")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页",dataType="int",required=true,defaultValue = "0"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="当前页数据量",dataType="int",required=true,defaultValue = "10")
	})
	@RequestMapping("/commonText/getByUserId")
	public JSONMessage commonTextGetByUserId(@RequestParam(defaultValue = "0") int pageIndex,@RequestParam(defaultValue = "10") int pageSize){

		try {
			List<CommonText> commonTextList = customerManager.commonTextGetByUserId(ReqUtil.getUserId(), pageIndex, pageSize);

			return JSONMessage.success(commonTextList);

		} catch (Exception e) {
			logger.error("查询常用语失败 ===> "+ e.getStackTrace());
			return JSONMessage.failureByException(e);
		}
	}

	/**
	* @Title: commonTextModify
	* @Description: 修改常用语
	* @param @param commonText
	* @param @return    参数
	* @return JSONMessage    返回类型
	* @throws
	*/
	@ApiOperation("修改常用语")
	@RequestMapping("/commonText/modify")
	public JSONMessage commonTextModify( CommonText commonText){

		try {
			if (!StringUtil.isEmpty(commonText.toString())) {
				customerManager.commonTextModify(commonText);
				return JSONMessage.success();
			}else{
				return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
			}
		} catch (Exception e) {
			logger.error("修改常用语失败 ==> " + e.getStackTrace());
			return JSONMessage.failureByException(e);
		}
		
	}
	
	/**
	 * 此接口用于将查找customer客户表中的数据，然后封装成 user 返回
	 * @param customerId
	 * @return
	 */
	@ApiOperation("此接口用于将查找customer客户表中的数据，然后封装成 user 返回")
	@ApiImplicitParam(paramType="query" , name="customerId" , value="编号",dataType="String",required=true)
	@RequestMapping(value = "/getUser")
	public JSONMessage getUser(@RequestParam String customerId) {
		
		Object data = customerManager.getUser(customerId);
		return JSONMessage.success(data);
	}
	
	
	
}

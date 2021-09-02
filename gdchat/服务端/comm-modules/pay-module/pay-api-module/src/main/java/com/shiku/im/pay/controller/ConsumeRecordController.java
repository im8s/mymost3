package com.shiku.im.pay.controller;

import com.alipay.util.AliPayUtil;
import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.common.model.PageVO;
import com.shiku.im.api.service.base.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.i18n.LocaleMessageUtils;
import com.shiku.im.pay.constants.ConsumeRecordEnum;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.dto.ConsumRecordCountDTO;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.service.impl.ConsumeRecordManagerImpl;
import com.shiku.im.api.service.AuthServiceOldUtils;
import com.shiku.im.user.config.WXConfig;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import com.wxpay.utils.WXPayUtil;
import com.wxpay.utils.WxPayDto;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.text.DecimalFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;


@RestController
@Api(value="ConsumeRecordController",tags="消费记录接口")
@RequestMapping(value = "",method = {RequestMethod.POST,RequestMethod.GET})
public class ConsumeRecordController extends AbstractController {

	private Logger logger = LoggerFactory.getLogger(this.getClass());
	@Autowired
	private ConsumeRecordManagerImpl consumeRecordManager;

	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private WXConfig wxConfig;


	@Autowired
	private AuthServiceOldUtils authServiceOldUtils;

	/**
	 * 充值
	 * @param payType
	 * @param price
	 * @param time
	 * @param secret
	 * @return
	 */
	@ApiOperation("充值")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="payType",value="支付类型",dataType="int"),
			@ApiImplicitParam(paramType="query" , name="price",value="价格",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="time",value="时间",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="secret",value="加密数据",dataType="String"),
			@ApiImplicitParam(paramType="query" , name="salt",value="盐加密",dataType="String")
	})
	@RequestMapping(value = "/user/recharge/getSign")
	public JSONMessage getSign(HttpServletRequest request, @RequestParam int payType, @RequestParam String price,
							   @RequestParam(defaultValue="0") long time,
							   @RequestParam(defaultValue="") String secret, String salt) {

		String token=getAccess_token();
		Integer userId = ReqUtil.getUserId();
		if(StringUtil.isEmpty(salt)){
			//充值接口授权
			if(!authServiceOldUtils.authRedPacket(userId+"", token, time, secret)) {
				return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
			}
		}
		// 处理充值自定义输入金额超过两位数
		DecimalFormat df = new DecimalFormat("0.00");
		Double money = new Double(price);
		if(0.01>money){
			return JSONMessage.failureByErrCode(PayResultCode.PleaseEnterAmount);
		}
		// 判断单笔消费金额是否超过限制
		if(money>SKBeanUtils.getImCoreService().getPayConfig().getMaxRechargeAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedMaxAmount);
		}
		// 判断单日消费金额是否超过限制
		Double todayMoney = consumeRecordManager.getUserPayMoney(userId,KConstants.ConsumeType.USER_RECHARGE,KConstants.OrderStatus.END, DateUtil.getTodayMorning().getTime()/1000 , DateUtil.getTodayNight().getTime()/1000);
		todayMoney = todayMoney + money;
		if(todayMoney > SKBeanUtils.getImCoreService().getPayConfig().getDayMaxRechargeAmount()){
			return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
		}

		price = df.format(money);
		Map<String,String> map= Maps.newLinkedHashMap();
		String orderInfo="";
		if(0<payType){
			String orderNo=StringUtil.getOutTradeNo();
			BaseConsumeRecord entity=new BaseConsumeRecord();
			entity.setMoney(money);
			/*if(10<entity.getMoney()) {
				return JSONMessage.failureByErrCode(PayResultCode.SingleRechargeUpTen);
			}*/
			entity.setUserId(ReqUtil.getUserId());
			entity.setTime(DateUtil.currentTimeSeconds());
			entity.setType(KConstants.ConsumeType.USER_RECHARGE);
			entity.setChangeType(KConstants.MOENY_ADD);
			entity.setDesc("余额充值");
			entity.setStatus(KConstants.OrderStatus.CREATE);
			entity.setTradeNo(orderNo);
			entity.setPayType(payType);

			if (KConstants.PayType.ALIPAY == payType) {
				if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableAliPay()){
					return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
				}

				orderInfo = AliPayUtil.getOrderInfo("余额充值", "余额充值", price, orderNo);
				consumeRecordManager.saveConsumeRecord(entity);
				map.put("orderInfo", orderInfo);

				logger.info("orderInfo : " + orderInfo);
				return JSONMessage.success(null, map);
			}else {
				if(1 != SKBeanUtils.getImCoreService().getClientConfig().getEnableWxPay()){
					return JSONMessage.failureByErrCode(KConstants.ResultCode.FUNCTION_NOTOPEN);
				}
				WxPayDto tpWxPay = new WxPayDto();
				//tpWxPay.setOpenId(openId);
				tpWxPay.setBody("余额充值");
				tpWxPay.setOrderId(orderNo);
				tpWxPay.setSpbillCreateIp(request.getRemoteAddr());
				tpWxPay.setTotalFee(price);
				consumeRecordManager.saveConsumeRecord(entity);
				Object data= WXPayUtil.getPackage(tpWxPay,wxConfig);
				return JSONMessage.success(data);
			}
		}
		return JSONMessage.failureByErrCode(PayResultCode.NotSelectPayType);
	}

	@ApiOperation("用户充值记录列表")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue="10")
	})
	@RequestMapping("/user/recharge/list")
	public JSONMessage getList(@RequestParam(defaultValue="0")int pageIndex, @RequestParam(defaultValue="10")int pageSize) {
		List<BaseConsumeRecord> pageData = consumeRecordManager.reChargeList(ReqUtil.getUserId(), pageIndex, pageSize);



		long total=pageData.size();
		return JSONMessage.success(new PageVO(pageData, total,pageIndex, pageSize));
	}
	

	@ApiOperation("用户消费记录列表 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10")
	})
	@RequestMapping("/user/consumeRecord/list")
	public JSONMessage consumeRecordList(@RequestParam(defaultValue="0")int pageIndex,@RequestParam(defaultValue="10")int pageSize) {
		try {
			PageResult<BaseConsumeRecord> result = consumeRecordManager.consumeRecordList(ReqUtil.getUserId(), pageIndex, pageSize,(byte)0);

			if(!ReqUtil.DEFAULT_LANG.equals(ReqUtil.getRequestLanguage())){
				Locale requestLocale = LocaleMessageUtils.getRequestLocale();
				result.getData().forEach(data->{
					data.setDesc(LocaleMessageUtils.getMessage(ConsumeRecordEnum.getCode(data.getType()),requestLocale));

				});
			}
			PageVO data = new PageVO(result.getData(),result.getCount(),pageIndex,pageSize);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		
	}

	@ApiOperation("消费列表")
	@ApiImplicitParams({
			@ApiImplicitParam(paramType="query" , name="pageIndex" , value="当前页码数",dataType="int",defaultValue = "0"),
			@ApiImplicitParam(paramType="query" , name="pageSize" , value="每页数据条数",dataType="int",defaultValue = "10"),
			@ApiImplicitParam(paramType="query" , name="toUserId" , value="发送方编号",dataType="int",defaultValue = "0")
	})
	@RequestMapping("/friend/consumeRecordList")
	public JSONMessage friendRecordList(@RequestParam(defaultValue="0")int toUserId,@RequestParam(defaultValue="0")int pageIndex,@RequestParam(defaultValue="10")int pageSize) {
		try {
			PageResult<BaseConsumeRecord> result = consumeRecordManager
					.friendRecordList(ReqUtil.getUserId(),toUserId, pageIndex, pageSize,(byte)0);
			if(0==result.getCount())
				return JSONMessage.success(null, null);
			PageVO data = new PageVO(result.getData(),result.getCount(),pageIndex,pageSize);
			return JSONMessage.success(data);
		} catch (ServiceException e) {
			return JSONMessage.failureByException(e);
		}
		
	}
	
	

	@ApiOperation("删除消费记录 ")
	@ApiImplicitParam(paramType="query" , name="id" , value="记录Id",dataType="String",required=true)
	@RequestMapping("/recharge/delete")
	public JSONMessage delete(String id) {
		Object data = consumeRecordManager.getConsumeReCord(ReqUtil.getUserId(),new ObjectId(id));
		if(null != data){
			consumeRecordManager.getConsumeRecordDao().deleteById(ReqUtil.parseId(id));
			return JSONMessage.success();
		}else{
			return JSONMessage.failure(null);
		}
	}


	@ApiOperation("按月查询消费记录统计 ")
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="query" , name="startTime" , value="开始时间",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="endTime" , value="结束时间",dataType="String",required=true),
		@ApiImplicitParam(paramType="query" , name="pageIndex" , value="页码",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="pageSize" , value="翻页大小",dataType="String"),
		@ApiImplicitParam(paramType="query" , name="needCount" , value="是否需要统计 1:需要 ,0 不需要",dataType="int",required=true),
			@ApiImplicitParam(paramType="query" , name="isNext" , value="是否下拉 1:下拉 ,0 上拉",dataType="int",required=true),
	})

	@RequestMapping("/consumeRecord/queryConsumeRecordCount")
	public JSONMessage queryConsumeRecordCount(long startTime, long endTime,@RequestParam(defaultValue = "0") int pageIndex,@RequestParam(defaultValue = "50") int pageSize, int needCount,int isNext) {

		Integer userId = ReqUtil.getUserId();
		boolean needCountBool=1==needCount?true:false;
		boolean next=1==isNext?true:false;
		ConsumRecordCountDTO consumRecordCountDTO = consumeRecordManager.queryConsumeRecordCount(userId, startTime, endTime, pageIndex, pageSize,needCountBool,next);
		return JSONMessage.success(consumRecordCountDTO);
	}



}

package com.shiku.im.api.filter;

import cn.hutool.extra.servlet.ServletUtil;
import com.alibaba.fastjson.JSON;
import com.google.common.collect.Maps;
import com.shiku.im.api.service.AuthServiceOldUtils;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.api.service.IdempotenceApiService;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.service.UserRedisService;
import com.shiku.im.user.utils.KSessionUtil;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.utils.SpringBeansUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.ResponseUtil;
import com.shiku.utils.StringUtil;
import org.apache.commons.lang3.math.NumberUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.stream.Collectors;


@WebFilter(filterName = "authorizationfilter", urlPatterns = { "/*" }, initParams = {
		@WebInitParam(name = "enable", value = "true") })
@Component
public class AuthorizationFilter implements Filter {
	
	private Map<String, String> requestUriMap;
	private AuthorizationFilterProperties properties;
	
	private final String defLanguage="zh";

	@Autowired
	private UserRedisService userRedisService;

	@Autowired
	private AuthServiceUtils authServiceUtils;
	@Autowired
	private AuthServiceOldUtils authServiceOldUtils;
	@Autowired
	private IdempotenceApiService idempotenceApiService;

	private Logger logger=LoggerFactory.getLogger(AuthorizationFilter.class);
	@Override
	public void init(FilterConfig arg0) throws ServletException {
		
	}
	
	@Override
	public void destroy() {

	}

	private String getFullUrl(HttpServletRequest request) {
		StringBuffer fullUri = new StringBuffer();
		fullUri.append(request.getRequestURI());
		Map<String, String[]> paramMap = request.getParameterMap();


		if (!paramMap.isEmpty())
			fullUri.append("?");
		for (String key : paramMap.keySet()) {
			fullUri.append(key).append("=").append(paramMap.get(key)[0]).append("&");
		}
		return fullUri.toString();
	}

	@Override
	public void doFilter(ServletRequest arg0, ServletResponse arg1, FilterChain arg2)
			throws IOException, ServletException {

		if (null == requestUriMap || null == properties) {
			requestUriMap = Maps.newHashMap();
			properties = SpringBeansUtils.getContext().getBean(AuthorizationFilterProperties.class);

			for (String requestUri : properties.getRequestUriList()) {
				requestUriMap.put(requestUri, requestUri);
			}
		}

		HttpServletRequest request = (HttpServletRequest) arg0;
		HttpServletResponse response = (HttpServletResponse) arg1;
		//过滤静态文件
		String path = request.getRequestURI();
		String fullUrl = getFullUrl(request);
		String clientIp = ServletUtil.getClientIP(request);
		String ua = request.getHeader("User-Agent");
		//拒绝访问的路径设置
		if (path.contains("/actuator/beans") ||
			path.contains("/actuator/configprops") ||
			path.contains("/actuator/scheduledtasks")){
			returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
		}

		if (path.endsWith(".html") ||
			path.endsWith(".css") ||
			path.endsWith(".js")||
			path.endsWith(".map") ||
			path.equals("/v2/api-docs") ||path.equals("/swagger-resources")||
			path.endsWith(".png") ||
			path.endsWith(".ico") ||
			path.endsWith("/")||
			path.contains("/actuator")
		) {
			arg2.doFilter(arg0, arg1);
			return;
		}


		request.setCharacterEncoding("utf-8");
		response.setCharacterEncoding("utf-8"); 
		response.setContentType("text/html;charset=utf-8");

		String accessToken = request.getParameter("access_token");
		long time = NumberUtils.toLong(request.getParameter("time"), 0);
		String secret =request.getParameter("secret");
		//是否检验接口   老版客户端没有参数
		boolean falg=true;//!StringUtil.isEmpty(secret);
		String requestUri = request.getRequestURI();
		if("/favicon.ico".equals(requestUri))
			return;

		// DEBUG**************************************************DEBUG
		StringBuffer sb = new StringBuffer();
		sb.append(request.getMethod()).append(" 请求：" + request.getRequestURI());

		if (requestUri.startsWith("/core")  || requestUri.startsWith("/data")) {
			arg2.doFilter(arg0, arg1);
			return;
		}
		
		/**
		 * 部分 第三方调用接口 不验证
		 */
		if(KConstants.NO_CHECKAPI_SET.contains(requestUri)){
			arg2.doFilter(arg0, arg1);
			return;
		}

		// DEBUG**************************************************DEBUG
		// 如果访问的是控制台或资源目录
		if(requestUri.startsWith("/console")||requestUri.startsWith("/manualAdmin")||requestUri.startsWith("/mp")||requestUri.startsWith("/open")||requestUri.startsWith("/pages")){
			if(requestUri.startsWith("/console/authInterface")||requestUri.startsWith("/console/oauth/authorize")||requestUri.startsWith("/console/login")||requestUri.startsWith("/mp/login")||requestUri.startsWith("/open/login")||requestUri.startsWith("/pages")){
				arg2.doFilter(arg0, arg1);
				return;
			}

			checkAdminRequest(request, falg, accessToken, response, time, secret, arg0, arg1, arg2, requestUri, fullUrl, clientIp, ua);
		} else {
			if(requestUri.startsWith("/config")||requestUri.startsWith("/getCurrentTime")||requestUri.equals("/getImgCode")) {
				arg2.doFilter(arg0, arg1);
				 return;
			}
				
			checkOtherRequest(request, falg, accessToken, response, time, secret, arg0, arg1, arg2, requestUri, fullUrl, clientIp, ua);
		}
	}

	private boolean isNeedLogin(String requestUri) {
		return !requestUriMap.containsKey(requestUri.trim());
	}

	private String getUserId(String accessToekn) {
		String userId = null;

		try {
			userId = KSessionUtil.getUserIdBytoken(accessToekn);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return userId;
	}
	
	private String getAdminUserId(String accessToekn){
		String userId = null;
		try {
			userId = KSessionUtil.getAdminUserIdByToken(accessToekn);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return userId;
	}

	private static final String template = "{\"resultCode\":%1$s,\"resultMsg\":\"%2$s\"}";

	private static void renderByErrorKey(ServletResponse response, int tipsKey) {
		String tipsValue = ConstantUtil.getMsgByCode(tipsKey+"", ReqUtil.getRequestLanguage());
		String s = String.format(template, tipsKey, tipsValue);

		ResponseUtil.output(response, s);
	}

	private static void renderResponse(ServletResponse response, String data) {
		ResponseUtil.output(response, data);
	}

	private static void renderByError(ServletResponse response, String errMsg) {
		
		String s = String.format(template, 0, errMsg);

		ResponseUtil.output(response, s);
	}
	
	// 校验后台所有相关接口
	public void checkAdminRequest(HttpServletRequest request,boolean falg,String accessToken,HttpServletResponse response,
			long time,String secret,ServletRequest arg0, ServletResponse arg1, FilterChain arg2,String requestUri, String fullUrl, String clientIp, String ua) throws IOException, ServletException{
		// 需要登录
		if (isNeedLogin(request.getRequestURI())) {
			falg=true;
			// 请求令牌是否包含
			if (StringUtil.isEmpty(accessToken)) {
				logger.info("不包含请求令牌");
				int tipsKey =1030101;
				returnFailureRsp(response, fullUrl, clientIp, ua, tipsKey, "不包含请求令牌");
			} else {
				String userId = getAdminUserId(accessToken);
				if(StringUtil.isEmpty(userId)){
					if(requestUri.startsWith("/open/getHelperList")||requestUri.startsWith("/open/codeAuthorCheck")||requestUri.startsWith("/open/authInterface")
				||requestUri.startsWith("/open/sendMsgByGroupHelper")||requestUri.startsWith("/open/webAppCheck")){
						userId = getUserId(accessToken);
					}
				}
				// 请求令牌是否有效
				if (null == userId) {
					logger.info("请求令牌无效或已过期...");
					int tipsKey = 1030102;
					returnFailureRsp(response, fullUrl, clientIp, ua, tipsKey, "请求令牌无效或已过期");
				} else {
					if(falg) {
						 if(!authServiceOldUtils.authRequestApi(userId, time, accessToken, secret,requestUri)) {
							 returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
						 }
					}
					ReqUtil.setLoginedUserId(Integer.parseInt(userId));
					arg2.doFilter(arg0, arg1);
					return;
				}
			}
		}else{
			/**
			 * 校验没有登陆的接口
			 */
			if(null==accessToken) {
				if(falg) {
					if(!authServiceOldUtils.authOpenApiSecret(time, secret)) {
						returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
					}
				}
			}
			
			String userId = getUserId(accessToken);
			if (null != userId) {
				ReqUtil.setLoginedUserId(Integer.parseInt(userId));
			}
			arg2.doFilter(arg0, arg1);
		}
	}
	
	public void checkOtherRequest(HttpServletRequest request,boolean falg,String accessToken,HttpServletResponse response,
			long time,String secret,ServletRequest arg0, ServletResponse arg1, FilterChain arg2,String requestUri, String fullUrl, String clientIp, String ua) throws IOException, ServletException{
		//设置国际化语言
		//获取请求ip地址
		String language= request.getParameter("language");
		language=StringUtil.isEmpty(language)?defLanguage:language;
		ReqUtil.setRequestLanguage(language);

		if(requestUri.startsWith("/yopPay")){
			if(SKBeanUtils.getImCoreService().getPayConfig().getIsOpenCloudWallet()!=1){
				returnFailureRsp(response, fullUrl, clientIp, ua, 10002, "云钱包功能未开放");
			}
		}
		if(requestUri.startsWith("/manual/pay")){
			if(SKBeanUtils.getImCoreService().getPayConfig().getIsOpenManualPay()!=1){
				returnFailureRsp(response, fullUrl, clientIp, ua, 10002, "扫码支付功能未开放");
			}
		}

		// 需要登录
		if (isNeedLogin(request.getRequestURI())) {
			falg=true;
			// 请求令牌是否包含
			if (StringUtil.isEmpty(accessToken)) {
				int tipsKey =1030101;
				returnFailureRsp(response, fullUrl, clientIp, ua, tipsKey, "不包含请求令牌");
			} else {
				String userId =  (null!=getUserId(accessToken))?getUserId(accessToken):getAdminUserId(accessToken);
				// 请求令牌是否有效
				if (null == userId) {
					int tipsKey = 1030102;
					returnFailureRsp(response, fullUrl, clientIp, ua, tipsKey, "请求令牌无效或已过期");
				} else {
					if(falg) {
						if((request.getHeader("user-agent")!=null && request.getHeader("user-agent").contains("MicroMessenger"))){
							// 微信小程序的请求
							if(!authServiceOldUtils.authRequestApi(userId, time, accessToken, secret,requestUri)) {
								returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
							}
						}else{
							Map<String, String> paramMap =request.getParameterMap().entrySet().stream()
									.collect(Collectors.toMap(Map.Entry::getKey,obj -> obj.getValue()[0]));
							KSession session = userRedisService.queryUserSesson(accessToken);
							int signal = authServiceUtils.authRequestApiByMac(paramMap,session,requestUri);
							if(0 == signal) {
								returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
								return;
							} else if (2 == signal) {
								JSONMessage cacheRsp = JSON.parseObject(idempotenceApiService.getGlobalIdempotenceApiData(session.getUserId(), request.getRequestURI()+secret)+"", JSONMessage.class);
								String rspStr = cacheRsp.toJSONString();
								if (null != cacheRsp) {
									logger.info("【请求完成-幂等缓存返回值】uid：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]，响应内容：[{}]",
											session.getUserId(), fullUrl, clientIp, ua, rspStr);
									logger.info("********************************************");
									renderResponse(response, rspStr);
									return;
								}
								//不再直接放行，会导致同样的签名请求可以一直重复调用，存在风险
								else {
									logger.warn("【请求幂等缓存返回值获取失败-因该接口执行时间超过200ms】uid：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]",
											session.getUserId(), fullUrl, clientIp, ua);
									returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
									return;
								}
							}
						}
					}
					try{
						if(!StringUtil.isEmpty(userId))
							ReqUtil.setLoginedUserId(Integer.parseInt(userId));
					}catch (Exception e){
						logger.error(e.getMessage(),e);
					}
					try{
						arg2.doFilter(arg0, arg1);
						return;
					}catch (Exception e){
						logger.error(e.getMessage(),e);
						return;
					}

				}
			}
		} else {
			if(requestUri.startsWith("/config")) {
				arg2.doFilter(arg0, arg1);
				return;
			}
			/**
			 * 校验没有登陆的接口
			 */
				if(falg) {
					if (null != request.getParameter("secret") && null != request.getParameter("salt")) {
                     Map<String, String[]> parameterMap = request.getParameterMap();
                     if(parameterMap.isEmpty()) {
						 returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
					 }
                    Map<String, String> paramMap = parameterMap.entrySet().stream()
								.collect(Collectors.toMap(Map.Entry::getKey, obj -> obj.getValue()[0]));
						if (!authServiceUtils.authOpenApiByMac(paramMap)) {
							returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
						}
					} else {
						if(!authServiceOldUtils.authOpenApiSecret(time, secret)) {
							returnFailureRsp(response, fullUrl, clientIp, ua, KConstants.ResultCode.AUTH_FAILED, "权限验证失败");
						}
					}
				}
			}
			


			if(null!=accessToken){
			String userId = getUserId(accessToken);
				try{
					if(!StringUtil.isEmpty(userId))
				ReqUtil.setLoginedUserId(Integer.parseInt(userId));
				}catch (Exception e){
					logger.error(e.getMessage(),e);
			}
			}
			try{
				arg2.doFilter(arg0, arg1);
				return;
			}catch (Exception e){
				logger.error(e.getMessage(),e);
				return;
			}
		}

	private void returnFailureRsp(HttpServletResponse response, String fullUrl, String clientIp, String ua, int authFailed, String 权限验证失败) {
		logger.error("【请求异常】错误码：[{}], 错误信息：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]",
				authFailed, 权限验证失败, fullUrl, clientIp, ua);
		logger.info("********************************************");
		renderByErrorKey(response, authFailed);
		return;
	}
}


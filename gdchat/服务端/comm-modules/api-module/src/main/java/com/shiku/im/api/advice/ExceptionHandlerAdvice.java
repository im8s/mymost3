package com.shiku.im.api.advice;

import com.alibaba.fastjson.JSON;
import com.google.common.collect.Maps;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.ResponseUtil;
import org.apache.catalina.connector.ClientAbortException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.EOFException;
import java.util.Map;


@ControllerAdvice
public class ExceptionHandlerAdvice {

	private Logger logger=LoggerFactory.getLogger(ExceptionHandlerAdvice.class);





	@ExceptionHandler(value ={MissingServletRequestParameterException.class})
	@ResponseBody
	public JSONMessage errorHandler(HttpServletRequest request, MissingServletRequestParameterException ex) throws Exception {
		renderError(request, "RequestParameterException info:{}"+ex.getMessage());


		return new JSONMessage(KConstants.ResultCode.ParamsAuthFail,ex.getMessage());
	}

	@ExceptionHandler(value ={BindException.class})
	@ResponseBody
	public JSONMessage bindExceptionErrorHandler(HttpServletRequest request, BindException ex) throws Exception {
		renderError(request, "bindExceptionErrorHandler info:"+ex.getMessage());


		return new JSONMessage(KConstants.ResultCode.ParamsAuthFail,ex.getFieldError().getDefaultMessage());

		/*if (e instanceof MissingServletRequestParameterException
				|| e instanceof BindException) {
			resultCode = ResultCode.ParamsAuthFail;
			resultMsg = getResultCode(resultCode);
		}*/
	}


	@ExceptionHandler(value = { Exception.class, ServiceException.class, RuntimeException.class })
	public void handleErrors(HttpServletRequest request,
			HttpServletResponse response, Exception e) throws Exception {
		

		Integer resultCode = KConstants.ResultCode.InternalException;
		String resultMsg =getResultCode(resultCode);
		String detailMsg = "";
		renderLog(request, request.getRequestURI() + "错误：");
		 if (e instanceof ServiceException) {
			ServiceException ex = ((ServiceException) e);

			resultCode = 0 == ex.getResultCode() ? 0 : ex.getResultCode();
			resultMsg =(0==resultCode&&null!=ex.getErrMessage())?ex.getErrMessage(): getResultCode(ex.getResultCode());
		} else if (e instanceof ClientAbortException) {
			resultCode=-1;
		}else if(e instanceof EOFException){
			detailMsg = e.getMessage();
		}else {
			e.printStackTrace();
			detailMsg = e.getMessage();
		}
		renderLog(request, resultMsg);

		Map<String, Object> map = Maps.newHashMap();
		map.put("resultCode", resultCode);
		map.put("resultMsg", resultMsg);
		map.put("detailMsg", detailMsg);

		String text = JSON.toJSONString(map);

		ResponseUtil.output(response, text);
	}
	
	public String getResultCode(Integer resultCode){
		return ConstantUtil.getMsgByCode(resultCode.toString(), ReqUtil.getRequestLanguage());
	}

	private void renderLog(HttpServletRequest request, String msg) {
		if (request.getRequestURI().startsWith("/core")) {
			return;
		}
		logger.info(msg);
	}

	private void renderError(HttpServletRequest request, String msg) {
		if (request.getRequestURI().startsWith("/core")) {
			return;
		}
		logger.error(msg);
	}
}

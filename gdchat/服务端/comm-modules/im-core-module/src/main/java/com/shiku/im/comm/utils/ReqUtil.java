package com.shiku.im.comm.utils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.mongodb.DBObject;
import com.shiku.im.comm.ex.ServiceException;
import org.bson.types.ObjectId;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import java.util.List;

public class ReqUtil {

	private static final String name = "LOGIN_USER_ID";

	public static  String DEFAULT_LANG="zh";

	private static final String LangName = "REQUEST_LANGEUAGE";

	public static void setLoginedUserId(int userId) {
		RequestContextHolder.getRequestAttributes().setAttribute(name, userId, RequestAttributes.SCOPE_REQUEST);
	}

	public static Integer getUserId() {
		// 获取AuthorizationFilter通过查询令牌用户映射设置的userId
		Object obj = RequestContextHolder.getRequestAttributes().getAttribute(name, RequestAttributes.SCOPE_REQUEST);
		// if (null == obj) {
		// HttpServletRequest request = ((ServletRequestAttributes)
		// RequestContextHolder.getRequestAttributes()).getRequest();
		// obj = request.getParameter("userId");
		// obj = (null == obj || "".equals(obj)) ? null : obj;
		// }
		return null == obj ? 0 : Integer.parseInt(obj.toString());
	}
	
	public static void setRequestLanguage(String language){
		RequestContextHolder.getRequestAttributes().setAttribute(LangName, language, RequestAttributes.SCOPE_REQUEST);
	}
	
	public static final String getRequestLanguage(){
		Object obj = RequestContextHolder.getRequestAttributes().getAttribute(LangName, RequestAttributes.SCOPE_REQUEST);
		if(null==obj)
			return "zh";
		return obj.toString();
	}




	public static ObjectId parseId(String s) {
		try {
			return (null == s || "".equals(s.trim())) ? null : new ObjectId(s);
		} catch (Exception e) {
			throw new ServiceException("请求参数错误");
		}
	}

	public static DBObject parseDBObj(String s) {
		return (DBObject) com.mongodb.util.JSON.parse(s);
	}

	public static List<ObjectId> parseArray(String text) {
		try {
			return new ObjectMapper().readValue(text, TypeFactory.defaultInstance().constructCollectionType(List.class, ObjectId.class));
		} catch (Exception e) {
			throw new ServiceException("请求参数错误");
		}
	}

}

package com.shiku.im.admin.service.impl;

import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.ErrorMessageDao;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.model.ErrorMessage;
import com.shiku.im.vo.JSONMessage;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ErrorMessageManageImpl {
	@Autowired
	private ErrorMessageDao errorMessageDao;

	/** @Description:（查询所有错误提示） 
	* @param keyword
	* @param pageIndex
	* @param pageSize
	* @return
	**/ 
	public Map<Long, List<ErrorMessage>> findErrorMessage(String keyword,int pageIndex,int pageSize){
		Map<Long, List<ErrorMessage>> map = Maps.newConcurrentMap();
		PageResult pageResult = errorMessageDao.getErrorMessageList(keyword,pageIndex,pageSize);
		map.put(pageResult.getCount(), pageResult.getData());
		return map;
	}
	
	public boolean deleteErrorMessage(String code){
		errorMessageDao.deleteErrorMessage(code);
		return true;
	}
	
	public JSONMessage saveErrorMessage(ErrorMessage errorMessage){
		ErrorMessage getErrorMessage = errorMessageDao.getErrorMessage(errorMessage.getCode());
		if(null != getErrorMessage)
			throw new ServiceException("当前code已被注册");
		errorMessageDao.addErrorMessage(errorMessage);
		return JSONMessage.success();
	}
	
	//修改提示消息
	public ErrorMessage updataErrorMessage(String id,ErrorMessage errorMessage) {
		return errorMessageDao.updateErrorMessage(new ObjectId(id),errorMessage);
	}
}

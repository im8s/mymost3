package com.shiku.im.open.opensdk;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.open.opensdk.entity.SkOpenCheckLog;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

@Service
public class OpenCheckLogManageImpl extends MongoRepository<SkOpenCheckLog,ObjectId> {


	@Override
	public Class<SkOpenCheckLog> getEntityClass() {
		return SkOpenCheckLog.class;
	}
	
	/** @Description:（保存操作日志） 
	* @param skOpenCheckLog
	**/ 
	public void saveOpenCheckLogs(String accountId, String appId,String operateUser, String status, String reason) {
		SkOpenCheckLog skOpenCheckLog = new SkOpenCheckLog(accountId,appId,operateUser,status,reason);
		save(skOpenCheckLog);
	}
	
	/**
	 * 审核日志列表
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	public PageResult<SkOpenCheckLog> getOpenCheckLogList(int pageIndex,int pageSize,String keyWorld){
		Query query=createQuery();
		if(!StringUtil.isEmpty(keyWorld)){
			addToQuery(query,"accountId",keyWorld);
		}
		PageResult<SkOpenCheckLog> data=new PageResult<>();
		data.setCount(count(query));
		data.setData(queryListsByQuery(query,pageIndex, pageSize, 1));
		return data;
	}
	
	/**
	 * 根据Id删除日志
	 * @param id
	 */
	public void delOpenCheckLog(ObjectId id){
		deleteById(id);
	}
}

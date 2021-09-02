package com.shiku.im.admin.service.impl;

import com.google.common.collect.Maps;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.user.dao.ReportDao;
import com.shiku.im.user.entity.Report;
import com.shiku.im.vo.JSONMessage;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReportManagerImpl {

	@Autowired
	private ReportDao reportDao;

	
	/** @Description:（删除举报） 
	* @param id
	* @return
	**/ 
	public JSONMessage deleteReport(String id){
		Report report = reportDao.getReport(new ObjectId(id));
		if(null!=report){
			reportDao.deleteReportById(new ObjectId(id));
			return JSONMessage.success();
		}else 
			return JSONMessage.failure("暂无举报信息");
	}
	
	public Map<Long, List<Report>> getReport(int type,int sender,int receiver,int pageIndex,int pageSize) {
		Map<Long, List<Report>> map = Maps.newConcurrentMap();
		try {
			if (type == 0) {
				List<Report> list = reportDao.getReportList(sender,String.valueOf(receiver),pageIndex,pageSize,0);
				for(Report report : list){
					if(KConstants.ReportReason.reasonMap.containsKey(report.getReason()))
						report.setInfo(KConstants.ReportReason.reasonMap.get(report.getReason()));
				}
				List<Report> data =list;
				map.put(Long.valueOf(list.size()), data);
			} else if (type == 1) {
				List<Report> list = reportDao.getReportList(sender,String.valueOf(receiver),pageIndex,pageSize,1);
			for(Report report : list){
				if(KConstants.ReportReason.reasonMap.containsKey(report.getReason()))
					report.setInfo(KConstants.ReportReason.reasonMap.get(report.getReason()));
			}
			List<Report> data = list;
			map.put(Long.valueOf(list.size()), data);
		}
		return map;
	} catch (Exception e) {
		e.printStackTrace();
	}
		return map;
}
	
	
}

package com.shiku.im.user.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.Report;
import org.bson.types.ObjectId;

import java.util.List;

public interface ReportDao extends IMongoDAO<Report,ObjectId> {

    void addReport(Integer userId,Integer toUserId,int reason,String roomId,String webUrl);

    Report getReport(ObjectId id);

    List<Report> getReportListByWebUrl(String webUrl);

    List<Report> getReportList(long userId,String receiver,int pageIndex,int pageSize,int type);

    PageResult<Report> getReportListResult(long userId, String receiver, int pageIndex, int pageSize, int type);

    void deleteReportById(ObjectId id);

    void deleteReport(Integer userId,String roomId);
}

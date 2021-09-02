package com.shiku.im.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.entity.SysApiLog;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface SysApiLogDao extends IMongoDAO<SysApiLog, ObjectId> {

    PageResult<SysApiLog> getSysApiLog(String keyword, int pageIndex, int pageSize);

    void deleteSysApiLog(ObjectId id);

    void deleteSysApiLogByTime(long time);
}

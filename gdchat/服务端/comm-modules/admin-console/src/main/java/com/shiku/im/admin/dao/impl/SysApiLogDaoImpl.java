package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.dao.SysApiLogDao;
import com.shiku.im.entity.SysApiLog;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 14:23
 */
@Repository
public class SysApiLogDaoImpl extends MongoRepository<SysApiLog, ObjectId> implements SysApiLogDao {

    @Override
    public Class<SysApiLog> getEntityClass() {
        return SysApiLog.class;
    }

    @Override
    public PageResult<SysApiLog> getSysApiLog(String keyword, int pageIndex, int pageSize) {
        PageResult<SysApiLog> result =new PageResult<SysApiLog>();

        Query query = createQuery();

        if (!StringUtil.isEmpty(keyword)) {
           query.addCriteria(containsIgnoreCase("apiId",keyword));
        }
        descByquery(query,"time");
        result.setData(queryListsByQuery(query,pageIndex,pageSize,1));
        result.setCount(count(query));

        return result;
    }

    @Override
    public void deleteSysApiLog(ObjectId id) {
       deleteById(id);
    }

    @Override
    public void deleteSysApiLogByTime(long time) {
        Query query =createQuery();
        query.addCriteria(Criteria.where("time").lt(time));
        deleteByQuery(query);
    }
}

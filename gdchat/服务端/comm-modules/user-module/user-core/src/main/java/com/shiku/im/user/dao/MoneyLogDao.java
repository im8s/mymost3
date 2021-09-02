package com.shiku.im.user.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.UserMoneyLog;
import org.bson.types.ObjectId;

public interface MoneyLogDao extends IMongoDAO<UserMoneyLog, ObjectId> {

    boolean saveMoneyLog(UserMoneyLog userMoneyLog);


    /**
     * 查询余额操作日志是否处理过
     * 防止同样的业务重复处理
     *
     * @param userMoneyLog
     * @return
     */
    boolean isExistMoneyLogProcessed(UserMoneyLog userMoneyLog);


    boolean isExistMoneyLogProcessed(UserMoneyLog userMoneyLog, byte logType);

    boolean isExistMoneyLogProcessed(String businessId,long userId,byte changeType,byte logType);
}

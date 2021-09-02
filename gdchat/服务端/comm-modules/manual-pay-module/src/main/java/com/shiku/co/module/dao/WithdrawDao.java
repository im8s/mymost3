package com.shiku.co.module.dao;

import com.shiku.co.module.entity.Withdraw;
import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface WithdrawDao extends IMongoDAO<Withdraw, ObjectId> {

    void addWithdraw(Withdraw entity);

    Withdraw getWithdraw(ObjectId id);

    PageResult<Withdraw> getWithdrawList(int pageIndex,int pageSize,String keyword,String startDate,String endDate);

    Map<String,Object> queryWithdraw();

    Withdraw updateWithdraw(ObjectId id, Map<String,Object> map);

    void deleteWithdraw(ObjectId id);
}

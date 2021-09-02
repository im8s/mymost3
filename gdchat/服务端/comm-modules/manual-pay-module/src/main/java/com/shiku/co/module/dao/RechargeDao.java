package com.shiku.co.module.dao;

import com.shiku.co.module.entity.Recharge;
import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface RechargeDao extends IMongoDAO<Recharge, ObjectId> {

    void addRecharge(Recharge entity);

    Recharge getRecharge(ObjectId id);

    PageResult<Recharge> getRechargeList(int pageIndex,int pageSize,String keyword,String startDate, String endDate);

    Map<String,Object> queryRecharge();

    Recharge updateRecharge(ObjectId id, Map<String,Object> map);

    void deleteRecharge(ObjectId id);

}

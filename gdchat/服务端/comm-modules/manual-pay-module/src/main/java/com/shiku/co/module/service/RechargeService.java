package com.shiku.co.module.service;

import com.shiku.co.module.entity.Recharge;
import com.shiku.common.model.PageResult;
import org.bson.types.ObjectId;

public interface RechargeService {

    void addRecharge(int userId,Double money,int type);

    Recharge getRecharge(ObjectId id);

    PageResult<Recharge> getRechargeList(int pageIndex,int pageSize,String keyword,String startDate, String endDate);

    Recharge checkRecharge(ObjectId id,int status);

    void deleteRecharge(ObjectId id);
}

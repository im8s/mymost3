package com.shiku.co.module.service;

import com.shiku.co.module.entity.Withdraw;
import com.shiku.common.model.PageResult;
import org.bson.types.ObjectId;

import java.util.Map;

public interface WithdrawService {

    void addWithdraw(int userId,String money,String withdrawAccountId);

    Withdraw getWithdraw(ObjectId id);

    PageResult<Withdraw> getWithdrawList(int pageIndex, int pageSize,String keyword,String startDate,String endDate);

    Withdraw checkWithdraw(ObjectId id,int status);

    void deleteWithdraw(ObjectId id);
}

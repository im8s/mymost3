package com.shiku.co.module.service;

import com.shiku.co.module.entity.WithdrawAccount;
import com.shiku.common.model.PageResult;
import org.bson.types.ObjectId;

public interface WithdrawAccountService {

    void addWithdrawAccount(WithdrawAccount entity);

    void deleteWithdrawAccount(ObjectId id);

    void updateWithdrawAccount(WithdrawAccount withdrawAccount);

    PageResult<WithdrawAccount> getWithdrawAccountList(int userId,int pageIndex,int pageSize);

    WithdrawAccount getWithdrawAccount(ObjectId id);
}

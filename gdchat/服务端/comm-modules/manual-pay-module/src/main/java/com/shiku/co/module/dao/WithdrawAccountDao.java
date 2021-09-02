package com.shiku.co.module.dao;

import com.shiku.co.module.entity.WithdrawAccount;
import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface WithdrawAccountDao extends IMongoDAO<WithdrawAccount, ObjectId> {

    void addWithdrawAccount(WithdrawAccount entity);

    void deleteWithdrawAccount(ObjectId id);

    void updateWithdrawAccount(ObjectId id, Map<String,Object> map);

    PageResult<WithdrawAccount> getWithdrawAccountList(int userId,int pageIndex,int pageSize);

    WithdrawAccount getWithdrawAccount(ObjectId id);
}

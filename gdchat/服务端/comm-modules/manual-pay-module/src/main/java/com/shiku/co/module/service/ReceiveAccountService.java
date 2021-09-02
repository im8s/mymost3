package com.shiku.co.module.service;

import com.shiku.co.module.entity.ReceiveAccount;
import com.shiku.common.model.PageResult;
import org.bson.types.ObjectId;

public interface ReceiveAccountService {

    void addReceiveAccount(ReceiveAccount receiveAccount);

    void updateReceiveAccount(ObjectId id, ReceiveAccount receiveAccount);

    void deleteReceiveAccount(ObjectId id);

    PageResult<ReceiveAccount> getReceiveAccountList(int pageIndex,int pageSize,int type,String keyword);

    ReceiveAccount getReceiveAccount(ObjectId id);
}

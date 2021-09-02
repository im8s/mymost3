package com.shiku.co.module.dao;

import com.shiku.co.module.entity.ReceiveAccount;
import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface ReceiveAccountDao extends IMongoDAO<ReceiveAccount,ObjectId> {

    void  addReceiveAccount(ReceiveAccount receiveAccount);

    void updateReceiveAccount(ObjectId id, Map<String,Object> map);

    void deleteReceiveAccount(ObjectId id);

    PageResult<ReceiveAccount> getReceiveAccountList(int pageIndex,int pageSize,int type,String keyword);

    ReceiveAccount getReceiveAccount(ObjectId id);
}

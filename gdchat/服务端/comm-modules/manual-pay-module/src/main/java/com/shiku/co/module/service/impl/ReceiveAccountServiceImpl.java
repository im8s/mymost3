package com.shiku.co.module.service.impl;

import com.shiku.co.module.dao.ReceiveAccountDao;
import com.shiku.co.module.entity.ReceiveAccount;
import com.shiku.co.module.service.ReceiveAccountService;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/12/2 12:21
 */
@Service
public class ReceiveAccountServiceImpl implements ReceiveAccountService {
    @Autowired
    private ReceiveAccountDao receiveAccountDao;

    @Override
    public void addReceiveAccount(ReceiveAccount receiveAccount) {
        receiveAccountDao.addReceiveAccount(receiveAccount);
    }

    @Override
    public void updateReceiveAccount(ObjectId id, ReceiveAccount receiveAccount) {
        Map<String,Object> map = new HashMap<>();
        if(!StringUtil.isEmpty(receiveAccount.getUrl())){
            map.put("url",receiveAccount.getUrl());
        }
        if(receiveAccount.getType()!=0){
            map.put("type",receiveAccount.getType());
        }
        if(!StringUtil.isEmpty(receiveAccount.getName())){
            map.put("name",receiveAccount.getName());
        }
        if(!StringUtil.isEmpty(receiveAccount.getPayNo())){
            map.put("payNo",receiveAccount.getPayNo());
        }
        if(!StringUtil.isEmpty(receiveAccount.getBankCard())){
            map.put("bankCard",receiveAccount.getBankCard());
        }
        if(!StringUtil.isEmpty(receiveAccount.getBankName())){
            map.put("bankName",receiveAccount.getBankName());
        }
        receiveAccountDao.updateReceiveAccount(id,map);
    }

    @Override
    public void deleteReceiveAccount(ObjectId id) {
        receiveAccountDao.deleteReceiveAccount(id);
    }

    @Override
    public PageResult<ReceiveAccount> getReceiveAccountList(int pageIndex, int pageSize,int type,String keyword) {
        return receiveAccountDao.getReceiveAccountList(pageIndex,pageSize,type,keyword);
    }

    @Override
    public ReceiveAccount getReceiveAccount(ObjectId id) {
        return receiveAccountDao.getReceiveAccount(id);
    }
}

package com.shiku.co.module.service.impl;

import com.shiku.co.module.dao.WithdrawAccountDao;
import com.shiku.co.module.entity.WithdrawAccount;
import com.shiku.co.module.service.WithdrawAccountService;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.DateUtil;
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
 * @date 2019/12/2 17:14
 */
@Service
public class WithdrawAccountServiceImpl implements WithdrawAccountService {

    @Autowired
    private WithdrawAccountDao withdrawAccountDao;

    @Override
    public void addWithdrawAccount(WithdrawAccount entity) {
        entity.setCreateTime(DateUtil.currentTimeSeconds());
        withdrawAccountDao.addWithdrawAccount(entity);
    }

    @Override
    public void deleteWithdrawAccount(ObjectId id) {
        Map<String,Object> map = new HashMap<>();
        map.put("status",-1);
        withdrawAccountDao.updateWithdrawAccount(id,map);
    }

    @Override
    public void updateWithdrawAccount(WithdrawAccount withdrawAccount) {
        Map<String,Object> map = new HashMap<>();
        if(!StringUtil.isEmpty(withdrawAccount.getAliPayName())){
            map.put("aliPayName",withdrawAccount.getAliPayName());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getAliPayAccount())){
            map.put("aliPayAccount",withdrawAccount.getAliPayAccount());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getCardName())){
            map.put("cardName",withdrawAccount.getCardName());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getBankCardNo())){
            map.put("bankCardNo",withdrawAccount.getBankCardNo());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getBankName())){
            map.put("bankName",withdrawAccount.getBankName());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getBankBranchName())){
            map.put("bankBranchName",withdrawAccount.getBankBranchName());
        }
        if(!StringUtil.isEmpty(withdrawAccount.getDesc())){
            map.put("desc",withdrawAccount.getDesc());
        }
        withdrawAccountDao.updateWithdrawAccount(withdrawAccount.getId(),map);
    }

    @Override
    public PageResult<WithdrawAccount> getWithdrawAccountList(int userId,int pageIndex, int pageSize) {
        return withdrawAccountDao.getWithdrawAccountList(userId,pageIndex,pageSize);
    }

    @Override
    public WithdrawAccount getWithdrawAccount(ObjectId id) {
        return withdrawAccountDao.getWithdrawAccount(id);
    }
}

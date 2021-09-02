package com.shiku.co.module.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.co.module.dao.WithdrawDao;
import com.shiku.co.module.entity.Withdraw;
import com.shiku.co.module.service.WithdrawService;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.user.constants.MoneyLogConstants;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/12/2 17:11
 */@Service
public class WithdrawServiceImpl implements WithdrawService {


    @Autowired
    private WithdrawDao withdrawDao;
    @Autowired
    private UserCoreService userCoreService;

    @Override
    public void addWithdraw(int userId,String money,String withdrawAccountId) {
        Withdraw withdraw  = new Withdraw();
        withdraw.setUserId(userId);
        withdraw.setMoney(Double.valueOf(money));
        withdraw.setWithdrawAccountId(withdrawAccountId);
        withdraw.setCreateTime(DateUtil.currentTimeSeconds());
        withdraw.setModifyTime(DateUtil.currentTimeSeconds());
        withdraw.setStatus(1);
        withdraw.setOrderNo(StringUtil.getOutTradeNo());
        Double fee = withdraw.getMoney()*SKBeanUtils.getSystemConfig().getManualPaywithdrawFee();
        // 如果费率小于0.01 就按0.01收取
        if(fee<0.01){
            fee = 0.01;
        }
        withdraw.setServiceCharge(fee);
        withdraw.setActualMoney(withdraw.getMoney()-fee);
        UserMoneyLog userMoneyLog =new UserMoneyLog(userId,0,withdraw.getOrderNo(),withdraw.getMoney(),
                MoneyLogConstants.MoenyAddEnum.MOENY_REDUCE, MoneyLogConstants.MoneyLogEnum.MANUAL_RECHARGE, MoneyLogConstants.MoneyLogTypeEnum.LOCK_BALANCE);

        userCoreService.rechargeUserMoenyV1(userMoneyLog,callBack->{
            /**
             * 提交申请余额已经扣了,审核失败,余额在加回来
             */
            withdraw.setEndMoney(userMoneyLog.getEndMoeny());
            withdrawDao.addWithdraw(withdraw);
            return true;
        });

    }

    @Override
    public Withdraw getWithdraw(ObjectId id) {
        return withdrawDao.getWithdraw(id);
    }

    @Override
    public PageResult<Withdraw> getWithdrawList(int pageIndex,int pageSize,String keyword,String startDate,String endDate) {
        PageResult<Withdraw> result;
        Map<String, Object> totalVO = Maps.newConcurrentMap();
        Map<String,Object> map = withdrawDao.queryWithdraw();
        totalVO.put("totalWithdraw", NumberUtil.format(map.get("totalWithdraw")));
        totalVO.put("successWithdraw",NumberUtil.format(map.get("successWithdraw")));
        totalVO.put("failureWithdraw",NumberUtil.format(map.get("failureWithdraw")));
        totalVO.put("applyWithdraw",NumberUtil.format(map.get("applyWithdraw")));
        totalVO.put("ignoreCount",NumberUtil.format(map.get("ignoreCount")));

        result = withdrawDao.getWithdrawList(pageIndex,pageSize,keyword,startDate,endDate);
        result.setTotalVo(JSONObject.toJSONString(totalVO));
        return result;
    }

    @Override
    public Withdraw checkWithdraw(ObjectId id, int status) {
        Map<String,Object> map = new HashMap<>();
        map.put("status",status);
        return withdrawDao.updateWithdraw(id,map);
    }

    @Override
    public void deleteWithdraw(ObjectId id) {
        withdrawDao.deleteWithdraw(id);
    }
}

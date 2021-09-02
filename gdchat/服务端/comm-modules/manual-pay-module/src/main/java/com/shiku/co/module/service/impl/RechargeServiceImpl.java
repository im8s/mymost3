package com.shiku.co.module.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.co.module.dao.RechargeDao;
import com.shiku.co.module.entity.Recharge;
import com.shiku.co.module.service.RechargeService;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.NumberUtil;
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
 * @date 2019/12/2 15:47
 */
@Service
public class RechargeServiceImpl implements RechargeService {
    @Autowired
    private RechargeDao rechargeDao;

    @Override
    public void addRecharge(int userId, Double money, int type) {
        Recharge recharge = new Recharge();
        recharge.setUserId(userId);
        recharge.setMoney(money);
        recharge.setType(type);
        recharge.setStatus(1);
        recharge.setOrderNo(StringUtil.getOutTradeNo());
        recharge.setCreateTime(DateUtil.currentTimeSeconds());
        recharge.setModifyTime(DateUtil.currentTimeSeconds());
        rechargeDao.addRecharge(recharge);
    }

    @Override
    public Recharge getRecharge(ObjectId id) {
        return rechargeDao.getRecharge(id);
    }

    @Override
    public PageResult<Recharge> getRechargeList(int pageIndex, int pageSize,String keyword,String startDate, String endDate) {
        PageResult<Recharge> result;
        Map<String, Object> map = rechargeDao.queryRecharge();
        Map<String, Object> totalVO = Maps.newConcurrentMap();
        totalVO.put("totalRecharge", NumberUtil.format(map.get("totalRecharge")));
        totalVO.put("successRecharge",NumberUtil.format(map.get("successRecharge")));
        totalVO.put("failureRecharge",NumberUtil.format(map.get("failureRecharge")));
        totalVO.put("applyRecharge",NumberUtil.format(map.get("applyRecharge")));
        result = rechargeDao.getRechargeList(pageIndex,pageSize,keyword,startDate,endDate);
        result.setTotalVo(JSONObject.toJSONString(totalVO));
        return result;
    }

    @Override
    public Recharge checkRecharge(ObjectId id, int status) {
        Map<String,Object> map = new HashMap<>();
        map.put("status",status);
        return rechargeDao.updateRecharge(id,map);
    }

    @Override
    public void deleteRecharge(ObjectId id) {
        rechargeDao.deleteRecharge(id);
    }
}

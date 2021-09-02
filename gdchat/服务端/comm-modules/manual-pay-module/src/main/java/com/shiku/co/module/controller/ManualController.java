package com.shiku.co.module.controller;

import com.alibaba.fastjson.JSONObject;
import com.shiku.co.module.entity.ReceiveAccount;
import com.shiku.co.module.entity.WithdrawAccount;
import com.shiku.co.module.service.impl.ReceiveAccountServiceImpl;
import com.shiku.co.module.service.impl.RechargeServiceImpl;
import com.shiku.co.module.service.impl.WithdrawAccountServiceImpl;
import com.shiku.co.module.service.impl.WithdrawServiceImpl;
import com.shiku.common.model.PageResult;
import com.shiku.im.api.service.AuthServiceUtils;
import com.shiku.im.api.service.base.AbstractController;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.service.impl.ConsumeRecordManagerImpl;
import com.shiku.im.support.Call;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/12/2 12:25
 */
@RestController
@RequestMapping(value = "/manual/pay")
public class ManualController extends AbstractController {

    @Autowired
    private RechargeServiceImpl rechargeService;

    @Autowired
    private ReceiveAccountServiceImpl receiveAccountService;

    @Autowired
    private WithdrawAccountServiceImpl withdrawAccountService;

    @Autowired
    private WithdrawServiceImpl withdrawService;
    @Autowired
    private UserCoreService userCoreService;

    @Autowired
    private AuthServiceUtils authServiceUtils;

    @Autowired
    private ConsumeRecordManagerImpl consumeRecordManager;
    /**
     * 获取转账人
     * @param
     * @return
     */
    @RequestMapping(value = "/getReceiveAccount")
    public JSONMessage getReceiveAccount(@RequestParam int type){
        PageResult<ReceiveAccount> result =  receiveAccountService.getReceiveAccountList(0,0,type,null);
        if(result.getData().size()==0){
            return JSONMessage.failure("后台未设置收款人");
        }
        Random random = new Random();
        int i = random.nextInt(result.getData().size());
        return JSONMessage.success(result.getData().get(i));
    }

    /**
     * 提交充值申请
     * @param
     * @return
     */
    @RequestMapping(value = "/recharge")
    public JSONMessage recharge(@RequestParam String money,@RequestParam int type){
        Double rechargeMoney = Double.valueOf(money);
        if (rechargeMoney > SKBeanUtils.getImCoreService().getPayConfig().getMaxRechargeAmount()) {
            return JSONMessage.failureByErrCode(PayResultCode.SingleRechargeUpTen);
        }
        Integer userId = ReqUtil.getUserId();
        Double totalMoney = consumeRecordManager.getUserPayMoney(userId,1,1, DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
        totalMoney = totalMoney + rechargeMoney;
        if(totalMoney > SKBeanUtils.getImCoreService().getPayConfig().getDayMaxRechargeAmount()){
            return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
        }
        rechargeService.addRecharge(userId, rechargeMoney, type);
        return JSONMessage.success();
    }

    /**
     * 添加提现账户
     * @param
     * @return
     */
    @RequestMapping(value = "/addWithdrawAccount")
    public JSONMessage addWithdrawAccount(WithdrawAccount withdrawAccount){
        withdrawAccount.setUserId(ReqUtil.getUserId());
        withdrawAccountService.addWithdrawAccount(withdrawAccount);
        return JSONMessage.success();
    }

    /**
     * 获取提现账户列表
     * @param
     * @return
     */
    @RequestMapping(value = "/getWithdrawAccountList")
    public JSONMessage getWithdrawAccountList(@RequestParam(defaultValue = "0") int pageIndex,@RequestParam(defaultValue = "10") int pageSize){
        PageResult<WithdrawAccount> result = withdrawAccountService.getWithdrawAccountList(ReqUtil.getUserId(),pageIndex,pageSize);
        return JSONMessage.success(result.getData());
    }

    /**
     * 删除提现账户
     * @param
     * @return
     */
    @RequestMapping(value = "/deleteWithdrawAccount")
    public JSONMessage deleteWithdrawAccount(@RequestParam(defaultValue = "") String id){
        withdrawAccountService.deleteWithdrawAccount(new ObjectId(id));
        return JSONMessage.success();
    }

    /**
     * 修改提现账户
     * @param
     * @return
     */
    @RequestMapping(value = "/updateWithdrawAccount")
    public JSONMessage updateWithdrawAccount(WithdrawAccount withdrawAccount){
        withdrawAccountService.updateWithdrawAccount(withdrawAccount);
        return JSONMessage.success();
    }

    /**
     * 提交提现申请
     * @param
     * @return
     */
    @RequestMapping(value = "/withdraw")
    public JSONMessage addWithdraw(@RequestParam String data,@RequestParam String codeId){
        // 客户端配置
        ClientConfig clientConfig = SKBeanUtils.getImCoreService().getClientConfig();
        //开关关闭
        if (0 == clientConfig.getWithdrawSwitch()) {
            return JSONMessage.failure(clientConfig.getWithdrawCloseToast());
        }
        int userId = ReqUtil.getUserId();
        String token = getAccess_token();
        User user = userCoreService.getUser(userId);
        JSONObject jsonObj = authServiceUtils.authManualWithdraw(userId, token, data, codeId,user.getPayPassword());
        if(null==jsonObj) {
            return JSONMessage.failureByErrCode(KConstants.ResultCode.AUTH_FAILED);
        }
        String amount = jsonObj.getString("amount");
        if(Double.valueOf(amount)>userCoreService.getUserMoenyV1(userId)){
            return JSONMessage.failureByErrCode(PayResultCode.InsufficientBalance);
        }
        String withdrawAccountId = jsonObj.getString("withdrawAccountId");
        if(StringUtil.isEmpty(amount)) {
            return JSONMessage.failureByErrCode(PayResultCode.NoTransferMoney);
        }

        if(Double.valueOf(amount)>SKBeanUtils.getImCoreService().getPayConfig().getMaxWithdrawAmount()){
            return JSONMessage.failureByErrCode(PayResultCode.ExceedMaxAmount);
        }
        Double totalMoney = consumeRecordManager.getUserPayMoney(userId,2,1,DateUtil.getTodayMorning().getTime()/1000 ,DateUtil.getTodayNight().getTime()/1000);
        totalMoney = totalMoney+Double.valueOf(amount);
        if(totalMoney > SKBeanUtils.getImCoreService().getPayConfig().getDayMaxWithdrawAmount()){
            return JSONMessage.failureByErrCode(PayResultCode.ExceedDayMaxAmount);
        }
        withdrawService.addWithdraw(userId,amount,withdrawAccountId);
       /* UserMoneyLog userMoneyLog =new UserMoneyLog(userId,0,"", Double.valueOf(amount),
                MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.MANUAL_RECHARGE, MoneyLogTypeEnum.LOCK_BALANCE);

        userCoreService.rechargeUserMoenyV1(userMoneyLog, new Call<Double>() {
            @Override
            public Object execute(Double obj) {
                withdrawService.addWithdraw(userId,amount,withdrawAccountId);
                return null;
            }
        });*/
        return JSONMessage.success();
    }
}

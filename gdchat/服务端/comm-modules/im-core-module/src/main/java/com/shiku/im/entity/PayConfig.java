package com.shiku.im.entity;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2020/1/4 9:43
 */
@Data
@Document(value="payConfig")
public class PayConfig {

    private @Id long id=10000;

    /**
     * 单笔最大转账金额
     */
    private double maxTransferAmount;

    /**
     * 单笔最大红包金额
     */
    private double maxRedpacktAmount=200.0;

    /**
     * 单笔群红包最大发送个数
     */
    private int maxRedpacktNumber = 10;

    /**
     * 单笔最大提现金额
     */
    private double maxWithdrawAmount;

    /**
     * 单笔最大充值金额
     */
    private double maxRechargeAmount;

    /**
     * 单笔付款码支付最大金额
     */
    private double maxCodePaymentAmount;

    /**
     * 单日付款码支付最大金额
     */
    private double dayMaxCodePayAmount;

    /**
     * 单笔二维码收款最大金额
     */
    private double maxCodeReceiptAmount;

    /**
     * 单日二维码收款最大金额
     */
    private double dayMaxCodeReceiptAmount;

    /**
     * 用户单日转账最大金额
     */
    private double dayMaxTransferAmount;

    /**
     * 用户单日红包最大金额
     */
    private double dayMaxRedpacktAmount;

    /**
     * 用户单日提现最大金额
     */
    private double dayMaxWithdrawAmount;

    /**
     * 用户单日充值最大金额
     */
    private double dayMaxRechargeAmount;

    /**
     * 零钱提现费率
     */
    private double myChangeWithdrawRate = 0.006;

    /**
     * 是否开启扫码手动充值
     */
    private byte isOpenManualPay = 0;

    /**
     * 是否开启云钱包 1:开启 0:关闭
     */
    private byte isOpenCloudWallet = 0;

    /**
     * 云钱包开户用户是否默认不冻结
     */
    private byte isDefaultFreeze = 0;

    /**
     * 云钱包新开户充值多少小时后可交易
     */
    private double newYopUserRechargeTime = 24;

    /**
     * 云钱包新开户第一笔充值限额
     */
    private double newYopUserFirstRecharge = 10;

    /**
     * 后台管理中单笔最大充值金额
     */
    private double consoleMaxRechargeAmount = 1;

    /**
     * 后台管理中单笔最大手工提现金额
     */
    private double consoleMaxCodePaymentAmount = 1;

}

package com.shiku.im.pay.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 按照时间查询账单 统计
 */
@Setter
@Getter
public class BillRecordCountDTO {

    /**
     * 未领取红包金额统计
     */
    private String redpacketOverTotal;
    /**
     * 转账未领取金额统计
     */
    private String transferOverTotal;

    /**
     * 充值金额统计
     */
    private String rechargeTotal;
    /**
     * 提现金额统计
     */
    private String cashTotal;
    /**
     * 提现手续费统计
     */
    private String serviceChargeTotal;




}

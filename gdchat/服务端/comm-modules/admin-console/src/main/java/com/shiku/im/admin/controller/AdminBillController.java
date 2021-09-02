package com.shiku.im.admin.controller;

import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.common.service.RedPacketsManager;
import com.shiku.im.common.service.SkTransferManager;
import com.shiku.im.pay.dto.BillRecordCountDTO;
import com.shiku.im.vo.JSONMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.annotations.ApiIgnore;

import java.math.BigDecimal;

@ApiIgnore
@RestController
@RequestMapping
public class AdminBillController {


    @Autowired(required = false)
    private RedPacketsManager redPacketsManager;


    @Autowired(required = false)
    private SkTransferManager transferManager;

    @Autowired(required = false)
    private PaymentManager paymentManager;

    @RequestMapping(value = "/console/billCount")
    public JSONMessage billCount(long startTime, long endTime,@RequestParam(defaultValue ="0") int type) {
        BillRecordCountDTO billRecordCountDTO=paymentManager.queryCashGroupCount(startTime,endTime);
        String transferOverCount = transferManager.queryTransferOverGroupCount(startTime, endTime);
        String redpackOverCount = redPacketsManager.queryRedpackOverGroupCount(startTime, endTime);
        String rechargeCount = paymentManager.queryRechargeGroupCount(startTime, endTime);
        billRecordCountDTO.setTransferOverTotal(transferOverCount);
        billRecordCountDTO.setRedpacketOverTotal(redpackOverCount);
        billRecordCountDTO.setRechargeTotal(rechargeCount);
        //提现手续费保留2位小数
        billRecordCountDTO.setServiceChargeTotal(new BigDecimal(billRecordCountDTO.getServiceChargeTotal()).setScale(2, BigDecimal.ROUND_DOWN).toString());


        return JSONMessage.success(billRecordCountDTO);
    }

}

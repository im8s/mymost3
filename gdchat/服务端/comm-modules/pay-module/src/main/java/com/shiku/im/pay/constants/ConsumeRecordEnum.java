package com.shiku.im.pay.constants;

import java.util.Arrays;

public enum ConsumeRecordEnum {

    /**
     * 用户充值
     */
    USER_RECHARGE(1,"user_recharge","用户充值"),

    USER_WITHDRAW(2,"user_withdraw","用户提现"),

    SYSTEM_RECHARGE(3,"system_recharge","管理员充值"),

    SEND_REDPACKET(4,"send_redpacket","发送红包"),

    RECEIVE_REDPACKET(5,"receive_redpacket","领取红包"),

    REFUND_REDPACKET(6,"refund_redpacket","红包退款"),

    SEND_TRANSFER(7,"send_transfer","转账"),
    RECEIVE_TRANSFER(8,"receive_transfer","接收转账"),
    REFUND_TRANSFER(9,"refund_transfer","转账退款"),

    SEND_PAYMENTCODE(10,"send_paymentcode","付款码付款"),
    RECEIVE_PAYMENTCODE(11,"receive_paymentcode","付款码收款"),

    SEND_QRCODE(12,"send_qrcode","二维码付款"),

    RECEIVE_QRCODE(13,"receive_qrcode","二维码收款"),


    LIVE_GIVE(14,"live_give","直播送礼物"),

    LIVE_RECEIVE(15,"live_receive","直播收礼物"),

    SYSTEM_HANDCASH(16,"system_handcash","手动提现"),


    SDKTRANSFR_PAY(17,"sdktransfr_pay","第三方支付"),


    MANUALPAY_RECHARGE(18,"manualpay_recharge","扫码手动充值"),

    MANUALPAY_WITHDRAW(19,"manualpay_withdraw","扫码手动提现"),



    MALL_ORDER_INCOME(60,"mall_order_income","商城订单收入"),

    MALL_ORDER_REFUND(61,"mall_order_refund","商城订单退款"),

    MALL_ORDER_PAY(62,"mall_order_pay","商城订单付款"),

    MALL_FORWARD_INCOME(63,"mall_forward_income","转发收入"),



    UNKNOWN(0,"UNKNOWN","未知"),
    ;
    private  byte type;


    private String code;

    private  String desc;

    private ConsumeRecordEnum(int type,String code, String desc){
        this.type= (byte) type;
        this.code=code;
        this.desc=desc;
    }


    public byte getType() {
        return type;
    }

    public void setType(int type) {
        this.type = (byte) type;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }


    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public static String getDesc(int type){
        return Arrays.asList(ConsumeRecordEnum.values()).stream()
                .filter(value -> value.getType()== type)
                .findFirst().orElse(ConsumeRecordEnum.UNKNOWN).getDesc();
    }
    public static String getCode(int type){
        return Arrays.asList(ConsumeRecordEnum.values()).stream()
                .filter(value -> value.getType()== type)
                .findFirst().orElse(ConsumeRecordEnum.UNKNOWN).getCode();
    }
}




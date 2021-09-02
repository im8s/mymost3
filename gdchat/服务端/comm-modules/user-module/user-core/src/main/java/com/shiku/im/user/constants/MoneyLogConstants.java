package com.shiku.im.user.constants;

import java.util.Arrays;

public class MoneyLogConstants {

    public enum MoneyLogEnum {
        /**
         * 用户充值
         */
        RECHARGE(1,"用户充值"),
        CASH_OUT(2,"用户提现"),
        ADMIN_RECHARGE(3,"管理员充值"),

        REDPACKET(4,"红包"),



        TRANSFER(5,"转账"),



        RQCODE_PAY(6,"二维码支付"),

        PAYMENTCODE_PAY(7,"付款码支付"),


        LIVE_GIVE_PAY(8,"直播礼物"),

        OPEN_ORDER_PAY(9,"开放接口订单"),

        MANUAL_RECHARGE(11,"手动充值"),

        MANUAL_CASH_OUT(12,"手动提现"),

        MALL_SHOP_PAY(15,"商城支付"),

        UNKNOWN(0, "未知");




        ;
        private  byte type;
        private  String desc;

        private MoneyLogEnum(int type, String desc){
            this.type= (byte) type;
            this.desc=desc;
        }


        public byte getType() {
            return type;
        }

        public void setType(int type) {
            this.type = (byte) type;
        }

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }



        public static String getMoneyLogDesc(int type){
            return Arrays.asList(MoneyLogEnum.values()).stream()
                    .filter(value -> value.getType()== type)
                    .findFirst().orElse(MoneyLogEnum.UNKNOWN).getDesc();
        }

    }

    public enum MoneyLogTypeEnum {

        /**
         * 1:发送/支出 操作
         *
         * 2:领取/收入 操作
         *
         * 3:退款操作
         *
         * 5:锁定余额操作
         *
         * 6:取消锁定余额操作
         *
         *
         *-1:异常回滚操作
         */
        NORMAL_PAY(1,"发送/支出"),

        RECEIVE(2,"领取/收入"),

        REFUND(3,"退款"),

        LOCK_BALANCE(5,"锁定余额"),

        UNLOCK_BALANCE(6,"取消锁定余额"),

        ROLLBACK(-1,"异常回滚"),

        UNKNOWN(0, "未知");




        ;
        private  byte type;
        private  String desc;

        private MoneyLogTypeEnum(int type, String desc){
            this.type= (byte) type;
            this.desc=desc;
        }


        public byte getType() {
            return type;
        }

        public void setType(int type) {
            this.type = (byte) type;
        }

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        public static String getLogTypeDesc(int type){
            return Arrays.asList(MoneyLogTypeEnum.values()).stream()
                    .filter(value -> value.getType()== type)
                    .findFirst().orElse(MoneyLogTypeEnum.UNKNOWN).getDesc();
        }
    }

    public enum MoenyAddEnum {
        /**
         * 用户充值
         */
        MOENY_ADD(1,"余额增加"),
        MOENY_REDUCE(2,"余额减少"),

        UNKNOWN(0, "未知");

        ;
        private  byte type;
        private  String desc;

        private MoenyAddEnum(int type, String desc){
            this.type= (byte) type;
            this.desc=desc;
        }


        public byte getType() {
            return type;
        }

        public void setType(int type) {
            this.type = (byte) type;
        }

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        public static String getAddTypeDesc(int type){
            return Arrays.asList(MoenyAddEnum.values()).stream()
                    .filter(value -> value.getType()== type)
                    .findFirst().orElse(MoenyAddEnum.UNKNOWN).getDesc();
        }
    }
}

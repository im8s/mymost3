package com.shiku.im.pay.constants;

/**
 * 支付相关返回值常量
 * 包含 充值,发红包,转账,付款,提现
 *
 * 104*** 开头统一六位数
 *
 */

public interface PayResultCode{




    //余额不足
    static final int InsufficientBalance = 104001;
    //支付密码未设置
    static final int PayPasswordNotExist = 104002;

    //支付密码错误
    static final int PayPasswordIsWrong = 104003;

    //余额异常
    static final int BALANCE_DATA_EX = 104004;


    //没有选择支付方式!
    static final int NotSelectPayType = 104005;

    // 请输入正确金额
    static final int PleaseEnterAmount = 104006;

    // 已超过单次充值最高限制
    static final int SingleRechargeUpTen = 104007;



    // 没有选择支付类型
    static final int NOSELECTPAYTYPE = 104008;

    /**
     * 重复扣款余额
     */
    static final int DUPLICATE_CHARGE_BALANCE = 104009;



    /**
     * 红包相关 1041**
     */

    // RedPacketController

    // 红包总金额超过限制
    static final int RedPacketAmountRange = 104101;

    // 每人最少 0.01元 !
    static final int RedPacketMinMoney = 104102;
    // 你已经领取过红包了
    static final int RedPacketReceived = 104103;

    // 红包领取超时 104104  100101 客户端已写死 兼容老版本
    static final int RedPacket_TimeOut = 100101;

    // 你手太慢啦  已经被领完了 104105  100102 客户端已写死 兼容老版本
    static final int RedPacket_NoMore = 100102;

    // 红包个数大于房间人数
    static final int GreateRoomMember = 104106;

    // 回复不能为 null!
    static final int RedPacke_ReplyNotNull = 104107;

    // 超过单笔群红包发送的最大个数
    static final int RedPacke_MaxNumber = 104108;

    /**
     * 转账相关
     * 1042**
     */

    //SkTransferController
    // 该转账已超过24小时 104201  100301 客户端已写死 兼容老版本
    static final int TransferTimeOut = 100301;
    // 该转账已完成或退款 104202  100302 客户端已写死 兼容老版本
    static final int TransferOver = 100302;
    // 收款人不正确
    static final int PayeeIsInCorrect = 104203;

    /**
     * 提现相关
     *
     * 1043**
     */

    //TransferController
    // 提现不能低于最低限制
    static final int WithdrawMin = 104301;
    // 提现失败
    static final int WithdrawFailure = 104302;

    // 请先 微信授权 没有授权不能提现
    static final int NoWXAuthorization = 104303;

    //AlipayController 请先支付宝授权没有授权不能提现
    static final int NotAliAuth = 104304;

    // 请输入提现金额
    static final int NoTransferMoney = 104305;

    //AlipayController 单次提现  最多 100元  单次提现超过了最大提现金额
    static final int TransferMaxMoney = 104306;


    /**
     * 付款相关
     * 1044**
     */
    //PayController 付款码错误

    //付款QrKey 已过期  104401 1040204 客户端已写死 兼容老版本
    static final int PayQRKeyExpired = 1040204;
    //付款码错误
    static final int PayCodeWrong = 104402;
    // 付款码已失效
    static final int PayCodeExpired = 104403;
    // 不支持向自己付款
    static final int NotPayWithSelf = 104404;
    // 付款失败
    static final int PayFailure = 104405;



    /**
     * 支付相关其他错误
     *
     * 1044**
     */
    //支付宝支付后回调出错：
    static final int AliPayCallBack_FAILED = 104501;

    // 应用未在第三方平台注册
    static final int NotWithThirdParty = 104502;

    // 验签失败
    static final int AuthSignFailed = 104503;

    // 订单不存在
    static final int OrderNotExist = 104504;
    // appId错误
    static final int AppIdWrong = 104505;

    // 已被禁止使用该功能
    static final int DisabledUse = 104506;

    // 超过单次最大金额限制
    static final int ExceedMaxAmount = 104507;

    // 超过单日最大金额限制
    static final int ExceedDayMaxAmount = 104508;

    // 钱包未开户
    static final int UnopenedWallet = 104509;

}

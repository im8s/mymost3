package com.shiku.im.pay.entity;

import com.shiku.im.comm.utils.NumberUtil;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.text.DecimalFormat;

@Data
@Document(value = "ConsumeRecord")
public class BaseConsumeRecord {

	@Id
	private ObjectId id; //记录id

	private @Indexed String tradeNo; //交易单号


	/**
	 * 业务ID
	 */
	private String businessId;

	private @Indexed int userId; //用户Id

	/**
	 * 对方用户Id
	 * 接受转账时 为 转账人的ID
	 *
	 * 发送转账时 为 接受放的 ID
	 */
	private @Indexed int toUserId;

	private Double money; //金额


	private long time; //时间

	/*
	 * 类型  1:用户充值, 2:用户提现, 3:后台充值, 4:发红包, 5:领取红包,
	 * 6:红包退款  7:转账   8:接受转账   9:转账退回   10:付款码付款
	 *  11:付款码收款   12:二维码付款  13:二维码收款* 14: 直播送礼物,
	 * 15: 直播收到礼物，16：后台手工提现，17：第三方调用支付,18: 扫码手动充值,19: 扫码手动提现
	 */
	private @Indexed int type;

	private String desc;  //消费备注

	private int payType;  //支付方式  1：支付宝支付 , 2：微信支付, 3：余额支付, 4:系统支付

	private @Indexed int status; //交易状态 0：创建  1：支付完成  2：交易完成  -1：交易关闭

	private int manualPay_status;// 扫码手动充值提现交易状态  1.审核成功 -1.审核失败

	private Double serviceCharge;// 手续费

	private Double currentBalance;// 当前余额

	private Double operationAmount;// 实际操作金额

	private ObjectId redPacketId;// 红包id

	/**
	 * 1 收入
	 * 2.支出
	 */
	private byte changeType;

	@Transient
	private String userName;// 用户昵称

	@ApiModelProperty("转账说明")
	@Transient
	private String transferRemark;

	@ApiModelProperty("转账状态")
	@Transient
	private int transferStatus = 1;// 1 ：发出  2：已收款  -1：已退款

	/*public ObjectId getId() {
		return id;
	}
	public void setId(ObjectId id) {
		this.id = id;
	}*/
	public Double getMoney() {
		if(0<money){
			money= NumberUtil.format(money);
		}
		return money;
	}
	public void setMoney(Double money) {
		if(0<money){
			money=NumberUtil.format(money);
		}

		this.money = money;
	}
/*
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public String getDesc() {
		return desc;
	}
	public void setDesc(String desc) {
		this.desc = desc;
	}
	public int getPayType() {
		return payType;
	}
	public void setPayType(int payType) {
		this.payType = payType;
	}
	public String getTradeNo() {
		return tradeNo;
	}
	public void setTradeNo(String tradeNo) {
		this.tradeNo = tradeNo;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}

	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public Integer getToUserId() {
		return toUserId;
	}
	public void setToUserId(int toUserId) {
		this.toUserId = toUserId;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}*/
	/**
	 * @return the serviceCharge
	 */
/*	public Double getServiceCharge() {
		return serviceCharge;
	}
	*//**
	 * @param serviceCharge the serviceCharge to set
	 *//*
	public void setServiceCharge(Double serviceCharge) {
		this.serviceCharge = serviceCharge;
	}
	*//**
	 * @return the currentBalance
	 *//*
	public Double getCurrentBalance() {
		return currentBalance;
	}
	*//**
	 * @param currentBalance the currentBalance to set
	 *//*
	public void setCurrentBalance(Double currentBalance) {
		this.currentBalance = currentBalance;
	}
	*//**
	 * @return the operationAmount
	 *//*
	public Double getOperationAmount() {
		return operationAmount;
	}
	*//**
	 * @param operationAmount the operationAmount to set
	 *//*
	public void setOperationAmount(Double operationAmount) {
		this.operationAmount = operationAmount;
	}
	public ObjectId getRedPacketId() {
		return redPacketId;
	}
	public void setRedPacketId(ObjectId redPacketId) {
		this.redPacketId = redPacketId;
	}

	public int getManualPay_status() {
		return manualPay_status;
	}

	public void setManualPay_status(int manualPay_status) {
		this.manualPay_status = manualPay_status;
	}

	public String getBusinessId() {
		return businessId;
	}

	public void setBusinessId(String businessId) {
		this.businessId = businessId;
	}

	public byte getChangeType() {
		return changeType;
	}

	public void setChangeType(byte changeType) {
		this.changeType = changeType;
	}*/
}
//消费记录实体

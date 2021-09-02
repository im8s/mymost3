package com.shiku.im.pay.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.common.service.SkTransferManager;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.pay.constants.ConsumeRecordEnum;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.dao.TransferDao;
import com.shiku.im.pay.dao.TransferReceiveDao;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.entity.ConsumeRecord;
import com.shiku.im.pay.entity.Transfer;
import com.shiku.im.pay.entity.TransferReceive;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class SkTransferManagerImpl implements SkTransferManager {

	@Autowired
	private TransferDao transferDao;
	@Autowired
	private ConsumeRecordDao consumeRecordDao;
	@Autowired
	private TransferReceiveDao transferReceiveDao;

	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private MessageService messageService;

	private  UserCoreService getuserCoreService(){
		return userCoreService;
	};

	public Transfer saveTransfer(Transfer entity){
		transferDao.addTransferReturn(entity);

		return entity;
	}
	
	/**
	 * 获取转账信息
	 * @param userId
	 * @param id
	 * @return
	 */
	public JSONMessage getTransferById(Integer userId, ObjectId id){
		Transfer transfer = transferDao.getTransfer(id);
		//判断转账是否超时
		if(DateUtil.currentTimeSeconds()>transfer.getOutTime()){
			return JSONMessage.failureByErrCode(PayResultCode.TransferTimeOut, transfer);
		}
		// 判断转账状态是否正常
		if(transfer.getStatus()!=1){
			return JSONMessage.failureByErrCode(PayResultCode.TransferOver, transfer);
		}
		
		return JSONMessage.success(transfer);
	}
	
	public  JSONMessage sendTransfer(Integer userId,String money,Transfer transfer)throws Exception{
		Object result=userCoreService.payMoenyBalanceOnLock(userId,transfer.getMoney(),
				obj -> sendTransferOnLock(userId, transfer));
		return JSONMessage.success(result);
	}
	private Object sendTransferOnLock(Integer userId,Transfer transfer){

		transfer.setUserId(userId);
		transfer.setUserName(userCoreService.getUser(userId).getNickname());
		long cuTime=DateUtil.currentTimeSeconds();
		transfer.setCreateTime(cuTime);
		transfer.setOutTime(cuTime+ KConstants.Expire.DAY1);
		transfer.setId(ObjectId.get());
		if(StringUtil.isEmpty(transfer.getRemark())){
			transfer.setRemark("");
		}
		/**
		 * 发送转账 余额操作日志
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,transfer.getToUserId(),transfer.getId().toString(),transfer.getMoney(),
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.TRANSFER, MoneyLogTypeEnum.NORMAL_PAY);

		//修改金额
		userCoreService.rechargeUserMoenyV1(userMoneyLog,obj -> {
			saveTransfer(transfer);
			//开启一个线程 添加一条消费记录
			ThreadUtils.executeInThread(back -> {
				String tradeNo=StringUtil.getOutTradeNo();
				//创建消费记录
				BaseConsumeRecord record=new BaseConsumeRecord();
				record.setUserId(userId);
				record.setToUserId(transfer.getToUserId());
				record.setTradeNo(tradeNo);
				record.setMoney(transfer.getMoney());
				record.setOperationAmount(transfer.getMoney());
				record.setCurrentBalance(obj);
				record.setBusinessId(userMoneyLog.getBusinessId());
				record.setStatus(KConstants.OrderStatus.END);
				record.setType(KConstants.ConsumeType.SEND_TRANSFER);
				record.setChangeType(KConstants.MOENY_REDUCE);
				record.setPayType(KConstants.PayType.BALANCEAY); //余额支付
//				record.setDesc("转账");
				record.setDesc(ConsumeRecordEnum.getDesc(KConstants.ConsumeType.SEND_TRANSFER));
				record.setTime(DateUtil.currentTimeSeconds());
				consumeRecordDao.addConsumRecord(record);
			});
			return true;
		});
		return transfer;
	}
	
	/**
	 * 转账收钱
	 * @param userId
	 * @param id
	 * @return
	 */
	public synchronized JSONMessage receiveTransfer(Integer userId,ObjectId id){
		Transfer transfer = transferDao.getTransfer(id);
		//判断转账是否超时
		if(DateUtil.currentTimeSeconds()>transfer.getOutTime()){
			return JSONMessage.failureByErrCode(PayResultCode.TransferTimeOut,transfer);
		}
		// 判断转账状态是否已经完成
		if(transfer.getStatus()!=1){
			return JSONMessage.failureByErrCode(PayResultCode.TransferOver,transfer);
		}
		
		// 判断是否发送给该用户的转账
		if(!transfer.getToUserId().equals(userId)){
			return JSONMessage.failureByErrCode(PayResultCode.PayeeIsInCorrect,transfer);
		}
		
		User user=getuserCoreService().getUser(userId);
		Map<String,Object> map = new HashMap<>();
		map.put("status", 2);
		map.put("receiptTime", DateUtil.currentTimeSeconds());
		transferDao.updateTransfer(transfer.getId(),map);
		TransferReceive receive=new TransferReceive();
		receive.setMoney(transfer.getMoney());
		receive.setSendId(transfer.getUserId());
		receive.setUserId(userId);
		receive.setSendName(transfer.getUserName());
		receive.setUserName(user.getNickname());
		receive.setTransferId(transfer.getId().toString());
		receive.setTime(DateUtil.currentTimeSeconds());
		transferReceiveDao.addTransferReceive(receive);


		/**
		 * 接受转账 余额操作日志
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,transfer.getUserId(),transfer.getId().toString(),transfer.getMoney(),
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.TRANSFER, MoneyLogTypeEnum.RECEIVE);

		//修改金额
		Double balance = getuserCoreService().rechargeUserMoenyV1(userMoneyLog);

		
		//开启一个线程 添加一条消费记录
		ThreadUtils.executeInThread(obj -> {

			String tradeNo=StringUtil.getOutTradeNo();
			//创建消费记录
			BaseConsumeRecord record=new BaseConsumeRecord();
			record.setUserId(userId);
			record.setToUserId(transfer.getUserId());
			record.setTradeNo(tradeNo);
			record.setMoney(transfer.getMoney());
			record.setCurrentBalance(balance);
			record.setStatus(KConstants.OrderStatus.END);
			record.setType(KConstants.ConsumeType.RECEIVE_TRANSFER);
			record.setChangeType(KConstants.MOENY_ADD);
			record.setPayType(KConstants.PayType.BALANCEAY); //余额支付
//			record.setDesc("接收转账");
			record.setDesc(ConsumeRecordEnum.getDesc(KConstants.ConsumeType.RECEIVE_TRANSFER));
			record.setTime(DateUtil.currentTimeSeconds());
			record.setOperationAmount(transfer.getMoney());
			record.setBusinessId(userMoneyLog.getBusinessId());
			consumeRecordDao.addConsumRecord(record);
		});

		// 发送xmpp消息
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.RECEIVETRANSFER);
		messageBean.setFromUserId(user.getUserId().toString());
		messageBean.setFromUserName(user.getNickname());
		messageBean.setContent(transfer.getId().toString());
		messageBean.setToUserId(transfer.getUserId().toString());
		messageBean.setMsgType(0);// 单聊消息
		messageBean.setMessageId(StringUtil.randomUUID());
		try {
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return JSONMessage.success(receive);
	}
	
	/**
	 * 发起转账列表
	 * @param userId
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	public List<Transfer> getTransferList(Integer userId,int pageIndex,int pageSize){
		return transferDao.getTransferList(userId,pageIndex,pageSize);
	}
	
	/**
	 * 接受转账列表
	 * @param userId
	 * @param pageIndex
	 * @param pageSize
	 * @return
	 */
	public List<TransferReceive> getTransferReceiveList(Integer userId,int pageIndex,int pageSize){
		return transferReceiveDao.getTransferReceiveList(userId,pageIndex,pageSize);
	}


	public Transfer getTransferByYop(String orderNo){
		return transferDao.getTransferByYop(orderNo);
	}

	public  Transfer queryAccountInfo(ObjectId id){
		return transferDao.getTransfer(id);
	}



	public static final int TRANSFER_START=1;// 转账发出状态
	public static final int TRANSFER_RECEDE=-1;// 转账退款状态
	//public static final int STATUS_RECEDE=3;//已退款红包状态
	@Override
	public void autoRefreshTransfer(){
		long currentTime=DateUtil.currentTimeSeconds();
		Integer userId=0;
		Double money=0.0;
		Integer toUserId=0;
		ObjectId transferId=null;
		//只查询发出状态的转账
		List<Transfer> transfers = transferDao.getTransferTimeOut(currentTime,TRANSFER_START);


		for (Transfer dbObject : transfers) {
			userId = dbObject.getUserId();
			money = dbObject.getMoney();
			toUserId = dbObject.getToUserId();
			transferId = dbObject.getId();

			try {
				transferRecedeMoney(userId, toUserId, money, transferId);
			} catch (Exception e) {
				continue;
			}
		}
		if(0<transfers.size()){
			Map<String,Object> map = new HashMap<>();
			map.put("status", TRANSFER_RECEDE);
			transferDao.updateTransferTimeOut(currentTime,TRANSFER_START,map);
		}
		log.info("转账超时未领取的数量 ======> "+transfers.size());
	}


	// 转账退回
	public void transferRecedeMoney(Integer userId,Integer toUserId,double money,ObjectId transferId){
		if(0<money){
			// 格式化数据
			DecimalFormat df = new DecimalFormat("#.00");
			money= Double.valueOf(df.format(money));
		}else {
			return;
		}

		ConsumeRecord record=new ConsumeRecord();
		String tradeNo= com.shiku.im.comm.utils.StringUtil.getOutTradeNo();
		record.setTradeNo(tradeNo);
		record.setMoney(money);
		record.setUserId(userId);
		record.setToUserId(toUserId);
		record.setOperationAmount(money);

		record.setDesc("转账退款");

		/**
		 * 转账超时退款 余额操作日志
		 */
		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,toUserId,transferId.toString(),money,
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.TRANSFER, MoneyLogTypeEnum.REFUND);

		userCoreService.rechargeUserMoenyV1(userMoneyLog,balance->{
			record.setCurrentBalance(balance);
			record.setType(KConstants.ConsumeType.REFUND_TRANSFER);
			record.setChangeType(KConstants.MOENY_ADD);
			record.setPayType(KConstants.PayType.BALANCEAY);
			record.setTime(DateUtil.currentTimeSeconds());
			record.setStatus(KConstants.OrderStatus.END);
			record.setBusinessId(userMoneyLog.getBusinessId());
			consumeRecordDao.addConsumRecord(record);
			return true;
		});


		User sysUser = userCoreService.getUser(1100);
		Transfer transfer=transferDao.getTransfer(transferId);
		transfer.setId(null);
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.REFUNDTRANSFER);

		messageBean.setFromUserId(sysUser.getUserId().toString());
		messageBean.setFromUserName(sysUser.getNickname());

		messageBean.setContent(JSONObject.toJSONString(transfer));
		messageBean.setToUserId(userId.toString());
		messageBean.setMsgType(0);// 单聊消息
		messageBean.setMessageId(com.shiku.im.comm.utils.StringUtil.randomUUID());
		try {
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}

		log.info(userId+"  发出转账,剩余金额   "+money+"  未收钱  退回余额!");
	}


	@Override
	public String queryTransferOverGroupCount(long startTime, long endTime) {
		return transferDao.queryTransferOverGroupCount(startTime,endTime);
	}
}

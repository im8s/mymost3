package com.shiku.im.redpack.service;


import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.common.service.RedPacketsManager;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.pay.constants.PayResultCode;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.entity.ConsumeRecord;
import com.shiku.im.redpack.dao.RedPacketDao;
import com.shiku.im.redpack.dao.RedReceiveDao;
import com.shiku.im.redpack.entity.RedPacket;
import com.shiku.im.redpack.entity.RedReceive;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.vo.JSONMessage;
import com.shiku.redisson.ex.LockFailException;
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
import java.util.Random;

@Slf4j
@Service
public class RedPacketManagerImpl implements RedPacketsManager {

	@Autowired
	private RedPacketDao redPacketDao;

	@Autowired
	private RedReceiveDao redReceiveDao;

	@Autowired
	private ConsumeRecordDao consumeRecordDao;


	@Autowired
	private UserCoreService userCoreService;

	@Autowired
	private MessageService messageService;


	@Autowired
	private RedPacketRedisService redPacketRedisService;

	
	public RedPacket saveRedPacket(RedPacket entity){
			redPacketDao.addRedPacket(entity);
			return entity;
	}
	
	public Object sendRedPacket(int userId,RedPacket packet) throws Exception {

		try {
			return userCoreService.payMoenyBalanceOnLock(userId,packet.getMoney(),obj -> {
				return sendRedPacketOnLock(userId,packet);
			});
		} catch (Exception e) {
			throw e;
		}


	}

	public Object sendRedPacketOnLock(int userId,RedPacket packet){


		packet.setUserId(userId);
		packet.setUserName(userCoreService.getNickName(userId));
		packet.setOver(packet.getMoney());
		long cuTime= DateUtil.currentTimeSeconds();
		packet.setSendTime(cuTime);
		packet.setOutTime(cuTime+ KConstants.Expire.DAY1);
		packet.setId(ObjectId.get());

		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,packet.getToUserId(),packet.getId().toString(),packet.getMoney(),
				MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.REDPACKET, MoneyLogTypeEnum.NORMAL_PAY);

		//修改金额
		userCoreService.rechargeUserMoenyV1(userMoneyLog,balance -> {
			 saveRedPacket(packet);
			//开启一个线程 添加一条消费记录
			ThreadUtils.executeInThread(callback -> {
				String tradeNo= StringUtil.getOutTradeNo();
				//创建充值记录
				BaseConsumeRecord record=new BaseConsumeRecord();
				record.setUserId(userId);
				record.setToUserId(packet.getToUserId());
				record.setTradeNo(tradeNo);
				record.setMoney(packet.getMoney());
				record.setStatus(KConstants.OrderStatus.END);
				record.setType(KConstants.ConsumeType.SEND_REDPACKET);
				record.setChangeType(KConstants.MOENY_REDUCE);
				record.setPayType(KConstants.PayType.BALANCEAY); //余额支付
				record.setDesc("红包发送");
				record.setTime(DateUtil.currentTimeSeconds());
				record.setRedPacketId(packet.getId());
				record.setOperationAmount(packet.getMoney());
				record.setCurrentBalance(balance);
				record.setBusinessId(userMoneyLog.getBusinessId());
				consumeRecordDao.addConsumRecord(record);
			});
			return true;

		});
		return packet;
	}
	
	public JSONMessage getRedPacketById(Integer userId, ObjectId id){

		RedPacket packet = getRedPacketById(id);
		if(null==packet)
			 return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
		Map<String,Object> map=Maps.newHashMap();
		map.put("packet", packet);
		//判断红包是否超时
		if(DateUtil.currentTimeSeconds()>packet.getOutTime()){
			map.put("list", getRedReceivesByRedId(packet.getId()));
			return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacket_TimeOut, map);
		}
			
		//判断红包是否已领完
		if(packet.getCount()>packet.getReceiveCount()){
			//判断当前用户是否领过该红包
			if(null==packet.getUserIds()||!packet.getUserIds().contains(userId)){
				map.put("list", getRedReceivesByRedId(packet.getId()));
				return JSONMessage.success(map);
			}else {
				map.put("list", getRedReceivesByRedId(packet.getId()));
				return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacketReceived, map);
			}
		}else{//红包已经领完了
			map.put("list", getRedReceivesByRedId(packet.getId()));
			return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacket_NoMore, map);
		}
	}
	/**
	 * 抢红包分布式锁
	 */
	private static final String REDPACK_LOCK = "redpack:lock:%s";
	
	public  JSONMessage openRedPacketById(Integer userId,ObjectId id){
		String redisKey = redPacketRedisService.buildRedisKey(REDPACK_LOCK, id.toString());
		try {
			return (JSONMessage) redPacketRedisService.executeOnLock(redisKey, callBack->
					openRedPacketByIdOnLock(userId,id));
		} catch (LockFailException e) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.SystemIsBusy);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			return JSONMessage.failureByErrCode(KConstants.ResultCode.SystemIsBusy);
		}
	}

	public  JSONMessage openRedPacketByIdOnLock(Integer userId,ObjectId id){
		RedPacket packet = getRedPacketById(id);
		if (null == packet)
			return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
		if (!StringUtil.isEmpty(packet.getYopRedPacketId())) {
			return JSONMessage.failureByErrCode(KConstants.ResultCode.DataNotExists);
		}
		Map<String,Object> map=Maps.newHashMap();
		map.put("packet", packet);
		//判断红包是否超时
		if(DateUtil.currentTimeSeconds()>packet.getOutTime()){
			map.put("list", getRedReceivesByRedId(packet.getId()));
			return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacket_TimeOut,map);
		}
		//判断红包是否已领完
		if(packet.getCount()>packet.getReceiveCount()){
			//判断当前用户是否领过该红包
			//
			if(null==packet.getUserIds()||!packet.getUserIds().contains(userId)){
				packet=openRedPacket(userId, packet);
				map.put("packet", packet);
				map.put("list", getRedReceivesByRedId(packet.getId()));
				return JSONMessage.success(map);
			}
			else {
				map.put("list", getRedReceivesByRedId(packet.getId()));
				return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacketReceived, map);
			}
		}else{ //你手太慢啦  已经被领完了
			map.put("list", getRedReceivesByRedId(packet.getId()));
			return JSONMessage.failureByErrCodeAndData(PayResultCode.RedPacket_NoMore, map);
		}
	}
	
	private  RedPacket openRedPacket(Integer userId,RedPacket packet){
		int overCount= packet.getCount()-packet.getReceiveCount();
		User user=userCoreService.getUser(userId);
		Double money=0.0;
		//普通红包
		if(1==packet.getType()){
			if(1==packet.getCount()-packet.getReceiveCount()){
				//剩余一个  领取剩余红包
				money=packet.getOver();
			}else{
				money=packet.getMoney()/packet.getCount();
				//保留两位小数
				money= Double.valueOf(DECIMAL_FORMAT.format(money));
			}
		}
		else  //拼手气红包或者口令红包
		{
			money=getRandomMoney(overCount, packet.getOver());
		}
		
			
			// 保留两位小数
			Double over=(packet.getOver()-money);
			packet.setOver(Double.valueOf(DECIMAL_FORMAT.format(over)));
			packet.getUserIds().add(userId);
			Map<String,Object> map = new HashMap<>();
			if(0==packet.getOver()){
				map.put("status", 2);
				packet.setStatus(2);
			}
			map.put("receiveCount", packet.getReceiveCount()+1);
			map.put("over",packet.getOver());
			map.put("userIds", packet.getUserIds());
			updateRedPacket(packet.getId(),map);
			
		//实例化一个红包接受对象
		RedReceive receive=new RedReceive();
			receive.setMoney(money);
			receive.setUserId(userId);
			receive.setSendId(packet.getUserId());
			receive.setRedId(packet.getId());
			receive.setTime(DateUtil.currentTimeSeconds());
			receive.setUserName(userCoreService.getUser(userId).getNickname());
			receive.setSendName(userCoreService.getUser(packet.getUserId()).getNickname());
			receive.setId(ObjectId.get());
			saveRedReceive(receive);

		UserMoneyLog userMoneyLog =new UserMoneyLog(userId,packet.getUserId(),
				packet.getId().toString(),money,
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.REDPACKET, MoneyLogTypeEnum.RECEIVE);


			//修改金额
		    Double balance = userCoreService.rechargeUserMoenyV1(userMoneyLog);
		    final Double num=money;
			MessageBean messageBean=new MessageBean();
			messageBean.setType(MessageType.OPENREDPAKET);
			messageBean.setFromUserId(user.getUserId().toString());
			messageBean.setFromUserName(user.getNickname());
			if(packet.getRoomJid()!=null){
				messageBean.setObjectId(packet.getRoomJid());
				if(0==packet.getOver()) {
					messageBean.setFileSize(1);
					messageBean.setFileName(packet.getSendTime()+"");
				}
				messageBean.setRoomJid(packet.getRoomJid());
			}
			messageBean.setMsgType(null == packet.getRoomJid() ? 0 : 1);
			messageBean.setContent(packet.getId().toString());
			messageBean.setToUserId(packet.getUserId()+"");
			messageBean.setToUserName(userCoreService.getNickName(packet.getUserId()));
			messageBean.setMessageId(StringUtil.randomUUID());
			try {
				messageService.send(messageBean);
			} catch (Exception e) {
				e.printStackTrace();
			}
			//开启一个线程 添加一条消费记录
			ThreadUtils.executeInThread(obj -> {
				String tradeNo=StringUtil.getOutTradeNo();
				//创建充值记录
				BaseConsumeRecord record=new BaseConsumeRecord();
				record.setUserId(userId);
				record.setToUserId(packet.getUserId());
				record.setTradeNo(tradeNo);
				record.setMoney(num);
				record.setStatus(KConstants.OrderStatus.END);
				record.setType(KConstants.ConsumeType.RECEIVE_REDPACKET);
				record.setChangeType(KConstants.MOENY_ADD);
				record.setPayType(KConstants.PayType.BALANCEAY); //余额支付
				record.setDesc("红包接收");
				record.setOperationAmount(num);
				record.setCurrentBalance(balance);
				record.setBusinessId(userMoneyLog.getBusinessId());
				record.setRedPacketId(packet.getId());
				record.setTime(DateUtil.currentTimeSeconds());
				consumeRecordDao.addConsumRecord(record);
			});
		return packet;
	}

	public void updateRedPacket(ObjectId id, Map<String, Object> map){

		redPacketDao.updateRedPacket(id,map);
		redPacketRedisService.deleteRedPacket(id.toString());
	}
	//发送领取红包消息  即 添加消费记录
	public void sendOpenMessageAndCreateRecord() {
		
	}

	private  final   Random RANDOM     = new Random();

	private final     DecimalFormat DECIMAL_FORMAT = new DecimalFormat("#.00");

	private  Double getRandomMoney(int remainSize,Double remainMoney) {
		    // remainSize 剩余的红包数量
		    // remainMoney 剩余的钱
			Double money=0.0;
		    if (remainSize == 1) {
		        remainSize--;
		         money=(double) Math.round(remainMoney * 100) / 100;
		         System.out.println("=====> "+money);
	            return money;
		    }

		    double min   = 0.01; //
		    double max   = remainMoney / remainSize * 2;
		     money = RANDOM.nextDouble() * max;
		    money = money <= min ? 0.01: money;
		    money = Math.floor(money * 100) / 100;
		    System.out.println("=====> "+money);
		    remainSize--;

		    remainMoney -= money;
		   return Double.valueOf(DECIMAL_FORMAT.format(money));
	}
	
	public void replyRedPacket(String id,String reply) {
		Integer userId = ReqUtil.getUserId();
		Map<String,Object> map = new HashMap<>();
		map.put("reply", reply);
		redReceiveDao.updateRedReceive(new ObjectId(id),userId,map);
	}
	
	//根据红包Id 获取该红包的领取记录
	public  List<RedReceive> getRedReceivesByRedId(ObjectId redId){
		String redpackId = redId.toString();
		List<RedReceive> redReceiveList = redPacketRedisService.queryReceiveList(redpackId);
		if(null==redReceiveList||0==redReceiveList.size()){
			redReceiveList=redReceiveDao.getRedReceiveList(redId);
			redPacketRedisService.saveReceiveList(redpackId,redReceiveList);
		}
		return redReceiveList;
	}
	//发送的红包
	public List<RedPacket> getSendRedPacketList(Integer userId,int pageIndex,int pageSize){
		return redPacketDao.getRedPacketList(userId,pageIndex,pageSize);
	}
	//收到的红包
	public List<RedReceive> getRedReceiveList(Integer userId,int pageIndex,int pageSize){
		return redReceiveDao.getRedReceiveList(userId,pageIndex,pageSize);
	}
	
	
	//发送的红包
	public PageResult<RedPacket> getRedPacketList(String userName, int pageIndex, int pageSize, String redPacketId){
		return redPacketDao.getRedPackListPageResult(userName,redPacketId,pageIndex,pageSize);
	}
	
	//发送的红包
	public PageResult<RedReceive> receiveWater(String redId,int pageIndex,int pageSize){
		return redReceiveDao.getRedReceivePageResult(new ObjectId(redId),pageIndex,pageSize);
	}

	public RedPacket getRedPacketByPoy(String yopRedPacketId){
		return redPacketDao.getRedPacketByPoy(yopRedPacketId);
	}

	public RedPacket getRedPacketById(ObjectId id){
		String redpackId = id.toString();
		RedPacket redPacket=redPacketRedisService.queryRedPacket(redpackId);
		if(null==redPacket){
			redPacket=redPacketDao.getRedPacketById(id);
			if(null!=redPacket){
				redPacketRedisService.saveRedPacket(redpackId,redPacket);
			}
		}

		return redPacket;
	}

	public void saveRedReceive(RedReceive receive){
		 redReceiveDao.addRedReceive(receive);

		 redPacketRedisService.deleteReceiveList(receive.getRedId().toString());
	}


	@Override
	public Object getRedPackListTimeOut(long outTime, int status) {
		return redPacketDao.getRedPackListTimeOut(outTime,status);
	}

	@Override
	public void updateRedPackListTimeOut(long outTime, int status, Map<String, Object> map) {
		redPacketDao.updateRedPackListTimeOut(outTime,status,map);
	}


	public static final int STATUS_START=1;//红包发出状态
	public static final int STATUS_END=2;//已领完红包状态
	public static final int STATUS_RECEDE=-1;//已退款红包状态

	@Override
	public void autoRefreshRedPackect() {
		long currentTime=DateUtil.currentTimeSeconds();
		Integer userId=0;
		Integer toUserId=0;
		String roomJid="";
		ObjectId redPackectId=null;
		Double money=0.0;
		List<RedPacket> redPackets = redPacketDao.getRedPackListTimeOut(currentTime,STATUS_START);

		for (RedPacket redPacket : redPackets) {

			try {
				recedeMoney(redPacket);
			} catch (Exception e) {
				continue;
			}
		}
        if(0<redPackets.size()){
            Map<String,Object> map = new HashMap<>();
            map.put("status",STATUS_RECEDE);
            redPacketDao.updateRedPackListTimeOut(currentTime,STATUS_START,map);
        }

		log.info("红包超时未领取的数量 ======> "+redPackets.size());
	}



	private void recedeMoney(RedPacket redPacket){
		Double money=0.0;
		if(0<redPacket.getOver()){
			DecimalFormat df = new DecimalFormat("#.00");
			money= Double.valueOf(df.format(redPacket.getOver()));
		}else {
			return;
		}
		//实例化一天交易记录
		 ConsumeRecord record=new ConsumeRecord();
		String tradeNo= com.shiku.im.comm.utils.StringUtil.getOutTradeNo();
		record.setTradeNo(tradeNo);
		record.setMoney(money);
		record.setOperationAmount(money);


		UserMoneyLog userMoneyLog =new UserMoneyLog(redPacket.getUserId(),redPacket.getToUserId(),
				redPacket.getId().toString(),money,
				MoenyAddEnum.MOENY_ADD, MoneyLogEnum.REDPACKET, MoneyLogTypeEnum.REFUND);

		userCoreService.rechargeUserMoenyV1(userMoneyLog,balance->{
			redPacketRedisService.deleteRedPacket(redPacket.getId().toString());
			record.setUserId(redPacket.getUserId());
			record.setToUserId(redPacket.getToUserId());
			record.setType(KConstants.ConsumeType.REFUND_REDPACKET);
			record.setChangeType(KConstants.MOENY_ADD);
			record.setPayType(KConstants.PayType.BALANCEAY);
			record.setTime(DateUtil.currentTimeSeconds());
			record.setStatus(KConstants.OrderStatus.END);
			record.setDesc("红包退款");
			record.setRedPacketId(redPacket.getId());

			record.setCurrentBalance(balance);
			record.setBusinessId(userMoneyLog.getBusinessId());
			consumeRecordDao.addConsumRecord(record);
			return true;
		});

		User toUser = userCoreService.getUser(redPacket.getUserId());
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.RECEDEREDPAKET);
		if(toUser!=null){
			messageBean.setFromUserId(toUser.getUserId().toString());
			messageBean.setFromUserName(toUser.getNickname());
		}else {
			messageBean.setFromUserId("10100");
			messageBean.setFromUserName("支付公众号");
		}

		if(redPacket.getRoomJid()!=null){
			messageBean.setObjectId(redPacket.getRoomJid());
		}
		messageBean.setContent(redPacket.getId().toString());
		messageBean.setToUserId(redPacket.getUserId()+"");
		// 单聊消息
		messageBean.setMsgType(0);
		messageBean.setMessageId(com.shiku.im.comm.utils.StringUtil.randomUUID());
		try {
			messageService.send(messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}

		log.info(redPacket.getUserId()+"  发出的红包,剩余金额   "+money+"  未领取  退回余额!");
	}

	@Override
	public String queryRedpackOverGroupCount(long startTime, long endTime) {
		return redPacketDao.queryRedpackOverGroupCount(startTime,endTime);
	}
}

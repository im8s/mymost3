package com.shiku.im.live.service.impl;

import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.common.service.PaymentManager;
import com.shiku.im.dao.GiftDao;
import com.shiku.im.dao.GiveGiftDao;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.Gift;
import com.shiku.im.entity.Givegift;
import com.shiku.im.live.dao.BlackDao;
import com.shiku.im.live.dao.LiveRoomDao;
import com.shiku.im.live.dao.LiveRoomMemberDao;
import com.shiku.im.live.entity.Black;
import com.shiku.im.live.entity.LiveRoom;
import com.shiku.im.live.entity.LiveRoom.LiveRoomMember;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.support.Callback;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.entity.UserMoneyLog;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class LiveRoomManagerImpl {

	//余额不足
	static final int InsufficientBalance = 104001;
	
	public final  String mucMsg="mucmsg_";
	@Autowired
    private LiveRoomDao liveRoomDao;
	public LiveRoomDao getLiveRoomDao(){
		return liveRoomDao;
	}

	@Autowired
    private LiveRoomMemberDao liveRoomMemberDao;

	@Autowired
    private BlackDao blackDao;
    @Autowired
    private GiftDao giftDao;
    @Autowired
    private GiveGiftDao giveGiftDao;

    @Autowired(required=false)
//	@Lazy
	private PaymentManager paymentManager;

	@Autowired
	private MessageService messageService;

	@Autowired
	private IMessageRepository messageRepository;

	@Autowired
	private UserCoreService userCoreService;


	private  UserCoreService getUserManager(){
		return userCoreService;
	};	
	
	public LiveRoom getLiveRoom(Integer userId){
		LiveRoom liveRoom = liveRoomDao.getLiveRoomByUserId(userId);
		if(null==liveRoom)
			return null;
		// 返回时加上完整地址
		if(!liveRoom.getUrl().startsWith("rtmp://"))
			liveRoom.setUrl(SKBeanUtils.getImCoreService().getClientConfig().getLiveUrl()+liveRoom.getUrl());
        return liveRoom;
	}

	public LiveRoom getLiveRoomByJid(String jid){
		LiveRoom liveRoom = liveRoomDao.getLiveRoomByJid(jid);
		// 返回时加上完整地址
		if(null!=liveRoom&&!liveRoom.getUrl().startsWith("rtmp://"))
			liveRoom.setUrl(SKBeanUtils.getImCoreService().getClientConfig().getLiveUrl()+liveRoom.getUrl());
		return liveRoom;
	}
	
	//创建直播间
	public LiveRoom createLiveRoom(LiveRoom room){
//			Query<LiveRoom> query = getDatastore().createQuery(getEntityClass()).field("userId").equal(room.getUserId());
        LiveRoom liveRoom = liveRoomDao.getLiveRoomByUserId(room.getUserId());
			if(null != liveRoom)
				throw new ServiceException(KConstants.ResultCode.NotCreateRepeat);
		User user = getUserManager().getUser(room.getUserId());

		room.setNickName(user.getNickname());
		room.setCreateTime(DateUtil.currentTimeSeconds());
		room.setNotice(room.getNotice());
		room.setNumbers(1);
		room.setUrl(room.getUserId()+"_"+DateUtil.currentTimeSeconds());
		if(StringUtil.isEmpty(room.getJid())){
			String jid =StringUtil.randomUUID();
					messageService.createMucRoomToIMServer(jid,user.getPassword(), user.getUserId().toString(),
					room.getName());
			room.setJid(jid);
		}
			//room.setJid(room.getJid());
			room.setUrl(SKBeanUtils.getImCoreService().getClientConfig().getLiveUrl()+room.getUrl());
			room.setRoomId(ObjectId.get());
			liveRoomDao.addLiveRoomReturn(room);
			LiveRoom.LiveRoomMember member=new LiveRoom.LiveRoomMember();
			member.setUserId(room.getUserId());
			member.setCreateTime(DateUtil.currentTimeSeconds());
			member.setNickName(getUserManager().getUser(room.getUserId()).getNickname());
			member.setType(1);
			member.setRoomId(room.getRoomId());
            liveRoomMemberDao.addLiveRoomMember(member);
			return room;
	}
	//修改直播间信息
	public void updateLiveRoom(Integer userId,LiveRoom room){
//		Query<LiveRoom> query = getDatastore().createQuery(getEntityClass()).field("roomId").equal(room.getRoomId()).field("userId").equal(userId);
//		UpdateOperations<LiveRoom> ops=createUpdateOperations();
		Map<String,Object> map = new HashMap<>();
		if(!StringUtil.isEmpty(room.getName()))
		    map.put("name", room.getName());
//			ops.set("name", room.getName());
		if(!StringUtil.isEmpty(room.getUrl()))
		    map.put("url", room.getUrl());
//			ops.set("url", room.getUrl());
		if(!StringUtil.isEmpty(room.getNotice()))
		    map.put("notice", room.getNotice());
//			ops.set("notice", room.getNotice());
//		ops.set("currentState", room.getCurrentState());
        map.put("currentState", room.getCurrentState());
//		ops.disableValidation();
		
//		UpdateResults update = getDatastore().update(query, ops);
//		if(update.getUpdatedCount()<=0){
//			throw new ServiceException(KConstants.ResultCode.UpdateFailure);
//		}
		liveRoomDao.updateLiveRoom(room.getRoomId(),userId,map);
	}
	
	//删除直播间
	public void deleteLiveRoom(ObjectId roomId){
//		Query<LiveRoom> query=getDatastore().createQuery(LiveRoom.class).field("_id").equal(roomId);
//		LiveRoom liveRoom = query.get();
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		if(null !=liveRoom){
			// 删除聊天记录
			messageRepository.deleteMucMsg(liveRoom.getJid());
			//删除直播间中的成员
//			Query<LiveRoomMember> merquery=getDatastore().createQuery(LiveRoomMember.class);
//			merquery.filter("roomId", roomId);
//			getDatastore().delete(merquery);
            liveRoomMemberDao.deleteLiveRoomMember(roomId);
			
			//删除群组离线消息记录
			messageRepository.dropRoomChatHistory(liveRoom.getJid());
			// 删除直播间
//			getDatastore().delete(query);
            liveRoomDao.deleteLiveRoom(roomId);
		}
		
	}
	
	//开始/结束直播
	public void start(ObjectId roomId,int status){
        Integer currentState = liveRoomDao.getLiveRoom(roomId).getCurrentState();
		if(1 == currentState) 
			throw new ServiceException(KConstants.ResultCode.LiveRoomLock);
        Map<String,Object> map = new HashMap<>();
        map.put("status", status);
        liveRoomDao.updateLiveRoom(roomId,0,map);
	}
	
	//后台查询所有房间
	public PageResult<LiveRoom> findConsoleLiveRoomList(String name, String nickName, Integer userId, Integer page, Integer limit, int status, int type){
		PageResult<LiveRoom> result=new PageResult<LiveRoom>();
        result = liveRoomDao.findLiveRoomList(name,nickName,userId,status,page,limit,type);
		for (LiveRoom liveRoom : result.getData()) {
			if(!liveRoom.getUrl().contains("//")){
				liveRoom.setUrl(SKBeanUtils.getImCoreService().getClientConfig().getLiveUrl()+liveRoom.getUrl());
			}
		}
		return result;
	}
	
	//查询所有房间
	public List<LiveRoom> findLiveRoomList(String name,String nickName,Integer userId,Integer page, Integer limit,int status,int type){
        PageResult<LiveRoom> pageResult = liveRoomDao.findLiveRoomList(name,nickName,userId,status,page,limit,type);
		for (LiveRoom liveRoom : pageResult.getData()) {
			if(!liveRoom.getUrl().contains("//")){
				liveRoom.setUrl(SKBeanUtils.getImCoreService().getClientConfig().getLiveUrl()+liveRoom.getUrl());
			}
			/*else if(DateUtil.currentTimeSeconds()-liveRoom.getCreateTime()>3600){
				roomList.remove(liveRoom);
			}	*/
		}
		return pageResult.getData();
	}
	
	//加入直播间
	public boolean enterIntoLiveRoom(Integer userId,ObjectId roomId){
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
        if(null==liveRoom){
			throw new ServiceException(KConstants.ResultCode.DataNotExists);
		}
		if(!userId.equals(liveRoom.getUserId()) && 0 == liveRoom.getStatus())
			throw new ServiceException(KConstants.ResultCode.LiveRoomNotStart);
        LiveRoomMember liveRoomMember = liveRoomMemberDao.getLiveRoomMember(roomId,userId);
        Black black = blackDao.getBlack(roomId,userId);
		//成员是否在黑名单
		if(null == black){
			User user=getUserManager().getUser(userId);
			//房间是否存在改用户
			if(null!=liveRoomMember){
                Map<String,Object> map = new HashMap<>();
                map.put("online", 1);
                liveRoomMemberDao.updateLiveRoomMember(roomId,userId,map);
			}else{
				LiveRoomMember member=new LiveRoomMember();
				member.setUserId(userId);
				member.setRoomId(roomId);
				member.setCreateTime(DateUtil.currentTimeSeconds());
				member.setNickName(getUserManager().getUser(userId).getNickname());
				member.setOnline(1);
				member.setType(userId.equals(liveRoom.getUserId())? 1 : 3);
                liveRoomMemberDao.addLiveRoomMember(member);
			    liveRoomDao.updateLiveRoomNum(roomId,1);
			}
			MessageBean messageBean=new MessageBean();
			messageBean.setType(MessageType.JOINLIVE);
			messageBean.setContent(liveRoom.getName());
			messageBean.setObjectId(liveRoom.getJid());
			messageBean.setFileName(liveRoom.getRoomId().toString());
			messageBean.setToUserId(user.getUserId()+"");
			messageBean.setToUserName(user.getNickname());
			messageBean.setMessageId(StringUtil.randomUUID());
			// 发送群聊
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
			return true;
		}else{
			throw new ServiceException(KConstants.ResultCode.KickedLiveRoom);
		}
		
		
		
	}
	//后台退出直播间
	public void exitLiveRoom(Integer userId,ObjectId roomId){
		//删除直播间成员
        LiveRoomMember liveRoomMember=liveRoomMemberDao.getLiveRoomMember(roomId,userId);
		User user=getUserManager().getUser(userId);
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);

		if(null==liveRoomMember||liveRoomMember.getOnline()==0)
			return;
		
		if(liveRoomMember.getType()==3&&liveRoomMember.getState()!=1){
            liveRoomMemberDao.deleteLiveRoomMember(roomId,userId);
			//修改直播间总人数
			if(liveRoom.getNumbers()<=0){
				return;
			}else{
                liveRoomDao.updateLiveRoomNum(roomId,-1);
			}
		}else{
			if(liveRoomMember.getType()==1){
                Map<String,Object> map = new HashMap<>();
                map.put("online", 0);
                liveRoomMemberDao.updateLiveRoomMember(roomId,userId,map);
                blackDao.deleteBlack(roomId);
			}else{
                Map<String,Object> map = new HashMap<>();
                map.put("online", 0);
                liveRoomMemberDao.updateLiveRoomMember(roomId,userId,map);
			}
		}
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.LiveRoomSignOut);
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setFromUserId(user.getUserId()+"");
		messageBean.setFromUserName(user.getNickname());
		messageBean.setToUserId(user.getUserId()+"");
		messageBean.setToUserName(user.getNickname());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);

	}

	// 用户离线后移出直播间
	public void OutTimeRemoveLiveRoom(Integer userId){
		List<LiveRoomMember> memberList=liveRoomMemberDao.queryLiveRoomMemberList(userId);
		memberList.forEach(liveRoomMember -> {
			LiveRoom liveRoom = liveRoomDao.getLiveRoom(liveRoomMember.getRoomId());
			User user=getUserManager().getUser(userId);
			if(null == liveRoom){
				return;
			}
			if(null==liveRoomMember||liveRoomMember.getOnline()==0)
				return;

			if(liveRoomMember.getType()==3&&liveRoomMember.getState()!=1){
				liveRoomMemberDao.deleteLiveRoomMember(liveRoom.getRoomId(),userId);
				//修改直播间总人数
				if(liveRoom.getNumbers()<=0){
					return;
				}else{
					liveRoomDao.updateLiveRoomNum(liveRoom.getRoomId(),-1);
				}
			}else{
				if(liveRoomMember.getType()==1){
					Map<String,Object> map = new HashMap<>();
					map.put("online", 0);
					liveRoomMemberDao.updateLiveRoomMember(liveRoom.getRoomId(),userId,map);
					blackDao.deleteBlack(liveRoom.getRoomId());
				}else{
					Map<String,Object> map = new HashMap<>();
					map.put("online", 0);
					liveRoomMemberDao.updateLiveRoomMember(liveRoom.getRoomId(),userId,map);
				}
			}

			MessageBean messageBean=new MessageBean();
			messageBean.setType(MessageType.RemoveLiveRoom);
			messageBean.setObjectId(liveRoom.getJid());
			messageBean.setFromUserId(user.getUserId()+"");
			messageBean.setFromUserName(user.getNickname());
			messageBean.setToUserId(user.getUserId()+"");
			messageBean.setToUserName(user.getNickname());
			messageBean.setMessageId(StringUtil.randomUUID());
			// 如果是创建者
			if(liveRoomMember.getType()==1){
				messageBean.setOther(userId.toString());
			}
			// 发送群聊通知
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
			messageBean.setMsgType(0);
			messageService.send(messageBean);
		});


	}

	//踢出直播间
	public void kick(Integer userId,ObjectId roomId){
		/*//删除直播间成员
		*/
		LiveRoomMember liveRoomMember = liveRoomMemberDao.getLiveRoomMember(roomId,userId);
		if(null == liveRoomMember){
			throw new ServiceException(KConstants.ResultCode.NotInLiveRoom);
		}
		LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		//修改直播间总人数
		if(liveRoom.getNumbers()<=0){
			return;
		}else{
            liveRoomDao.updateLiveRoomNum(roomId,-1);
		}
		User touser=getUserManager().getUser(userId);
		if(touser==null){
			return;
		}
		User user=getUserManager().getUser(ReqUtil.getUserId());
		
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.LiveRoomSignOut);
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setFromUserId(user.getUserId()+"");
		messageBean.setFromUserName(user.getNickname());
		messageBean.setToUserId(touser.getUserId()+"");
		messageBean.setToUserName(touser.getNickname());
		messageBean.setMessageId(StringUtil.randomUUID());
		try {
			// 发送群聊通知
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
			ThreadUtils.executeInThread((Callback) obj ->
					liveRoomMemberDao.deleteLiveRoomMember(roomId,userId)
			);
		} catch (Exception e) {	
			// TODO: handle exception
		}
		//添加到黑名单
		Black black=new Black();
		black.setRoomId(roomId);
		black.setUserId(userId);
		black.setTime(DateUtil.currentTimeSeconds());
        blackDao.addBlack(black);
	}
	
	//解锁、锁定直播间
	public void operationLiveRoom(ObjectId roomId, int currentState) {
		// 处理直播间的状态
        Map<String,Object> map = new HashMap<>();
        map.put("currentState", currentState);
        map.put("status", 0);// 关闭直播
        liveRoomDao.updateLiveRoom(roomId,0,map);
		// 通知处理
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		User user = getUserManager().getUser(liveRoom.getUserId());
		MessageBean messageBean = new MessageBean();
		messageBean.setType(MessageType.RoomDisable);
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setFromUserId(10005 + "");
		messageBean.setFromUserName("后台管理员");
		messageBean.setToUserId(user.getUserId() + "");
		messageBean.setToUserName(user.getNickname());
		messageBean.setMessageId(StringUtil.randomUUID());
		try {
			// 发送群聊通知
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	//查询房间成员
	public List<LiveRoomMember> findLiveRoomMemberList(ObjectId roomId,int pageIndex,int pageSize){
       return liveRoomMemberDao.getLiveRoomMemberList(roomId,1,pageIndex,pageSize);
	}
	public List<Integer> findMembersUserIds(ObjectId roomId){
		List<Integer> userIds=null;
        userIds = liveRoomMemberDao.findMembersUserIds(roomId,1);
		return userIds;
	}
	
	//获取单个成员
	public LiveRoomMember getLiveRoomMember(ObjectId roomId,Integer userId){
        LiveRoomMember liveRoomMember=liveRoomMemberDao.getLiveRoomMember(roomId,userId);
		return liveRoomMember;
		
	}
	
	//禁言/取消禁言
	public LiveRoomMember shutup(int adminUserId,int state,Integer userId,ObjectId roomId,String talkTime){
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		LiveRoomMember livemember=new LiveRoomMember();
		livemember = liveRoomMemberDao.getLiveRoomMember(roomId,userId);
        if(null == livemember){
        	throw new ServiceException(KConstants.ResultCode.NotInLiveRoom);
		}
		//修改状态
        Map<String,Object> map = new HashMap<>();
        map.put("state", state);
        if(!StringUtil.isEmpty(talkTime)){
			map.put("talkTime",Long.valueOf(talkTime));
		}
        liveRoomMemberDao.updateLiveRoomMember(roomId,userId,map);
		//xmpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.LiveRoomBannedSpeak);
		if(state==1){
			messageBean.setContent(talkTime);
		}else{
			messageBean.setContent(0);
		}
		messageBean.setFromUserId(String.valueOf(adminUserId));
		messageBean.setFromUserName(userCoreService.getNickName(adminUserId));
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setToUserId(livemember.getUserId()+"");
		messageBean.setToUserName(livemember.getNickName());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
		return livemember;
	}
	//添加礼物
	public void addGift(String name,String photo,double price,int type){
		Gift gift=new Gift();
		gift.setName(name);
		gift.setPhoto(photo);
		gift.setPrice(price);
		gift.setType(type);
        giftDao.addGift(gift);

	}
	//删除礼物
	public void deleteGift(ObjectId giftId){
        Gift gift = giftDao.getGift(giftId);
		if(null == gift)
			throw new ServiceException(KConstants.ResultCode.DataNotExists);
        giftDao.deleteGift(giftId);
	}
	
	//后台查询所有的礼物
	public Map<String,Object> consolefindAllgift(String name,int pageIndex,int pageSize){
		Map<String,Object> giftMap = Maps.newConcurrentMap();
        Map<String,Object> map = giftDao.getGiftListMap(name,pageIndex,pageSize);
		giftMap.put("total", map.get("total"));
		giftMap.put("data", map.get("data"));
		return giftMap;
	}
	
	//查询所有的礼物
	public List<Gift> findAllgift(String name,int pageIndex,int pageSize){
        List<Gift> giftList = giftDao.getGiftList(name,pageIndex,pageSize);
		return giftList;
	}

	public Gift queryGift(ObjectId giftId){
		return giftDao.getGift(giftId);
	}

	
	//送礼物
	public synchronized ObjectId giveGift(Integer userId,Integer toUserId,ObjectId giftId,int count,Double price,ObjectId roomId){

		// 礼物对应的总价格
		Double totalMoney = price * count; 
		User user= userCoreService.getUser(userId);

		LiveRoom liveRoom= liveRoomDao.getLiveRoom(roomId);
		Double balance =getUserManager().getUserMoenyV1(userId);
		if(balance<price*count){
			throw new ServiceException(InsufficientBalance);
		}
			Givegift givegift=new Givegift();
			givegift.setUserId(userId);
			givegift.setToUserId(toUserId);
			givegift.setGiftId(giftId);
			givegift.setCount(count);
			givegift.setPrice(price*count);
			givegift.setTime(DateUtil.currentTimeSeconds());
			givegift.setId(ObjectId.get());

			/**
			 * 没有支付模块不扣取余额
			 */
		   if (paymentManager != null){
				giveGiftUserBalanceChange(userId,totalMoney,toUserId,givegift.getId().toString());
			}

            giveGiftDao.addGiveGift(givegift);

			
			//xmpp推送消息
			MessageBean messageBean=new MessageBean();
			messageBean.setType(MessageType.GIFT);
			messageBean.setFromUserId(userId.toString());
			messageBean.setFromUserName(user.getNickname());
			messageBean.setObjectId(liveRoom.getJid());
			messageBean.setContent(giftId.toString());
			messageBean.setMessageId(StringUtil.randomUUID());
			// 发送群聊s
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);

			return giftId;

	}


	/**
	 *送礼物时 用户余额改变的操作
	 * @return
	 */
	private boolean giveGiftUserBalanceChange(int userId,double totalMoney,int toUserId,String businessId){

		try {


			/**
			 * 用户的余额更新日志
			 */
			UserMoneyLog userMoneyLog =new UserMoneyLog(userId,toUserId,businessId,totalMoney,
					MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.LIVE_GIVE_PAY, MoneyLogTypeEnum.NORMAL_PAY);
			Config config=SKBeanUtils.getSystemConfig();
			double giftRatio;
			if(null != config) {
				giftRatio = totalMoney*config.getGiftRatio();
			}else {
				giftRatio = totalMoney*0.50;
			}
			/**
			 * 主播的余额更新日志
			 */
			UserMoneyLog toUserMoneyLog =new UserMoneyLog(toUserId,userId,businessId,giftRatio,
					MoenyAddEnum.MOENY_ADD, MoneyLogEnum.LIVE_GIVE_PAY, MoneyLogTypeEnum.RECEIVE);
			//扣除用户的余额
			getUserManager().rechargeUserMoeny(userMoneyLog);
			//增加主播的余额
			getUserManager().rechargeUserMoeny(toUserMoneyLog);
			// 系统分成
			ThreadUtils.executeInThread(obj -> {
				String tradeNo=StringUtil.getOutTradeNo();
				//创建送礼物记录
				BaseConsumeRecord record=new BaseConsumeRecord();
				record.setUserId(userId);
				record.setToUserId(toUserId);
				record.setTradeNo(tradeNo);
				record.setMoney(totalMoney);
				record.setBusinessId(userMoneyLog.getBusinessId());
				record.setCurrentBalance(userMoneyLog.getEndMoeny());
				record.setStatus(KConstants.OrderStatus.END);
				record.setType(KConstants.ConsumeType.LIVE_GIVE);
				record.setChangeType(KConstants.MOENY_REDUCE);
				record.setPayType(KConstants.PayType.BALANCEAY); //余额支付
				record.setDesc("直播礼物送出");
				record.setTime(DateUtil.currentTimeSeconds());
				record.setOperationAmount(totalMoney-giftRatio);
				record.setServiceCharge(giftRatio);
				paymentManager.addConsumRecord(record);
				tradeNo=StringUtil.getOutTradeNo();
				//创建接受礼物记录
				BaseConsumeRecord recordTo=new BaseConsumeRecord();
				recordTo.setUserId(toUserId);
				recordTo.setToUserId(userId);
				recordTo.setTradeNo(tradeNo);
				recordTo.setMoney(totalMoney);
				recordTo.setCurrentBalance(toUserMoneyLog.getEndMoeny());
				recordTo.setBusinessId(toUserMoneyLog.getBusinessId());
				recordTo.setStatus(KConstants.OrderStatus.END);
				recordTo.setType(KConstants.ConsumeType.LIVE_RECEIVE);
				recordTo.setChangeType(KConstants.MOENY_ADD);
				recordTo.setPayType(KConstants.PayType.BALANCEAY); //余额支付
				recordTo.setDesc("直播礼物收入");
				recordTo.setTime(DateUtil.currentTimeSeconds());
				recordTo.setServiceCharge(giftRatio);
				recordTo.setOperationAmount(totalMoney - giftRatio);
				paymentManager.addConsumRecord(recordTo);
			});
		} catch (Exception e) {
			log.error(e.getMessage(),e.getMessage());
			log.info(" 直播送礼物更新余额异常");
		}
		return true;
	}
	
	//主播收到礼物的列表
	public PageResult<Givegift> getGiftList(Integer userId,String startDate,String endDate,Integer page,Integer limit){
		PageResult<Givegift> result=new PageResult<Givegift>();
		double totalMoney = 0;
		Config config=SKBeanUtils.getSystemConfig();
        List<Givegift> giveGiftList = null;
		PageResult<Givegift> queryResult = giveGiftDao.getGivegift(userId,startDate,endDate,page,limit);
		giveGiftList = queryResult.getData();
		for(Givegift givegift : giveGiftList){
            LiveRoom liveRoom = liveRoomDao.getLiveRoomByUserId(givegift.getToUserId());
			Gift gift = giftDao.getGift(givegift.getGiftId());
            givegift.setGiftName(gift.getName());
            if(null!=liveRoom) {
				givegift.setLiveRoomName(liveRoom.getName());
			}
			givegift.setActualPrice(config.getGiftRatio()*givegift.getPrice());
			// 当前总收入
			totalMoney += givegift.getActualPrice();
			givegift.setUserName(getUserManager().getNickName(givegift.getUserId()));
			givegift.setToUserName(getUserManager().getNickName(givegift.getToUserId()));
		}
		result.setData(giveGiftList);
		result.setCount(queryResult.getCount());
		result.setTotal(totalMoney);
		return result;
		
	}
	
	//购买礼物的记录
	public List<Givegift> giftdeal(Integer userId,int pageIndex,int pageSize){
        List<Givegift> givegiftList = giveGiftDao.getGiveGiftList(userId,0,pageIndex,pageSize,0);
		return givegiftList;
	}
	//发送弹幕
	public ObjectId barrage(Integer userId,ObjectId roomId,String text){
		User user= getUserManager().getUser(userId);
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		int price=1;
		ObjectId barrageId=null;
		Double balance = getUserManager().getUserMoenyV1(userId);
		if(balance>=1*price){
			Givegift givegift=new Givegift();
			givegift.setCount(1);
			givegift.setPrice(1.0);
			givegift.setUserId(userId);
			givegift.setTime(DateUtil.currentTimeSeconds());
			givegift.setId(ObjectId.get());



			if(null!=paymentManager){
				/**
				 * 用户的余额更新日志
				 */
				UserMoneyLog userMoneyLog =new UserMoneyLog(userId,0,givegift.getId().toString(),givegift.getPrice(),
						MoenyAddEnum.MOENY_REDUCE, MoneyLogEnum.LIVE_GIVE_PAY, MoneyLogTypeEnum.NORMAL_PAY);
				getUserManager().rechargeUserMoeny(userMoneyLog);

			}


			giveGiftDao.addGiveGift(givegift);
			barrageId=givegift.getGiftId();//xmpp推送
			MessageBean messageBean=new MessageBean();
			messageBean.setType(MessageType.BARRAGE);
			messageBean.setFromUserId(userId.toString());
			messageBean.setFromUserName(user.getNickname());
			messageBean.setObjectId(liveRoom.getJid());
			messageBean.setContent(text);
			messageBean.setMessageId(StringUtil.randomUUID());
			/*try {
				List<Integer> userIdlist=findMembersUserIds(roomId);
				KXMPPServiceImpl.getInstance().send(userIdlist,messageBean.toString());
			} catch (Exception e) {
				// TODO: handle exception
			}*/
			// 发送群聊
			messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
			return barrageId;
		}else{
		 throw new ServiceException(InsufficientBalance);
		}
		
	}
	//设置/取消管理员
	public void setmanage(Integer userId,int type,ObjectId roomId){
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		if(userId == liveRoom.getUserId())
			throw new ServiceException(KConstants.ResultCode.NotSetAnchorIsAdmin);
        LiveRoomMember liveRoomMember = liveRoomMemberDao.getLiveRoomMember(roomId,userId);
		if(null == liveRoomMember){
			throw new ServiceException(KConstants.ResultCode.NotInLiveRoom);
		}
		if(liveRoomMember.getType() == type)
			throw new ServiceException(KConstants.ResultCode.NotRepeatOperation);
        Map<String,Object> map = new HashMap<>();
        map.put("type", type);
        liveRoomMemberDao.updateLiveRoomMember(roomId,userId,map);
		//xmpp推送
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.LiveRoomSettingAdmin);
		if(type==2){//1为设置管理员
			messageBean.setContent(1);
		}else{
			messageBean.setContent(0);
		}
		messageBean.setFromUserId(liveRoom.getUserId().toString());
		messageBean.setFromUserName(liveRoom.getNickName());
		messageBean.setToUserName(liveRoomMember.getNickName());
		messageBean.setToUserId(liveRoomMember.getUserId().toString());
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊通知
		messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);

	}
	//点赞
	public void addpraise(ObjectId roomId){
        LiveRoom liveRoom = liveRoomDao.getLiveRoom(roomId);
		//xmpp消息
		MessageBean messageBean=new MessageBean();
		messageBean.setType(MessageType.LIVEPRAISE);
		messageBean.setObjectId(liveRoom.getJid());
		messageBean.setMessageId(StringUtil.randomUUID());
		// 发送群聊
		messageService.sendMsgToGroupByJid(liveRoom.getJid(), messageBean);
	}
	
	//定时清除直播间
	public void clearLiveRoom(){
        liveRoomDao.clearLiveRoom();
	}

}

package com.shiku.im.service;

import com.alibaba.fastjson.JSONObject;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.config.XMPPConfig;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.model.PressureParam;
import com.shiku.im.model.PressureThread;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.user.dao.UserCoreDao;
import com.shiku.im.user.service.impl.UserManagerImpl;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/** @version:（1.0） 
* @ClassName	PressureTest
* @Description: （压力测试） 
* @date:2018年11月13日下午5:46:54  
*/
@Slf4j
@Service
public class PressureTestManagerImpl {
	
	@Autowired(required=false)
	private XMPPConfig xmppConfig;
	@Autowired
	private UserCoreDao userCoreDao;

	@Autowired
	private RoomManagerImplForIM roomManager;

	@Autowired
	private UserManagerImpl userManager;

	@Autowired
	private IMessageRepository messageRepository;


	
	private int runStatus=0;//任务 运行状态   0  无任务   1  运行中  
	
	final ScheduledExecutorService threadPool = Executors.newScheduledThreadPool(Runtime.getRuntime().availableProcessors()*2);
	
	private void InitializeBuilder(){

	}
	
	
	/**
	 *	1. 群内生成1000个用户 
	 *  
	 *  2. 模拟四百个用户发送消息   ===》 机器人  不够自动创建
	 *  
	 *  3. 可以 发送总条数、每秒条数 
	 */
	
	
	/** @Description:（创建一定数量的机器人） 
	* @param checkNum
	* @param jids
	**/ 
	public void createRobot(int checkNum,List<String> jids,Integer adminUserId){
		// 筛选群内离线的人，不够checkNum则创建机器人
		for (String jid : jids) {
			List<Integer> offlineUsers = new ArrayList<Integer>();
			ObjectId roomId = roomManager.getRoomId(jid);
			List<Integer> memberIds = roomManager.getCommonMemberIdList(roomId);
			int createNum = (int) (checkNum - memberIds.size());
			if(createNum > 0){
				List<Integer> addRobots = userManager.addRobot(createNum, true, roomId, adminUserId);
				offlineUsers.addAll(memberIds);
				offlineUsers.addAll(addRobots);
				log.info("群："+jid+"   需要创建机器人的个数："+createNum);
			}else {
				/**
				 * 人数 大于 三倍 随机取
				 */
				if(3<(memberIds.size()/checkNum)) {
					for (int i = 0; i <checkNum; i++) {
						Integer num = NumberUtil.getRandomByMinAndMax(1, memberIds.size());
						while (offlineUsers.contains(num)) {
							num = NumberUtil.getRandomByMinAndMax(1, memberIds.size());
						}
						offlineUsers.add(memberIds.get(num-1));
						memberIds.remove(num);
					}
				}else {
					offlineUsers.addAll(memberIds);
				}
			}
			// 人数足够 checkNum 后生成xmpp conn


			System.out.println("群："+jid+"   选中的conn：");

		}
	}
	
	
	
	public PressureParam.PressureResult mucTest(PressureParam param,Integer adminUserId){
		try {
			if(1==runStatus) {
				log.error("已有压测 任务 运行中  请稍后 请求 。。。。。。");
				return null;
			}
			System.out.println("压力测试："+" roomJids: "+JSONObject.toJSONString(param.getJids())+" checkNum: "+param.getCheckNum()+" sendMsgNum: "+param.getSendMsgNum()
					+"  消息时间间隔:"+param.getTimeInterval());
			runStatus=1;
			closeConnection();
			param.setAtomic(new AtomicInteger(0));
			
			String format = new SimpleDateFormat("MM-dd HH:mm").format(System.currentTimeMillis());
		
			param.setTimeStr(format);
			createRobot(param.getCheckNum(), param.getJids(), adminUserId);

			
			List<PressureThread> threads=Collections.synchronizedList(new ArrayList<>());
			for (String jid : param.getJids()) {


				String roomName = roomManager.getRoomName(jid);
				threads.add(new PressureThread(jid,roomName, param, null));
				
			}
			param.setStartTime(System.currentTimeMillis());// 开始时间
			
			Set<ScheduledFuture> threadFutures=new HashSet<ScheduledFuture>();
			threads.forEach(th ->{
				ScheduledFuture<?> scheduledFuture = threadPool.scheduleAtFixedRate(th,1000, param.getTimeInterval(),TimeUnit.MILLISECONDS);
				threadFutures.add(scheduledFuture);
			});
			
			PressureParam.PressureResult result=null;
			while (runStatus==1) {
				if (param.getAtomic().get()>=param.getSendAllCount()) {
					try {
						//threadPool.shutdown();
						
						threadFutures.stream().forEach(th->{ th.cancel(false); });
						 
						param.setConns(null);
						result = new PressureParam.PressureResult();
						result.setTimeCount((System.currentTimeMillis() - param.getStartTime()) / 1000);
						result.setSendAllCount(param.getSendAllCount());
						result.setTimeStr(param.getTimeStr());
						log.info("任务执行完毕 ：" + JSONObject.toJSONString(param));
						
						runStatus=2;
						break;
					} catch (Exception e) {
						e.printStackTrace();
						break;
					}
				}else {
					Thread.sleep(1000);
				}
			}
			runStatus=0;
			return result;
		} catch (Exception e) {
			runStatus=0;
			return  new PressureParam.PressureResult();
		}
		
		/*try {
			Thread.sleep(60000);
		} catch (Exception e) {
			e.printStackTrace();
		}*/
		
		
	}
	
	
	private void closeConnection() {
					
	}

	




	
	
}

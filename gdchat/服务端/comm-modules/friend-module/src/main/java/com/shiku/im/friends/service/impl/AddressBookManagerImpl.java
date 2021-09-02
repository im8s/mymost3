package com.shiku.im.friends.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.entity.Config;
import com.shiku.im.friends.dao.AddressBookDao;
import com.shiku.im.friends.entity.AddressBook;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.message.MessageService;
import com.shiku.im.message.MessageType;
import com.shiku.im.support.Callback;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.StringUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
@Slf4j
@Service
public class AddressBookManagerImpl{

	@Autowired
	private AddressBookDao addressBookDao;

	@Autowired(required = false)
	@Lazy
	private MessageService messageService;

	@Autowired(required = false)
	private FriendsManagerImpl friendsManager;

	@Autowired
	private UserCoreService userCoreService;

	private static Config getSystemConfig(){
		return SKBeanUtils.getSystemConfig();
	}

	
	public List<AddressBook> uploadTelephone(User user, String deleteStr, String uploadStr, String uploadJsonStr){
		List<AddressBook> books = null;
		if(!StringUtil.isEmpty(deleteStr))
			deleteByStrs(user.getUserId(), deleteStr);
		else if(!StringUtil.isEmpty(uploadStr))
			books =	uploadTelephone(user.getUserId(),user.getTelephone(), uploadStr);
		else if(!StringUtil.isEmpty(uploadJsonStr)){
			books =	uploadJsonTelephone(user.getUserId(),user.getTelephone(), uploadJsonStr);
		}
		return books;
	}
	
	/** @Description:（新版通讯录） 
	* @param userId
	* @param telephone
	* @param
	* @return
	**/ 
	private List<AddressBook> uploadJsonTelephone(Integer userId, String telephone, String uploadJsonStr ) {
		List<AddressBook> address = JSONObject.parseArray(uploadJsonStr, AddressBook.class);
		List<AddressBook> bookList = new ArrayList<AddressBook>();
		for(int i = 0; i < address.size(); i++){
			String repPhone = address.get(i).getToTelephone();
			String toTelephone = repPhone.replace(" ", "");
			toTelephone = toTelephone.replace("-", "");
			User user = null;
				if (0 < get(userId, toTelephone))
					continue;
				if(toTelephone.equals(telephone))
					continue;// 不能让自己成为自己的通讯录好友
				try {
					user =userCoreService.getUser(toTelephone);
				} catch (Exception e) {
					log.debug("该通讯录好友不是本平台用户:{}", toTelephone);
				}
				AddressBook saveBook = saveBook(telephone, toTelephone, user, userId, address.get(i).getToRemarkName());
				bookList.add(saveBook);

		}
		addressBookDao.addAddressBookList(bookList);
		//logger.info("====>  导入完成后：   用户：  "+userId  +"  的 通讯录好友： "+JSONObject.toJSONString(bookList));
		return bookList.stream().
				filter(book -> 1==book.getRegisterEd())
				.collect(Collectors.toList());
	}
	
	/** @Description:（普通版通讯录） 
	* @param userId
	* @param telephone
	* @param strs
	* @return
	**/ 
	private List<AddressBook> uploadTelephone(Integer userId, String telephone, String strs) {
		strs = strs.replace(" ", "");
		strs = strs.replace("-", "");
		String[] array = strs.split(",");
		User user = null;
		List<AddressBook> bookList = new ArrayList<AddressBook>();
		for (String str : array) {
			if (0 < get(userId, str))
				continue;// 不能让自己成为自己的通讯录好友
			user = userCoreService.getUser(str);
			if(str.equals(telephone))
				continue;
			AddressBook saveBook = buildAddressBook(telephone, str, user, userId);
			bookList.add(saveBook);
			
		}
		addressBookDao.addAddressBookList(bookList);
		return bookList.stream().
				filter(book -> 1==book.getRegisterEd())
				.collect(Collectors.toList());
	}

	private AddressBook saveBook(String telephone, String str, User user, Integer userId, String toRemark) {
		AddressBook book = null;
		book = new AddressBook();
		book.setTelephone(telephone);
		book.setToTelephone(str);
		book.setRegisterEd(null == user ? 0 : 1);
		book.setUserId(userId);
		book.setToUserId(null == user ? null : user.getUserId());
		book.setRegisterTime(null == user ? 0 : user.getCreateTime());
		book.setToUserName(null == user ? null : user.getNickname());
		book.setToRemarkName(toRemark);
		if(null != user){
			Friends friends = friendsManager.getFriends(userId, user.getUserId());
			if(null == friends && 0 == getSystemConfig().getIsAutoAddressBook())
				book.setStatus(0);
			else if(null != friends && 2 == friends.getStatus())
				book.setStatus(2);
			else if(0 == getSystemConfig().getIsAutoAddressBook()){// 不自动添加
				book.setStatus(0);
			}else if (1 == getSystemConfig().getIsAutoAddressBook()) {
				book.setStatus(1);
			}
		}else {// 没有注册im
			book.setStatus(0);
		}
		
		if(null != user && getSystemConfig().getIsAutoAddressBook()==1){
			ThreadUtils.executeInThread(new Callback() {
				
				@Override
				public void execute(Object obj) {
					Map<String, String> bookMap = Maps.newConcurrentMap();
					bookMap.put("toUserId", String.valueOf(user.getUserId()));
					bookMap.put("toRemark", toRemark);
					autofollowUser(userId, bookMap);
				}
			});
			
		}
		return book;
	}
	private AddressBook buildAddressBook(String telephone, String str, User user, Integer userId) {
		AddressBook book = new AddressBook();
		book.setTelephone(telephone);
		book.setToTelephone(str);
		book.setRegisterEd(user == null ? 0 : 1);
		book.setUserId(userId);
		book.setToUserId(user == null ? null : user.getUserId());
		book.setRegisterTime(user == null ? 0 : user.getCreateTime());
		book.setToUserName(user == null ? null : user.getNickname());
		return book;
	}
	private AddressBook saveBook(String telephone, String str, User user, Integer userId) {
		AddressBook book = null;
		book = new AddressBook();
		book.setTelephone(telephone);
		book.setToTelephone(str);
		book.setRegisterEd(user == null ? 0 : 1);
		book.setUserId(userId);
		book.setToUserId(user == null ? null : user.getUserId());
		book.setRegisterTime(user == null ? 0 : user.getCreateTime());
		book.setToUserName(user == null ? null : user.getNickname());
		addressBookDao.addAddressBook(book);
		return book;
	}
	
	/** @Description:（自动成为好友） 
	* @param
	* @param addressBook
	**/ 
	public void autofollowUser(Integer userId,Map<String, String> addressBook){
		friendsManager.autofollowUser(userId, addressBook);
	}
	
	
	
	public void notifyBook(String telephone,Integer userId,String nickName,Long registerTime){
		System.out.println("注册时修改数据："+"telephone:"+telephone+"   toUserId:"+userId+"    nickName:"+nickName+"   registerTime:"+registerTime);
		addressBookDao.updateAddressBook(telephone,userId,nickName,registerTime,0 == getSystemConfig().getIsAutoAddressBook() ? 0 : 1);
		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
				notifyBook(telephone);
			}
			
		});
	}
	public void notifyBook(String telephone){
		System.out.println("推送使用的电话号码："+telephone);
		//a注册   a给b发xmpp通知他我们成为通讯录好友
		List<AddressBook> list = queryListByToTelephone(telephone);
		ThreadUtils.executeInThread(new Callback() {
			@Override
			public void execute(Object obj) {
					for(AddressBook book :list){
						MessageBean messageBean=new MessageBean();
						messageBean.setType(MessageType.registAddressBook);
						messageBean.setFromUserId(String.valueOf(book.getToUserId()));
						messageBean.setFromUserName(book.getToUserName());
						messageBean.setToUserId(String.valueOf(book.getUserId()));
						messageBean.setToUserName(userCoreService.getNickName(book.getUserId()));
						messageBean.setContent(JSONObject.toJSON(book));
						messageBean.setMsgType(0);// 单聊消息
						messageBean.setMessageId(StringUtil.randomUUID());
						try {
							messageService.send(messageBean);
						} catch (Exception e) {
							e.printStackTrace();
						}
						
					}
			}
		});
	}
	
	private void deleteByStrs(int userId,String strs){
		strs=strs.replace(" ", "");
		strs=strs.replace("-", "");
		String[] deleteArray=strs.split(",");
		addressBookDao.deleteAddressBook(userId,deleteArray);
	}
	
	public List<AddressBook> findRegisterList(int userId,int pageIndex,int pageSize){
		User user = userCoreService.getUser(userId);
		List<AddressBook> list = addressBookDao.queryRegisterEdList(user.getUserId(),1,pageIndex,pageSize);
		list.forEach(book ->{
			book.setToUserName(userCoreService.getNickName(book.getToUserId()));
		});
		return list;
	}
	public List<AddressBook> queryListByToTelephone(String telephone){
		return addressBookDao.queryListByToTelephone(telephone);
	}
	public long get(int userId,String toTelephone){
		return addressBookDao.getAddressBookAllCount(userId,toTelephone);
	}
	
	public boolean get(String telephone,Integer toUserId){
		return addressBookDao.getAddressBook(telephone,toUserId)!=null;
	}
	
	public void delete(String telephone,String toTelephone,Integer userId){
		addressBookDao.deleteAddressBook(telephone,toTelephone,userId);
	}
	
	public void deleteAddressBook(Integer userId,Integer toUserId){
		addressBookDao.deleteAddressBook(userId,toUserId);
	}
	
	public List<AddressBook> getAll(int userId,int pageIndex,int pageSize){
		return addressBookDao.queryRegisterEdList(userId,1,pageIndex,pageSize);
	}

	public PageResult<AddressBook> getAllForAdmin(int userId, int pageIndex, int pageSize){
		return addressBookDao.queryAddressBookForAdmin(userId,pageIndex,pageSize);
	}

	public void checkAddressBook(String toTelephone,Integer toUserId){
		List<String> list = addressBookDao.queryTelephoneListToTelephone(toTelephone);

		for (String telephone : list) {
			
//			query=new BasicDBObject("telephone", telephone.toString());
//			query.append("toTelephone", toTelephone);
//			obj=(BasicDBObject) findOne(query);
//			obj = addressBookDao.get
//			if(1==obj.getInt("registerEd"))
//				continue;
//			query.append("registerEd", 0);
//			value=new BasicDBObject("registerEd", 1);
//			long registerTime= DateUtil.currentTimeSeconds();
//			value.append("registerTime",registerTime);
//			value.append("toUserId", toUserId);
			
		}
		
	}
	//注销手机号码
	public void writeOffUser(String telephone){
		addressBookDao.updateAddressBook(telephone);
	}
	

	
	// 获取通讯录好友
	public List<Integer> getAddressBookUserIds(Integer userId){
		List<AddressBook> list = addressBookDao.queryListByUserId(userId);
		List<Integer> userIds = new ArrayList<Integer>();
		list.forEach(addressBook ->{
			userIds.add(addressBook.getToUserId());
		});
		log.info("用户 "+userId+" : 的通讯录好友:{}",JSONObject.toJSONString(userIds));
		return userIds;
	}
}
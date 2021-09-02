/*
	页面数据的封装
	页面数据的处理
	页面数据的获取
*/

var DataMap={
	userMap:{},
	userSetting:{},
	friends:{},
	msgMap:{},
	msgRecordList:{},//好友聊天记录
	msgNum:{},
	myRooms:[],
	rooms:[],
	allFriendsUIds:{}, //存放所有的好友和单向关注用户的userId    key:userId  value :userId
	blackListUIds:{},  //存放已加入黑名单的userId    key:userId  value :userId
	msgStatus:{}, //存方发送消息的状态   key messageId  value 1:送达 2:已读  
	unReadMsg : {}, //存放未读消息    key : 发送方的userId  value: Array[] 存放该用户的所有未读消息(保证先后顺序)
	//msgEndTime : {}, //存放消息记录的结束时间   key: 发送方的userId   value: 结束时间
	loginData:null ,//用户登陆信息
	deleteRooms:{},//储存被踢出的群数据
	talkTime:{}, //储存我的禁言时间  key : 群的id   value: talkTime  我在该群禁言截止时间，为空则没有被禁言        
 	msgIds:[], //储存消息id ，只存最近10条
 	timeSendLogMap:{}, //消息发送时间保存
 	deleteFriends:{}/*删除的好友 或群组*/

 }
var Constant={
	loginData:"loginData"
	
}

//临时变量
var Temp={
	user:null,
	friend:null,
	toJid:null,
	toUserId:null,//临时变量
	toNickname:null,
	msgId:null,
	message:null,
	copyMsg:null,//复制的消息
	minTimeSend:0,//当前聊天好友的 历史记录 最早时间
	file:null,
	//上传文件操作 标识  sendImg 发送图片 //  sendFile 发送文件  uploadFile 群文件上传 
	uploadType:"sendImg",
	//弹出好友列表 标识  sendCard 发送名片  @Member @群成员
	//  forward  转发消息
	friendListType:"sendCard", 
	//左边菜单栏标识 当前在哪个菜单
	////messages  聊天列表界面
	leftTitle:"messages",
	//当前列表页面  列表标识  当前在哪个列表
	//messageList  聊天列表界面
	nowList:"messageList",

	roomRole:3,//我在当前群组的 权限标识
	members:{},//当前聊天界面的 成员集合

	

	setJid:function(userId){
		this.toUserId=userId;
		this.toJid=userId;
	}
}

var groupMsgReadList = {};  //用于存放群组消息已读用户列表数据 key ：msgId, value : List<user>  msgId:消息id  user:封装已读用户数据userId,nickname,timeSend 
var groupMsgReadNum = {};   //用于存放群组消息已读数量  key :msgId   value:num 已读数量
var msgHistory = {};  //储存用于获取聊天历史记录的数据
var msgNumCount = 0;  //记录用户接收到的(未读)消息数量
var friendRelation = {}; //记录好友关系  key：userId  value： true/false  true:是好友 false:不是好友


var DataUtils={

	/*
	刷新 当前 当前会话 聊天记录最小时间  拉取漫游使用
	*/
	refreshUIMinTimeSend:function(timeSend,isDel){
		if(isDel){
			Temp.minTimeSend=0;
			return;
		}

		if(0==Temp.minTimeSend)
			Temp.minTimeSend=timeSend;
		else if(Temp.minTimeSend>timeSend){
			Temp.minTimeSend=timeSend;
		}
	},
	getStreamId:function(){
		return DBUtils.getStreamId();
	},
	setStreamId:function(streamId){
		DBUtils.setStreamId(streamId);
	},
	getIsEncrypt:function(){
		//shikuLog("===> getLogoutTime "+value);
		var isEncrypt=myData.isEncrypt;
		if(myFn.isNil(isEncrypt)){
			isEncrypt= DBUtils.getIsEncrypt();
			if(myFn.isNil(isEncrypt)){
				isEncrypt= 0;
				this.setIsEncrypt(isEncrypt);
			}
			myData.isEncrypt=isEncrypt;

		}
        WEBIM.setEncrypt(1 == isEncrypt);
		return isEncrypt;
	},
	setIsEncrypt:function(value){
		myData.isEncrypt=value;
		DBUtils.setIsEncrypt(value);
		shikuLog("===> setIsEncrypt "+value);
	},
	getGroupMsgFromUserName(msg,userId,defaultName){
		var member=Temp.members[userId];
		var friend =DataMap.friends[userId];
		if(!myFn.isNil(member)){
			if(!myFn.isNil(member.remarkName)){
				msg.fromUserName=member.remarkName;
			}else if(!myFn.isNil(friend)){
				if(!myFn.isNil(friend.remarkName)){
					msg.fromUserName=friend.remarkName;
				}else {
					msg.fromUserName=member.nickname;
				}
						
			}else{
				msg.fromUserName=member.nickname;
			}
		}else if(!myFn.isNil(friend)){
			if(!myFn.isNil(friend.remarkName))
				msg.fromUserName=friend.remarkName;
		}
		 if(myFn.isNil(msg.fromUserName)){
		 	if(!myFn.isNil(defaultName))
		 		msg.fromUserName=defaultName;
		 	else
				msg.fromUserName=userId;
		}
		
		return msg.fromUserName;
	},
	getLogoutTime:function(){
		//shikuLog("===> getLogoutTime "+value);
		return DBUtils.getLogoutTime();
	},
	setLogoutTime:function(time){
		DBUtils.setLogoutTime(time);
		shikuLog("===> setLogoutTime "+time);
	},
	/*获取好友聊天记录*/
	getMsgRecordListKey:function(userId){
		if(myData.userId==WEBIM.getUserIdFromJid(userId))
			return userId;
		else
			return WEBIM.getBareJid(userId);
	},
	getMsgRecordList:function(userId,isKey){
		if(1!=isKey)
			userId=this.getMsgRecordListKey(userId);
		var arrList=DataMap.msgRecordList[userId];
		if(myFn.isNil(arrList)){
			arrList=DBUtils.getMsgRecordList(userId);
			DataMap.msgRecordList[userId]=arrList;
		}
		return arrList;
	},
	setMsgRecordList:function(userId,arrList){
		userId=this.getMsgRecordListKey(userId);
		DataMap.msgRecordList[userId]=arrList;
		DBUtils.setMsgRecordList(userId,arrList);
	},
	putMsgRecordList:function(userId,msgId,inTop){
		userId=this.getMsgRecordListKey(userId);
		var arrList=DataUtils.getMsgRecordList(userId,1);
		var index=arrList.indexOf(msgId);
		if(index>-1)
			return;
		/*本地记录 最多只保存最新50条*/
		if(1==inTop){
			if(50>arrList.length){
				arrList.unshift(msgId);
				DataMap.msgRecordList[userId]=arrList;
				DBUtils.setMsgRecordList(userId,arrList);
			}
		}else{
			if(50>arrList.length){
				arrList.push(msgId);
			}else{
				arrList.splice(0, 1);
				arrList.push(msgId);
			}
			DataMap.msgRecordList[userId]=arrList;
			DBUtils.setMsgRecordList(userId,arrList);
		}
		
	},
	removeMsgRecordList:function(userId,msgId){
		userId=this.getMsgRecordListKey(userId);
		var arrList=DataMap.msgRecordList[userId];
		Utils.removeArrValue(userId,msgId);
		DataMap.msgRecordList[userId]=arrList;
		DBUtils.setMsgRecordList(userId,arrList);
	},
	/*清除 好友 或群组的 消息记录*/
	clearMsgRecordList:function(userId){
		userId=this.getMsgRecordListKey(userId);
		delete DataMap.msgRecordList[userId];
		DBUtils.clearMsgRecordList(userId);
	},
	//删除解散群组 或 删除好友 
	deleteFriend:function(jid){
		this.clearMsgRecordList(jid);
		this.removeUIMessageList(jid);
		DataMap.deleteFriends[jid]=jid;
	},
	getDeleteFirend:function(jid){
		return DataMap.deleteFriends[jid];
	},


	/*获取未读消息 总数*/
	getMsgNumCount:function(){
		var num=msgNumCount;
		if(myFn.isNil(num)||0==num){
			num=DBUtils.getMsgNumCount();
			msgNumCount=num;
		}
		return num;
	},
	/*更新消息总数*/
	setMsgMumCount:function(num){
		
		msgNumCount=num;
		DBUtils.setMsgMumCount(num);
		
	},
	getMsgNum:function(id){
		
		var num=DataMap.msgNum[id];
		if(myFn.isNil(num)){
			num=DBUtils.getMsgNum(id);
			DataMap.msgNum[id]=num;
		}
		return num;
	},
	setMsgNum:function(id,num){
		/*
		var num=DataMap.msgNum[id];

		if(myFn.isNil(num)){
			num=DBUtils.getItem(key);
			DataMap.msgNum[id]=num;
		}*/
		DataMap.msgNum[id]=num;
		DBUtils.setMsgNum(id,num);
		
	},
	/*同步服务器 最近聊天列表*/
	getLastChatList:function(callback){
		var startTime=myFn.isNil(DataUtils.getUIMessageList())?0:DataUtils.getLogoutTime();

		mySdk.getLastChatList(startTime,function(result){
			var msgObj=null;
			var name=null;
			/*if(myFn.isNil(result))
				callback();*/
			var jidList=[];
			var message=null;
			for (var i = 0; i < result.length; i++) {
				message=result[i];
				msgObj=DataUtils.getLastMsg(message.jid);
				/*
				本地最后一条聊天记录与服务器 记录不符
				*/
				/*if(message.messageId!=msgObj.messageId){
					DataUtils.clearMsgRecordList(msgObj.id);
				}*/
				msgObj.messageId=message.messageId;
				msgObj.type=message.type;

				msgObj.content=WEBIM.decryptMessage(message);
				if(1==message.isRoom){
					var myRoom=DataMap.myRooms[msgObj.id];
					if(!myRoom)
						continue;
					var roomId=myRoom.id;
					 room=DataMap.rooms[roomId];
					 name=room.name;
					 var lastTime=0<msgObj.timeSend?msgObj.timeSend:DataUtils.getLogoutTime();
					 jidList.push(message.jid+","+lastTime);
				}else{
					var friend=DataMap.friends[msgObj.id];
					if(myFn.isNil(friend))
						continue;
					name=myFn.isNil(friend.remarkName)?friend.toNickname:friend.remarkName;
				}
				msgObj.lastTime=message.timeSend;
				msgObj.timeSend=message.timeSend;

				msgObj.name=name;
				DBUtils.putUIMessageList(msgObj);
				//DBUtils.removeMsgRecordList(msgObj.id);
			}
			if(0<jidList.length){
				WEBIM.pullBatchGroupMessage(jidList);
			}
			
			callback();
		});
	},
	/*获取最近的消息列表记录*/
	getUIMessageList:function(){
		var messageList=DBUtils.getUIMessageList();
		return messageList;
	},
	putUIMessageList:function(msg,fromUserId,fromUserName){
		//var messageList=DBUtils.getUIMessageList();
		
		var obj=DataUtils.getLastMsg(fromUserId);
		if(fromUserId)
			obj.id=fromUserId;
		else
			obj.id=msg.fromUserId;
		if(fromUserName)
			obj.name=fromUserName;
		else
			obj.name=msg.fromUserName;
		if(msg.timeSend>obj.timeSend)
			obj.timeSend=msg.timeSend;
		obj.lastTime=0;
		obj.content=msg.content;
		obj.type=msg.type;
		obj.isReadDel=msg.isReadDel;
		DBUtils.putUIMessageList(obj);
	},
	putUIMessageObj:function(msgObj){
		DBUtils.putUIMessageList(msgObj);
	},
	removeUIMessageList:function(userId){
		DBUtils.removeUIMessageList(userId);
		
	},
	getLastMsg:function(userId){
		var msg=DBUtils.getLastMsg(userId);
		if(myFn.isNil(msg)){
			msg={};
			msg.id=userId;
			msg.timeSend=0;
		}else{
			msg.timeSend=Number(msg.timeSend);
		}
		return msg;
	},
	getMessage:function(messageId){
		var msg=DataMap.msgMap[messageId];
		if(myFn.isNil(msg)){
			msg=DBUtils.getMessage(messageId);
			DataMap.msgMap[messageId]=msg;
		}
		return msg;
	},
	saveMessage:function(msg,msgId){
		if(msgId){
			msg.messageId=msgId;
		}else if(myFn.isNil(msg.messageId))
			msg.messageId=msg.id;
		if(!msg.messageId)
			return;
		DataMap.msgMap[msg.messageId]=msg;
		DBUtils.saveMessage(msg);
	},
	deleteMessage:function(messageId){
		delete DataMap.msgMap[messageId];
		DBUtils.deleteMessage(messageId);
	},

	getMsgReadList:function(messageId){
		var readList=groupMsgReadList[messageId];
		if(myFn.isNil(readList)){
			readList=DBUtils.getMsgReadList(messageId);
			groupMsgReadList[messageId]=readList;
		}
		return readList;
	},
	/*添加已读列表 消息对象*/
	putMsgReadList:function(messageId,msg){
		
		var readList=groupMsgReadList[messageId];
		if(myFn.isNil(readList)){
			readList=DBUtils.getMsgReadList(messageId);
		}
		readList.push(msg);
		groupMsgReadList[messageId]=readList;
		DBUtils.putMsgReadList(messageId,msg);

	},
	/*获取消息已读数量*/
	getMsgReadNum:function (messageId) {
		var value= groupMsgReadNum[messageId];
		if(myFn.isNil(value)){
			value=DBUtils.getMsgReadNum(messageId);
			groupMsgReadNum[messageId]=value;
		}
		return value;
	},
	//更新消息已读数量
	setMsgReadNum:function (messageId,num) {
		//设置已读数量
		groupMsgReadNum[messageId]=num;

		DBUtils.setMsgReadNum(messageId,num);

	},

	/*获取消息过滤状态*/
	getMsgFilters:function(id){
		var status=GroupManager.filters[id];
		if(myFn.isNil(status)){
			status=DBUtils.getMsgFilters(id);
			GroupManager.filters[id]=status;
		}status="0"==status?false:true;
		return status;
	
	},
	setMsgFilters:function(id,status){
		status=false==status?0:1;
		GroupManager.filters[id]=status;
		DBUtils.setMsgFilters(id,status);
	},
	/*
	好友阅后即焚状态
	*/
	getFriendReadDelStatus:function(userId){
		return DBUtils.getFriendReadDelStatus(userId);
	},
	setFriendReadDelStatus:function(userId,status){
		DBUtils.setFriendReadDelStatus(userId,status);
	},
	clearAll:function(){
		DBUtils.clearAll();
		ownAlert(3,"清除本地数据成功!");
	}
		
}




var ConversationManager = {
	isOpen : false,// 聊天窗口是否打开
	from : null,// 目标用户
    nickName : null,// 目标用户昵称
	fromUserId:null,
	resource:null,//目标用户的 设备标识
	talkTime:0,//禁言时间
	msgsList : {},
	roomData : null,
	user:null,
	friend:null,
	notice:null,// 消息通知标识
	chatType:0,//2是群聊 1 是单聊
	curViewUnreadNum:0, //当前界面的消息未读数量
	isShowNewMsgCut:true,//是否显示新消息分割线,初始为需要显示
	isShowUnreadCount:true,//是否需要显示新消息未读统计，初始需要显示
	
	/** 打开会话*/
	open : function(from, name,groupId) {

		this.nickName = name;
		document.getElementById("tabCon_2").style.display="none";//将所有的层都隐藏

		document.getElementById("tabCon_1").style.display="none";//将所有的层都隐藏 
		document.getElementById("tabCon_0").style.display="block";//显示当前层
		document.getElementById("tabCon_new").style.display="none";
		$(".chat_content_avatar").tooltip({
		   		trigger:'hover',
		   		html:true,
		   		title:'个人资料',
		   		placement:'bottom'
		   })
	
		//判断目标会话界面是否已经打开
		if (this.from!=10000 && ConversationManager.isOpen && this.from==from && this.fromUserId==WEBIM.getUserIdFromJid(from)){
			//ownAlert(3,"目标会话界面已经打开，请勿重复操作");
			return;
		}
	 
		$("#messageContainer   #bottomUnreadCount").remove();
		$("#messageContainer .message_system").remove();

		$("#userModal").modal('hide');
		$("#addfriend").modal('hide');
		ConversationManager.roomData = null;
		ConversationManager.isOpen = true;
		ConversationManager.from = from;
		ConversationManager.fromUserId = WEBIM.getUserIdFromJid(from);
		ConversationManager.resource = WEBIM.getResource(from);
		var chatType = WEBIM.isGroup(ConversationManager.fromUserId)?WEBIM.GROUPCHAT:WEBIM.CHAT;
		ConversationManager.chatType=chatType;

		var userIdKey=ConversationManager.fromUserId;
		if(myData.userId==userIdKey&&name!=myData.nickname){
			var resource=WEBIM.getResource(from);
			if(!myFn.isNil(resource))
				userIdKey=userIdKey+"_"+resource;
			DeviceManager.showDeviceOnlineStatus(resource);
			//清除未读消息数量提示
			UI.clearMsgNum(userIdKey,from);
		}else{
			//清除未读消息数量提示
			UI.clearMsgNum(userIdKey,from);
		}
		

		//初始化当前界面的新消息未读数据
		ConversationManager.curViewUnreadNum=0;
		ConversationManager.isShowNewMsgCut=true;
		ConversationManager.isShowUnreadCount=true;
		
		DataMap.timeSendLogMap[ConversationManager.fromUserId]=0;	
		Temp.minTimeSend=0;
		/*var msgObj=DataUtils.getLastMsg(ConversationManager.fromUserId);
		if(!myFn.isNil(msgObj)){
			if(0<msgObj.lastTime&&(msgObj.lastTime>msgObj.timeSend)){
				DataUtils.clearMsgRecordList(ConversationManager.fromUserId);
				msgObj.lastTime=0;
				DataUtils.putUIMessageObj(msgObj);
			}
		}*/
		if (WEBIM.isChatType(chatType)){  //单聊
			$("#Snapchat").show();
			UI.showDetails(from,chatType,name);
			
		} else {
			$("#Snapchat").hide();
			UI.showDetails(from,chatType,name); //显示详情数据
		}

		//检查用户是否被踢出该群，若被踢出则将详情界面隐藏
		if (!myFn.isNil(DataMap.deleteRooms[ConversationManager.fromUserId])) { 
			$("#tab #details").hide();
			changeTab(0,"msgTab"); //默认选中消息面板
		}else{
			$("#tab #details").show();
			changeTab(0,"msgTab");
		}

		var arrList=DataUtils.getMsgRecordList(ConversationManager.from);
		
		//判断是否存在本地未读消息
		if(!myFn.isNil(arrList) ){ 
			for (var i = 0; i < arrList.length; i++) {
				if(myFn.isNil(arrList[i]))
					continue;
				var msg = DataUtils.getMessage(arrList[i]);
				if(myFn.isNil(msg))
					continue;
				var itemHtml = null;
				if(this.fromUserId==myData.userId&&1==myData.multipleDevices){
					if(msg.fromUserId!=msg.toUserId)
						return;
					itemHtml=DeviceManager.showHistoryToHtml(msg);
				}else{
					itemHtml= UI.createItem(msg, msg.fromUserId,
					myData.userId!=msg.fromUserId?0:1);
				}
				if(myFn.isNil(itemHtml))   
					continue;

				//记录 当前会话 聊天记录最小时间  拉取漫游使用
				DataUtils.refreshUIMinTimeSend(msg.timeSend);

				$("#messageContainer").append(itemHtml);
				if(WEBIM.isChatType(msg.chatType)&&1!=msg.isRead&&myData.userId==msg.toUserId){//单聊
					if(!myFn.isReadDelMsg(msg))
						ConversationManager.sendReadReceipt(from,msg.messageId);
					else if(1!=msg.type&&2!=msg.type&&3!==msg.type&&6!==msg.type)
						ConversationManager.sendReadReceipt(from,msg.messageId); //发送已读回执
						
				}else if(WEBIM.isGroupType(msg.chatType)&&1!=msg.isRead){ //群聊
					//发送已读回执到群内
					if(myData.userId!=msg.fromUserId&&100>msg.type){
						//判断是否开启了显示群组消息已读人数  若为@消息强制发送
						//||!myFn.isNil(msg.objectId)
						if(myData.isShowGroupMsgReadNum){ 
							GroupManager.sendRead(msg.messageId); //调用方法发送已读回执
						}
					}
				}
			}
			mySdk.showLoadHistoryIcon(1); //加载消息历史结束后，显示消息历史的相关Icon	
			setTimeout(function(){ //将滚动条移动到最下方
				$("#messagePanel").nanoScroller();//刷新滚动条
				UI.scrollToEnd(); //滚动到底部
			},400);
			
			// alert(myData.isReadDel)
			// UI.switchToggle("switchReadDel",myData.isReadDel);
		}else{
			//加载历史消息
			ConversationManager.pullHistoryMessage();
		}
		
	},
	//校验用户在当前群组的角色
     checkGroupOwnerRole : function(roomId,userId){
		var flag = false;
        myFn.invoke({
            url : '/room/member/get',
            data : {
                roomId : roomId,
                userId : userId
            },
            success : function(result) {
                if (1 == result.resultCode) {
                	var obj = result.data;
					if(obj.userId == userId){
						if(obj.role<3){
							flag=true;
						}
					}
                }
            },
            error : function(result) {
            }
        });
        console.log("flag:"+flag);
        return flag;
	},
	showAvatar : function(userId,isGroup,deviceKey){ //显示聊天窗口顶部头像和昵称
		$("#chatAvator").empty();
		$("#desphoto").empty();
		$("#friend_img_div").empty();
		$("#gphoto").empty();
		var imgUrl=10000!=userId?myFn.getAvatarUrl(userId):"img/im_10000.png";
		if(deviceKey)
			imgUrl=DeviceManager.getDeviceImg(deviceKey);
				
		var avatarHtml ;
		if(isGroup==0){//单聊
			var html_img="<img onerror='this.src=\"img/ic_avatar.png\"' src='"+imgUrl+"' style='width:100px;border-radius: 90%'>";
			avatarHtml="<div class='imgAvatar'>"
			           +	"<figure style='height:40px;width:40px;'>"
		               +	  "<img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl+ "' class='chat_content_avatar' onclick='msgMabayUser()'>"
		               +	"</figure>"
		               +"</div>";
		    $("#chatAvator").empty();
		    $("#desphoto").empty();
		    $("#gphoto").empty();
		    $("#chatAvator").append(avatarHtml);
			$("#desphoto").append(avatarHtml);
			$("#gphoto").append(avatarHtml);
			$("#"+userId+"").hide();
			$("#friend_img_div").empty();
		    $("#friend_img_div").append(html_img);
		}else { //群聊
			avatarHtml="<div class='imgAvatar'>"
			           +	"<figure style='height:40px;width:40px;'>"
		               +	  "<img src='./img/group_avatar.png' class='chat_content_avatar'>"
		               +	"</figure>"
		               +"</div>";
		    $("#chatAvator").empty();
		    $("#desphoto").empty();
		    $("#gphoto").empty();
		    $("#chatAvator").append(avatarHtml);
			$("#desphoto").append(avatarHtml);
			$("#gphoto").append(avatarHtml);
			$("#"+userId+"").hide();
		}
		
	},
	pullHistoryMessage : function() {
		endTime =Temp.minTimeSend;
		var jid=ConversationManager.from;
		WEBIM.pullHistoryMessage(ConversationManager.chatType,jid,20,0,Number(endTime));
	},
	handlerHistoryMessageResult:function(result){
		if(ConversationManager.from!=result.jid)
			return;
		var arrList=DataUtils.getMsgRecordList(ConversationManager.from);
		/*是否为第一页*/
		let isFastPage=(0==arrList.length);

		var pageMsgHtml="";
		var itemHtml="";
		var msgList = result.messageList;
		if(myFn.isNil(msgList))
			return;
		for (let i =0; i<msgList.length; i++) {
			let message = msgList[i];
			let msg=DataUtils.getMessage(message.messageId);
			if(myFn.isNil(msg)){
				DataUtils.saveMessage(message);
				if(isFastPage){
					DataUtils.putMsgRecordList(ConversationManager.from,message.messageId,i==0?1:0);
				}else{
					DataUtils.putMsgRecordList(ConversationManager.from,message.messageId,1);
				}
				
			}
			DataUtils.refreshUIMinTimeSend(message.timeSend);
			itemHtml=ConversationManager.showHistoryToHtml(message,1);
			if(!myFn.isNil(itemHtml))
					pageMsgHtml+=itemHtml;
		}

		
		
		//为滚动条添加锚点
		 pageMsgHtml += "<div id='msgAnchor'></div>";   
		 $("#messageContainer").prepend(pageMsgHtml);
		
		 //一页(10条)的消息记录
		if(msgList.length<20){
			//调用方法显示消息记录翻页相关状态 3:没有更多记录了
			mySdk.showLoadHistoryIcon(3); 
		}else{
			mySdk.showLoadHistoryIcon(1);
		}
		
		//让滚动条移动翻页之前的消息位置
		// $("#messagePanel").scrollTo('#messageContainer #msgAnchor',1);
		$(".nano").nanoScroller({ scrollTo: $('#messageContainer #msgAnchor') });
		
		//清除此次翻页的锚点
		$("#messageContainer #msgAnchor").remove();
	},
	/*isTop  是否加载历史记录  需要 添加到顶部
	返回 内容*/
	showHistoryToHtml :function(msg,isTop){ //显示历史消息记录
		/*if(100<msg.type)
			return null;*/
		var itemHtml = $("#messageContainer #msg_"+msg.messageId).prop("outerHTML");
		if(!myFn.isNil(itemHtml))
			return null;
		else itemHtml="";
		if (!WEBIM.isGroupChat(ConversationManager.chatType)) {
			if(this.fromUserId==myData.userId&&1==myData.multipleDevices){
				if(msg.fromUserId!=msg.toUserId)
					return;
				itemHtml=DeviceManager.showHistoryToHtml(msg);
			}else{
				if (myData.userId==msg.fromUserId) {
					msg.fromUserName=myData.nickname;
					itemHtml += UI.createItem(msg, msg.fromUserId, 1);
				} else {
					itemHtml += UI.createItem(msg, msg.fromUserId, 0);
				}
			}
			
		} else {
			if (myData.userId == msg.fromUserId) {
				//群组
				//发送者是自己
				msg.fromUserName = myFn.isNil(GroupManager.roomCard)? msg.fromUserName : GroupManager.roomCard;

				itemHtml += UI.createItem(msg, msg.fromUserId, 1);
			} else {
				itemHtml += UI.createItem(msg, msg.fromUserId, 0);
			}
		}

		if(myFn.isNil(itemHtml))
			return null;
		if(isTop)
			return itemHtml;
		else
			$("#messageContainer").append(itemHtml);
			
			//检查记录中是否存在未读消息
			/*if(!WEBIM.isGroupChat(ConversationManager.chatType)&&(true!=msg.isRead ||1!=msg.isRead)){
				ConversationManager.sendReadReceipt(ConversationManager.from,o.messageId); //发送已读回执
				
			}*/
			setTimeout(function(){
				UI.scrollToEnd();
			},500);
		
	},
	
	loadMsgHistory : function(endTime){ //加载聊天的历史记录
		mySdk.showLoadHistoryIcon(2);
 		var chatType=ConversationManager.chatType;
 		ConversationManager.pullHistoryMessage();
	},

	//格式化消息通知
	parseNotification:function(msg,fromUserId,fromUserName){
		if (MessageType.Type.READ==msg.type)
			return;
		
		var url=myFn.getAvatarUrl(fromUserId);
		var content=WEBIM.parseShowMsgTitle(msg);
		//单聊
		if(WEBIM.CHAT==msg.chatType){
			if(myFn.isNil(fromUserName)||myFn.isNil(content)){
				shikuLog("===> Notification params is null ");
				return;
			}
			UI.showNotification(url,fromUserName,content);
			return;
		//群聊
		}else if(WEBIM.GROUPCHAT==msg.chatType){

		url="img/logo.png";
		var roomId=(!myFn.isNil(DataMap.myRooms[fromUserId]))?DataMap.myRooms[fromUserId].id:"";
		var room=DataMap.rooms[roomId];
		if(!myFn.isNil(room))
			UI.showNotification(url,room.name,content);		
		}


	},
	//接受的消息显示到页面
	receiverShowMsg:function(msg){
		
		//已经接受到的消息 返回
		if (!myFn.isNil(DataMap.msgIds[msg.messageId])) {
			return;
		}
		 var isFilter=false;
		var from=msg.from;
		var fromUserId=msg.fromUserId;
		if(WEBIM.GROUPCHAT==msg.chatType){

			fromUserId =msg.from;
			isFilter=DataUtils.getMsgFilters(from);
		}else if(myData.userId==fromUserId){
			if(202==msg.type){
				if(myFn.isNil(msg.toUserId)){
					var message=DataUtils.getMessage(msg.msgId);
					if(myFn.isNil(message))
						return;
					msg.toUserId=message.toUserId;
				}
			}
			if(myData.userId!=msg.toUserId){
				//自己其他设备发送给好友的消息 转发给我的
				from=msg.toUserId;
			}else
				from=msg.fromJid;
		}
		var fromUserName=msg.fromUserName;//发送方的用户昵称
		
		

		var fromJid=ConversationManager.from;
				
		//聊天界面没有打开//判断聊天面板是否打开
		var isOpen=ConversationManager.isOpen;
		//发送者不是 当前页面好友 或群组jid.
		if(WEBIM.getBareJid(fromJid)!=WEBIM.getBareJid(from))
			isOpen=false;
		else if(WEBIM.getBareJid(from)==myData.userId){
			if(fromJid!=from)
				isOpen=false;
		}

		// 正在输入状态 终止执行
		if(MessageType.Type.READ==msg.type){
			var tempMsg=DataUtils.getMessage(msg.content);
			if(!myFn.isNil(tempMsg)){
				tempMsg.isRead=1;
				DataUtils.saveMessage(tempMsg);
				if(!isOpen)
					return;
			}else if(!isOpen&&myFn.isReadDelMsg(tempMsg)){
				DataUtils.deleteMessage(msg.content);
				return;
			}
		}

		//判断是否同账号发送过来的消息
		if(1==myData.multipleDevices&&WEBIM.isChatType(msg.chatType)&&
			myData.userId==msg.fromUserId){
			//多设备的消息处理
		
			msg=DeviceManager.processShowMessage(msg,0,isOpen);
			if(myFn.isNil(msg))
				return;
			/*if(myData.userId!=msg.toUserId)
				fromUserId=msg.toUserId;*/
		}
		//聊天界面已打开 显示消息
		if(isOpen){
			$("#state").html("(在线)");
			UI.showMsg(msg, fromUserId,myData.userId!=msg.fromUserId?0:1,myData.userId!=msg.fromUserId?1:0,"newMsg");
		}
		if(msg.type>100&&202!=msg.type)
			return;
		
		if (WEBIM.isGroupType(msg.chatType)) {//已读回执
			if(myData.userId!=msg.fromUserId&&MessageType.Type.READ==msg.type){
				//群聊的已读消息 改变已读人数
				GroupManager.disposeReadReceipt(msg); 
				//调用方法处理已读回执 ,这里的fromUserId为群组jid
			}
		}
		if(MessageType.Type.INPUT==msg.type||
			MessageType.Type.READ==msg.type){
			return;
		}
		if(isOpen){
			if(WEBIM.isChatType(msg.chatType)&&myData.userId!=msg.fromUserId){//单聊
				if(!myFn.isReadDelMsg(msg))
					ConversationManager.sendReadReceipt(WEBIM.getUserIdFromJid(from), msg.messageId);
				else if(1!=msg.type&&2!=msg.type&&3!==msg.type&&6!==msg.type)
					ConversationManager.sendReadReceipt(WEBIM.getUserIdFromJid(from), msg.messageId); //发送已读回执
			}else if(WEBIM.isGroupType(msg.chatType)){ //群聊
				//发送已读回执到群内
				if(myData.userId!=msg.fromUserId){
					if(myData.isShowGroupMsgReadNum||!myFn.isNil(msg.objectId)){ 
						GroupManager.sendRead(msg.messageId); //调用方法发送已读回执
					}

				}
				
			}
		}else{
			if(false==isFilter){
				//显示通知
				ConversationManager.parseNotification(msg,fromUserId,msg.fromUserName);
			}
			
		}

		if(WEBIM.isChatType(msg.chatType)){
			//接受到消息好友移动到新朋友的下方  //显示未读消息数量提示
			// $("#myFriendsList #friends_"+fromUserId).insertAfter("#friends_10001");
			msg.isGroup=0;	
			if(myData.userId==fromUserId){
				fromUserId=msg.toUserId;
				msg.fromJid=msg.toUserId;
				fromUserName=null;
			}
			UI.moveFriendToTop(msg,fromUserId,fromUserName,isOpen?0:1);
			UI.playSound();
		}else if(WEBIM.isGroupType(msg.chatType)){
			msg.isGroup=1;
			if(true==isFilter)
				UI.moveFriendToTop(msg,msg.from,fromUserName,isOpen?0:0);
			else{
				UI.moveFriendToTop(msg,msg.from,fromUserName,isOpen?0:1);
				UI.playSound();
			}
			$("#myRoomList #groups_"+fromUserId).prependTo($("#myRoomList"));
		}
	},
	//处理收到的单条消息
	processMsg:function(message){
		switch (message.type){
			case 96:
				/*清除双方聊天记录*/
				UI.clearMsgNum(message.fromUserId);
				DataUtils.removeUIMessageList(message.fromUserId);
				DataUtils.clearMsgRecordList(message.fromUserId);
				UI.removeFriendMessagesList(message.fromUserId);

			 	/*打开了与对方当前聊天界面*/
				if(WEBIM.getUserIdFromJid(ConversationManager.from)==message.fromUserId){
				 	UI.cleanUIMessage();
				 	UI.showMsgLog("</br>对方清除了双方的聊天记录");
			 	}
			 	return;
	        	break;
			
			case 801:
				break;
			


	       	default:

	            break;
		}
		//消息去重
		if(DataUtils.getMessage(message.messageId))
			return;	

		var chatType = message.chatType;
		var from = message.from;
		var toJid = message.to;
		var resource=WEBIM.getResource(from);
		var fromUserId = WEBIM.getUserIdFromJid(from);
		 DataUtils.saveMessage(message);
		//收到的是当前设备发送的消息
		if(WEBIM.resource==resource&&myData.userId==fromUserId)
			return;
		
		//判断消息是否来自于黑名单用户，是则不接收
		if(!myFn.isNil(DataMap.blackListUIds[fromUserId])){
			return;
		}

		if(chatType ==WEBIM.CHAT){//单聊 
			// 收到消息立即发送回执给发送者
		  var delay=message.offline;//有这个字段就代表是离线消息
		  if(message.offline){
		  	
		  } 
		    	
		}
		let msg=message;
		//消息的发送者userID  群组的Jid
		msg.fromId=fromUserId;
		//消息来源的JID  其他地方要用
		msg.fromJid=from;
		msg.toJid=toJid;


		//多设备模块的  消息处理
		if(1==myData.multipleDevices){
			//// 好友消息处理
			if(WEBIM.CHAT==chatType&&fromUserId!=myData.userId){
				DeviceManager.receiverMessage(message);
			}else if(WEBIM.CHAT==chatType&&fromUserId==myData.userId){
				//其他 设备消息处理
				if(DeviceManager.receiverDeviceMessage(message))
					return;
			}
			
		}
		
		//处理客服模块的xmpp消息    320 : 建立对话   321: 结束会话
		if (msg.type==320 || msg.type=="320") {
			CustomerService.sendSayHello(parseInt(msg.fromUserId));
			return;
		};
			
		//过滤消息类型  接受到true 就 返回不继续执行
		if(ConversationManager.filterMsgType(msg,fromUserId))
			return;
		//发送者设备标识

		//var resource=WEBIM.getResource(from);

		if(WEBIM.CHAT==chatType&&myData.userId==msg.fromUserId){
			//自己发送的消息  fromUserName 改为null
			//显示的时候 会根据 fromUserId 取得 用户名
			msg.fromUserName=null;
		}
		if(msg.isEncrypt)
			msg.content = WEBIM.decryptMessage(msg);
		DataUtils.saveMessage(msg);
		ConversationManager.receiverShowMsg(msg);


	},
	processReceived:function(id){
		shikuLog("收到送达回执 ："+id);
		/*处理收到的消息回执*/
		if(!myFn.isNil(myData.user) && 1==myData.user.settings.openService){
			CustomerService.checkHelloTextReceipt(id); //客服模块，检查打招呼语的回执
		}
		DataMap.msgStatus[id] = 1; //将发送消息状态进行储存 1:送达
		//将对应消息的状态显示为送达
		
		if(WEBIM.isGroupChat(ConversationManager.chatType)){ //群聊
			
			$("#groupMsgLoad_"+id+"").remove();  //移除loading 标志

			if(myData.isShowGroupMsgReadNum ) {//开启群消息已读才显示  若为@消息强制显示
				//if(!myFn.isNil(message.objectId))
				$("#groupMsgStu_"+id+"").text("0人").show();
				//GroupManager.changeReadNum(id); //改变数量
			}  

		}else{ //单聊 
			$("#msgLoad_"+id+"").remove();
			if(myFn.isReadDelMsg(DataUtils.getMessage(id))){ //阅后即焚消息
				$("#msgStu_"+id+"").before("<img class='msg_status_readDel ico_readDel' src='./img/fire.png'>");
				$("#msgStu_"+id+"").removeClass("msg_status_common").addClass("msg_status_readDel  ok_bg");
				$("#msgStu_"+id+"").text("送达").show();
			}else{
				$("#msgStu_"+id+"").addClass("ok_bg"); //改变背景
				$("#msgStu_"+id+"").text("送达").show();
			}
			

		}

		/*if(1==myData.multipleDevices){
			//多设备模块的  回执处理
			if(DeviceManager.receiveReceived(message))
				return true;
		}*/
		return true;
	},
	/*收到群控制消息*/
	handlerGroupGontrolMessage:function(msg){
		if(DataUtils.getMessage(msg.messageId))
			return;
		UI.playSound();
		//调整控制信息  401 群文件上传  402 群文件删除
		msg=WEBIM.converGroupMsg(msg);
		if(!msg)
			return;
		msg.isGroup=1;
		msg.roomJid=msg.objectId;
		if(!myFn.isNil(DataUtils.getDeleteFirend(msg.roomJid))&&907!=msg.contentType){
			/*已退出或删除 解散 这个群组*/
			return true;
		}
		if(916!=msg.contentType){
			UI.moveFriendToTop(msg,msg.objectId,msg.fromUserName,
			(ConversationManager.isOpen&&msg.objectId==ConversationManager.fromUserId)?0:1,1);
		}else{
			if(myFn.isNil(msg.text)){
		  		//邀请好友
		  		var inviteObj=eval("(" +msg.objectId+ ")");
		  		msg.roomJid=inviteObj.roomJid;
		  		UI.moveFriendToTop(msg,msg.roomJid,msg.fromUserName,
				(ConversationManager.isOpen&&msg.roomJid==ConversationManager.fromUserId)?0:1,1);
		  	}else{
		  		UI.moveFriendToTop(msg,msg.objectId,msg.fromUserName,
				(ConversationManager.isOpen&&msg.objectId==ConversationManager.fromUserId)?0:1,1);
		  	}
		}
		DataUtils.saveMessage(msg);
		GroupManager.processGroupControlMsg(msg);
		if(ConversationManager.isOpen&&msg.roomJid==ConversationManager.fromUserId){
			UI.showMsg(msg,msg.roomJid,0);
		}
	},
	/*收到已读消息回执*/
	handlerReadReceipt:function(msg){
		if(WEBIM.CHAT==msg.chatType){
			var message=DataUtils.getMessage(msg.content);
			if(myFn.isNil(message))
				return ;
			message.isRead=1;
			if(myFn.isReadDelMsg(message)){
				DataUtils.removeMsgRecordList(msg.fromJid,msg.content);
				
			}else{
				DataUtils.saveMessage(message,msg.content);
			}
		}
		ConversationManager.receiverShowMsg(msg);
	},
	/*音视频通话相关消息*/
	handlerAudioOrVideoMessage:function(msg){
		//音视频通话相关消息
		//SIPWin.processMsg(msg);
		if(WEBIM.isGroupChat(msg.chatType)&&myData.userId==msg.fromUserId){
			return;
		}else if(WEBIM.isChatType(msg.chatType)&&myData.userId==WEBIM.getUserIdFromJid(msg.from)){
			msg.contentType=msg.type;
			Call.receiverMyDeviceMsg(msg);
			return true;
		}else if(WEBIM.isChatType(msg.chatType)&&1==myData.multipleDevices&&myData.userId!=msg.fromUserId){
				DeviceManager.receiverMessage(msg);
		}
		Call.processMsg(msg);
	},
	/*新朋友消息*/
	handlerNewFriendMessage:function(msg){
		//好友验证 消息
		UI.showMsgNum(10001,1);
		UI.msgWithFriend(msg);
	},
	/*撤回消息*/
	handlerRevokeMessage:function(msg){
		DataUtils.deleteMessage(msg.content);
		DataUtils.removeMsgRecordList(msg.content)
		DataUtils.saveMessage(msg);
		/*if(WEBIM.GROUPCHAT==msg.chatType&&myData.userId==msg.fromUserId)*/
		ConversationManager.receiverShowMsg(msg);
	},
	 /*处理 批量群组的 离线消息数量*/
	handlerGroupMessageResult:function(result){
		for (var i = 0; i <result.messageList.length; i++) {
    		message=result.messageList[i];
    		//DataUtils.putUIMessageList(message,message.from,message.fromUserName);
    		
    		message.content = WEBIM.decryptMessage(message);

			DataUtils.putMsgRecordList(message.from,message.messageId);
			DataUtils.saveMessage(message);
    	}
    	UI.showMsgNum(result.jid,1,Number(result.count));
    	UI.updateMessageListTimeSendStr();
			
	},
	handlerLoginConflict:function(){
		WEBIM.disconnect();
		window.location.href = "login.html?loginConflict=loginConflict";
	},
	//发送已读回执
	sendReadReceipt : function(from,messageId,isSendMyDevice) {
		//isSendMyDevice 发送给我的其他设备
		var dbMsg=DataUtils.getMessage(messageId);

		var msg=WEBIM.sendMessageReadReceipt(from,messageId);
		var msgObj=msg;
		//设置发送消息重发次数
		msg.reSendCount=3;
		DataUtils.saveMessage(msg);
		shikuLog("发送已读回执："+msgObj.messageId+"       类型:"+type);
		if(1==isSendMyDevice&&1==myData.multipleDevices){
			DeviceManager.sendMsgToMyDevices(msgObj);
		}
		//阅后即焚消息  删除
		if(dbMsg){
			dbMsg.isRead=1;
			DataUtils.saveMessage(dbMsg);
		}

	},
	filterMsgType:function(msg,fromUserId){
		//过滤消息类型 如果被过滤了 就返回 true 则不继续执行
		
		if(83==msg.type){
			msg=WEBIM.converGroupMsg(msg);
			DataUtils.saveMessage(msg);
			if(!myFn.isNil(msg.objectId)){
				//群聊红包
				msg.isGroup=1;
				UI.moveFriendToTop(msg,msg.objectId,msg.fromUserName,
					(ConversationManager.isOpen&&msg.objectId==ConversationManager.fromUserId)?0:1,1);
			}else{
				UI.moveFriendToTop(msg,msg.fromUserId,msg.fromUserName,
					(ConversationManager.isOpen&&msg.fromUserId==ConversationManager.fromUserId)?0:1,1);
			}
			UI.showMsg(msg,fromUserId,0);
			return true;
		} 
		return false;

	},
	showLog :function(msg){//日志
		if(msg.fromUserId==ConversationManager.fromUserId){
			var logHtml ="<div class='logContent ' >"
						+"	<span style='color:#3c3b3b'>"+msg.content+"</span> "
						+"</div>";
			$("#messageContainer").append(logHtml);
			UI.scrollToEnd("receive");
		}

	},
	sendMsg : function(msg,callback,toJid) {
		//发送消息开始
		//检查Xmpp 是否在线
		if(WEBIM.isConnect()){
			//检查消息是否需要加密
			ConversationManager.sendMsgAfter(msg,toJid);
			  if(callback)	
					callback();
			
		}else{

			ownAlert(4,"你已掉线是否重新登录？",function(){

					WEBIM.loginIM(function(){
					   UI.online();
						ConversationManager.sendMsgAfter(msg,toJid);

						  if(callback)
						 		callback();
						
					});

			});

		}
	},
	sendMsgAfter:function(msg,toJid){
		//组装xmpp 消息体 继续发送
		var type=msg.type;
		var from = WEBIM.userIdStr;
		// toJid指定的消息接受者
		// Temp.toJid 临时的消息接受者
		// ConversationManager.from  聊天框的消息接受者
		
		/*if(myFn.isNil(toJid))
			toJid=Temp.toJid;*/
		if(myFn.isNil(toJid))
		 	toJid = ConversationManager.from;
		 if(myFn.isNil(msg.toUserId)){
		 	msg.toUserId=WEBIM.getUserIdFromJid(toJid);
		 }
		// 发送消息
		
		var content=msg.content;
		
		msg.to=toJid;
		msg.from=WEBIM.userIdStr;
		//判断是否需要加密消息内容
		msg.content=ConversationManager.checkEncrypt(msg);
		if (WEBIM.isGroup(msg.toUserId)) {
			msg.chatType=WEBIM.GROUPCHAT;
		} else {
			msg.chatType=WEBIM.CHAT;
		}
		var message = msg;
		//发送消息的我的其他设备
		/*if(WEBIM.CHAT==msg.chatType&&myData.userId!=msg.toUserId&&1==myData.multipleDevices){
			DeviceManager.sendMsgToMyDevices(message);
		}*/
		WEBIM.sendMessage(message);
		msg.toJid=toJid;
		
		//设置发送消息重发次数
		if(msg.type<100)
			msg.reSendCount=5;
		else
			msg.reSendCount=0;
		msg.content=content;
		DataUtils.saveMessage(msg);
		DataUtils.putMsgRecordList(toJid,msg.messageId);
		return msg;
	},
	sendTimeout:function(msgId){
		var msg=DataUtils.getMessage(msgId);
		if(myFn.isNil(msg)){
			UI.showReSendImg(msgId);
			shikuLog("sendTimeout  消息找不到了");
			return;
		}
		//检查网络状态
		checkNetAndXmppStatus();
		if(msg.reSendCount>0){
			shikuLog(" 消息自动重发 "+msgId+"  type "+msg.type+" content ==  "+msg.content+"  reSendCount "+msg.reSendCount);
			msg.reSendCount=msg.reSendCount-1;
			DataUtils.saveMessage(msg);
			WEBIM.sendMessage(msg);
		}else{
			shikuLog("showReSendImg "+msgId+"  type "+msg.type+" content ==  "+msg.content+"  reSendCount "+msg.reSendCount);
			UI.showReSendImg(msgId);
		}
	},
	checkEncrypt:function(msg,callback){
		//检测消息加密  如果加密 调用接口加密
		var content=msg.content;
		if(msg.type!=MessageType.Type.FEEDBACK &&WEBIM.encrypt==true){
			return WEBIM.encryptMessage(msg);
		}else{
			return msg.content;
		}
	},
	/*关闭聊天窗口 清除当前聊天界面数据*/
	cleanCurrentData:function(){
		ConversationManager.fromUserId=null;
		ConversationManager.chatType=0;
		ConversationManager.from=null;
		ConversationManager.curViewUnreadNum=0;
		ConversationManager.roomData=null;
	}
	
};

function changeTab(tabCon_num,id){
 	
    for(i=0;i<=2;i++) {
        document.getElementById("tabCon_"+i).style.display="none"; //将所有的层都隐藏
    }
    document.getElementById("tabCon_"+tabCon_num).style.display="block";//显示当前层
    
    //切换图片
	//更改自己的图标
	$("#"+id+"").removeClass("msgMabayChange");
	//将其它兄弟的图标还原
	if("msgTab"==id){//消息面板
		$("#detailsTab").addClass("msgMabayChange");
	}else if("detailsTab"==id){//详情面板
		$("#msgTab").addClass("msgMabayChange");
	}

};

function msgMabayUser(){
	if(10000==ConversationManager.fromUserId)
		return;
	document.getElementById("tabCon_0").style.display="none"; //将所有的层都隐藏
	document.getElementById("tabCon_2").style.display="none"; //将所有的层都隐藏

	document.getElementById("tabCon_1").style.display="block";//显示当前层
}

function msgMabayRoom(){
	document.getElementById("tabCon_0").style.display="none"; //将所有的层都隐藏
	document.getElementById("tabCon_1").style.display="none"; //将所有的层都隐藏
	document.getElementById("tabCon_2").style.display="none";//显示当前层
	document.getElementById("tabCon_2").style.display="block";//显示当前层
	GroupManager.showGroupSetting();
	
}

function creatMsgHistory(type,o,msg){ //生成一条聊天消息的html
		
		var itemHtml = "";
			if (1 == type) {
				if (o.direction == 0) {
					msg.fromUserName=myData.nickname;
					itemHtml += UI.createItem(msg, o.sender, 1);
				} else {
					if(null!=DataMap.friends[o.receiver])
						msg.fromUserName=DataMap.friends[o.receiver].toNickname;
					itemHtml += UI.createItem(msg, o.receiver, 0);
				}
			} else {
				if (myData.userId == o.sender) {
					//群组
					//发送者是自己
					msg.fromUserName=GroupManager.roomCard;
					itemHtml += UI.createItem(msg, o.sender, 1);
				} else {
					itemHtml += UI.createItem(msg, o.sender, 0);
				}
			}
			if(myFn.isNil(itemHtml)){
				return "";
			}
		//检查记录中是否存在未读消息
		if(!WEBIM.isGroupChat(ConversationManager.chatType)&&(true!=msg.isRead ||1!=msg.isRead)){
			if(myData.userId!=msg.fromUserId)
			    ConversationManager.sendReadReceipt(ConversationManager.from, o.messageId); //发送已读回执
			
		}

		return itemHtml;		
}

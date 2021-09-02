/*
	web IM 相关的处理与UI 解耦  
	依赖于 具体 协议相关的 比如 xmpp-sdk 或者 websocket_sdk js
	UI调用 当前类  不直接调用 协议相关类  做得协议类 逻辑 解耦
*/
var WEBIM={
	/*消息ID 前缀 */
	cont:"skimweb_",
	resource:"youjob",
	/*单聊标识*/
	CHAT:1,
	/*群聊标识*/
    GROUPCHAT:2,
	token:null,
	userId:null,
	nickname:null,
	/*用户 jid 10004541/web */
    userIdStr:null,
    /*服务器连接地址 ws://localhost:5260 */
    serverUrl:null,
    server:"server",
    /*消息超时 时间 默认 15 秒*/
    sendTimeOut:15,
    /*等待消息回执的 消息Id 数组*/
    waitReceiptMessageIds:{},
    /*时间差*/
    timeDelay:0,
    encrypt:false,
    isReadDel:false,

    setUserIdAndToken:function(userId,token){
    	WEBIM.userId=userId;
    	WEBIM.token=token;
    },
    /*初始化*/
    initWebIM:function(url,userId,resource,password,pingTime,nickname,server){
        WEBIM.password=password;
        WEBIM.userId=userId+"";
        WEBIM.nickname=nickname;
        WEBIM.serverUrl=url;
        if(server)
        	WEBIM.server=server;
        WEBIM.resource=resource;
        SKIMSDK.initApi(url,userId,resource,password,pingTime,server);
		WEBIM.userIdStr=SKIMSDK.userIdStr;
        SKIMSDK.messageReceiver=WEBIM.handlerMessage;
        SKIMSDK.handlerMsgReceipt=WEBIM.handlerMsgReceipt;
        SKIMSDK.handlerLoginConflict=WEBIM.handlerLoginConflict;

       	console.log(" initWebIM pingTime ===> "+pingTime);
       	SKIMSDK.handlerGroupMessageResult=WEBIM.handlerGroupMessageResult;
        SKIMSDK.handlerHistoryMessageResult=WEBIM.handlerHistoryMessageResult;
    },
    loginIM:function(callback){
    	SKIMSDK.loginIM(function(message){
    		//var resource=WEBIM.getResource(message.from);
    		if(WEBIM.userIdStr==message.from){
            	if(WEBIM.isContains(message.resources,WEBIM.resource)&&callback)
                	callback();
                if(WEBIM.waitPullBatchGroups)
                	WEBIM.pullBatchGroupMessage(WEBIM.waitPullBatchGroups);
			}else{
            	/*其他设备登陆*/
            	WEBIM.updateMyDeviceStatus(message);
        	}
    	});
    },
    disconnect:function(e){
        SKIMSDK.disconnect(e);
    },
    isConnect:function(){
        return SKIMSDK.isConnect();
    },
    updateMyDeviceStatus:function(message){
    	console.log("updateMyDeviceStatus  "+JSON.stringify(message));
    	var resources = message.resources;
    	var from = message.from;
    	var fromResource = WEBIM.getResource(from);
    	if(WEBIM.isContains(resources,fromResource)){
    		DeviceManager.updateDeviceStatus(fromResource,1);
    	}else{
    		DeviceManager.updateDeviceStatus(fromResource,0);
    	}
    	/*var array=resources.split(",");
    	for (resource in array) {
    		if(WEBIM.resource==resource)
    			continue;
    		DeviceManager.updateDeviceStatus(,);
    	}*/
    },
    setEncrypt:function(isEncrypt){
    	WEBIM.encrypt=isEncrypt;
    	
    },
    setIsReadDel:function(isReadDel){
    	WEBIM.isReadDel=isReadDel;
    },
    sendMessage:function(message){
    	SKIMSDK.sendMessage(message);

    	console.log("send  message "+JSON.stringify(message));
    	/*调用等待消息回执*/
    	WEBIM.waitMessageReceipt(message.messageId);
    },
    /*收到服务端的聊天消息*/
    handlerMessage:function(message){
    	console.log("收到 message "+JSON.stringify(message));
    	WEBIM.handlerMessageByType(message);
    },
    /*根据消息类型处理逻辑*/
    handlerMessageByType:function(message){
    	message.content=WEBIM.decryptMessage(message);

    	if(parseInt(message.type/100)==9||401==message.type||402==message.type){
			return WEBIM.handlerGroupGontrolMessage(message);
		}else if (message.type>99&&message.type<130){
			return WEBIM.handlerAudioOrVideoMessage(message);
		}else if (parseInt(message.type/100)==5){
			return WEBIM.handlerNewFriendMessage(message);
		}else if(message.fromUserId==message.toUserId==WEBIM.userId &&
			message.type==MessageType.Type.NEW_MEMBER && message.chatType == WEBIM.GROUPCHAT){
			return;
		}else if (86==message.type) {
			/*红包过期退款消息不处理*/
			return;
		}

		switch (message.type){
	        case MessageType.Type.READ:
	            WEBIM.handlerReadReceipt(message);
	            break;

	        case MessageType.Type.INPUT:
	            WEBIM.handlerInputingMessage(message)
	            break;

	        case MessageType.Type.REVOKE:
	        	if(message.messageId.substring(0, 8)=="skimweb_" && WEBIM.userId==message.fromUserId)
	        	break;
	            WEBIM.handlerRevokeMessage(message)
	            break;

	        case MessageType.Type.DEVICE_UPDATE_SETTING: //多设备更新用户设置，web 端不处理
	        	break;

	        case MessageType.Type.DEVICE_UPDATE_USER_INFO: //多设备更新用户信息
	        	WEBIM.handlerDeviceUserDataUpdateMessage(message);
	        	break;

	        case MessageType.Type.DEVICEONLINE: //当前用户在其他设备上线
	        	 DeviceManager.receiveReceived(message);
	        	break;

	       	default:
	      	 	ConversationManager.processMsg(message);
	            break;
	    }

	},
    /*收到消息回执*/
    handlerMsgReceipt:function(messageId){
    	ConversationManager.processReceived(messageId);
    	delete WEBIM.waitReceiptMessageIds[messageId];
    },
    /*收到 群控制消息 */
    handlerGroupGontrolMessage:function(message){
    	ConversationManager.handlerGroupGontrolMessage(message);
    },
    /*收到音视频通话消息*/
    handlerAudioOrVideoMessage:function(message){
		ConversationManager.handlerAudioOrVideoMessage(message);
    },
    /*处理新的朋友消息*/
    handlerNewFriendMessage:function(message){
		ConversationManager.handlerNewFriendMessage(message);
    },
    /*处理正在输入消息*/
    handlerInputingMessage:function(message){

    },
    /*处理撤回消息*/
    handlerRevokeMessage:function(message){
		ConversationManager.handlerRevokeMessage(message);
    },
    /*设备登陆冲突被挤下线*/
    handlerLoginConflict:function(){
    	console.log("handlerLoginConflict====>");
    	ConversationManager.handlerLoginConflict();
    },
    /*多设备用户数据更新消息  type 801 */
    handlerDeviceUserDataUpdateMessage:function(message){

    },
    /*发送消息已读回执*/
    sendMessageReadReceipt:function(to,messageId){
    	var msg=WEBIM.createMessage(26,messageId);
		msg.to=to;
		if (WEBIM.isGroup(to)) {
			msg.chatType=WEBIM.GROUPCHAT;
		} else {
			msg.chatType =WEBIM.CHAT;
		}
		var msgObj=msg;
		WEBIM.sendMessage(msgObj);
		return msg;
    },
    /*收到消息已读回执*/
    handlerReadReceipt:function(message){
    	ConversationManager.handlerReadReceipt(message);
    },
    /*处理 漫游的历史聊天记录*/
    handlerHistoryMessageResult:function(result){
    	var message=null;
    	if(result.messageList){
			for (var i = 0; i <result.messageList.length; i++) {
	    		message=result.messageList[i];
	    		message=SKIMSDK.convertToClientMsg(message);
	    		message.content=WEBIM.decryptMessage(message);
	    		result.messageList[i]=message;
	    		//DataUtils.putMsgRecordList(result.jid,message.messageId,1);
	    		//console.log("handlerHistoryMessageResult "+JSON.stringify(message));
	    	}
	    }

    	ConversationManager.handlerHistoryMessageResult(result);
    },
     /*处理 批量群组的 离线消息数量*/
    handlerGroupMessageResult:function(result){
    	//console.log("handlerGroupMessageCountResult "+JSON.stringify(result));
    	var message=null;
    	if(result.messageList){
    		DataUtils.clearMsgRecordList(result.jid);
    		for (var i = 0; i <result.messageList.length; i++) {
	    		message=result.messageList[i];
	    		message=SKIMSDK.convertToClientMsg(message);
	    		result.messageList[i]=message;
	    		//console.log("handlerGroupMessageCountResult "+JSON.stringify(message));
    		}
    	}

    	ConversationManager.handlerGroupMessageResult(result);


    },
     /*批量请求 群组消息数量*/
	pullBatchGroupMessage:function(jidList){
		if(SKIMSDK.isConnect()){
			SKIMSDK.pullBatchGroupMessage(jidList);
			WEBIM.waitPullBatchGroups=null;

		}else{
			WEBIM.waitPullBatchGroups=jidList;
		}


	},
	 /*请求漫游聊天记录*/
	pullHistoryMessage:function(chatType,jid,size,startTime,endTime){
		 if(!endTime){
             endTime=0;
         }
         if(!startTime){
            startTime=0;
         }
       SKIMSDK.pullHistoryMessage(chatType,jid,size,startTime,endTime);
    },
    /*等待服务器消息回执*/
    waitMessageReceipt:function(messageId){
    	WEBIM.waitReceiptMessageIds[messageId]=1;
    	setTimeout(function(){
			//消息 发送失败 没有收到回执
			if (WEBIM.waitReceiptMessageIds[messageId]) { 
				WEBIM.sendMessageTimeOut(messageId);
			}
			
		},WEBIM.sendTimeOut*1000,messageId);
    },
    /*发送消息超时 没有收到消息回执 处理 页面逻辑*/
    sendMessageTimeOut:function(messageId){
    	ConversationManager.sendTimeout(messageId);
    },
    /**
	 * 加入群聊
	 * @param  {[type]} groupJid [群组Jid]
	 */
	joinGroupChat : function(groupJid,userId,seconds) {
		if(!seconds){
		 	/*var logOutTime=DataUtils.getLogoutTime();
			if(logOutTime>0)
			  seconds=getCurrentSeconds()-DataUtils.getLogoutTime();
			else*/

		}
		shikuLog(groupJid+"  joinGroup seconds "+seconds);
		SKIMSDK.joinGroupChat(groupJid,seconds);
		
	},
	/*退出群聊*/
	exitGroupChat:function(groupJid){
		SKIMSDK.exitGroupChat(groupJid);
	},
	/*转发 刷新消息属性*/
	refreshMessage:function(msg,toUserId){
		var timeSend =WEBIM.getServerTime();
		var messageId=WEBIM.randomUUID();

		msg.messageId=messageId;
		msg.fromUserId = WEBIM.userId + "";
		msg.fromUserName = WEBIM.nickname;
		msg.toUserId=toUserId+"";
		msg.timeSend = timeSend;
		msg.objectId=msg.objectId;

			/*if(msg.location_x){
           	  message.location_x=msg.location_x;
             }
	        if(msg.location_y){
	            message.location_y=msg.location_y;
	         }
			if(10==msg.type){
				message.type=msg.contentType;
				message.content=msg.text;
			}else{
				message.type=msg.type;
				message.content=msg.content;
			}*/
		msg.content=(msg.content+"").replaceAll('<br/>','\n');
			if(true==WEBIM.encrypt)
			msg.isEncrypt=1;
		if(4>msg.type&&6!=msg.type&&1==myData.isReadDel)
			msg.isReadDel=myData.isReadDel;
		msg.forward=1;

	},
	/*构建一条消息*/
	createMessage :function(type,content,toUserId,toUserName){
		var timeSend =WEBIM.getServerTime();
		var messageId=WEBIM.randomUUID();
			var msg = {
				messageId:messageId,
				fromUserId : WEBIM.userId + "",
				fromUserName : WEBIM.nickname,
				content : content,
				timeSend : timeSend,
				type : type
			};
			if(true==WEBIM.encrypt)
				msg.isEncrypt=WEBIM.encrypt;
			if(4>type&&6!=type)
				msg.isReadDel=1==myData.isReadDel;

			if(toUserId)
				msg.toUserId=toUserId+"";
			else
				msg.toUserId=ConversationManager.fromUserId+"";
			if(toUserName)
				msg.toUserName=toUserName;
			else{
				msg.toUserName=ConversationManager.nickName;
			}
			msg.to=msg.toUserId;
			msg.chatType = (SKIMSDK.isGroup(msg.to)?WEBIM.GROUPCHAT:WEBIM.CHAT);
			return msg;
			
	},
	/*创建一个 语音消息*/
	createVoiceMessage:function(type,content,size,time){
		var timeSend =WEBIM.getServerTime();
		var messageId=WEBIM.randomUUID();
			var msg = {
				messageId:messageId,
				fromUserId : WEBIM.userId + "",
				fromUserName : WEBIM.nickname,
				content : content,
				fileSize:size,
				timeLen:time,
				timeSend : timeSend,
				type : type
			};
			if(true==WEBIM.encrypt)
				msg.isEncrypt=WEBIM.encrypt;
			if(4>type&&6!=type)
				msg.isReadDel=1==myData.isReadDel;
			return msg;
	},
	/*转换为 客户端的 消息*/
    convertToClientMsg:function(message){
      return SKIMSDK.convertToClientMsg(message);
    },
    /*是否是 群组消息*/
    isGroupType:function(chatType){
		return WEBIM.GROUPCHAT==chatType;
    },
    /*是否是 单聊消息*/
    isChatType:function(chatType){
    	return WEBIM.CHAT==chatType;
    },
    randomUUID : function() {
        return WEBIM.cont+WEBIM.userId+WEBIM.getTimeSecond()+Math.round(Math.random()*1000);
    },
    /*获取服务器的当前时间秒*/
    getServerTime:function(){
    	return Math.round((WEBIM.getMilliSeconds()-WEBIM.timeDelay));
    },
    getServerTimeSecond:function(){
    	return Math.round((WEBIM.getMilliSeconds()-WEBIM.timeDelay)/1000);
    },
	getTimeSecond:function(){
		return Math.round(new Date().getTime()/1000);
	},
	getMilliSeconds:function(){
		return Math.round(new Date().getTime());
    },
	toDateTime : function(timestamp) {
		return (new Date(timestamp * 1000)).format("yyyy-MM-dd hh:mm");
	},
	toDate : function(timestamp) {
		return (new Date(timestamp * 1000)).format("yyyy-MM-dd");
	},
	isContains: function(str, substr) {
		if(!str)
			return false;
    	return str.indexOf(substr) >= 0;
	},
	isNil : function(s) {
		return undefined == s ||"undefined"==s|| null == s || $.trim(s) == "" || $.trim(s) == "null"||NaN==s;
	},
	notNull : function(s) {
		return !this.isNil(s);
	},
    getUserIdFromJid:function (jid){
    	return SKIMSDK.getUserIdFromJid(jid);
    },
	getBareJid: function (jid){
		return SKIMSDK.getBareJid(jid);
    },
	getResource : function(jid) {
		return SKIMSDK.getResource(jid);
	},
	/*是否为群组 Jid*/
	isGroup : function(userId) {
		userId+="";
		if(userId.indexOf("/") >= 0)
			return false;
		var reg = /^[0-9]*$/;
		if(!reg.test(userId))
			return true;
		else
			return false;
	},
	isGroupChat:function(chatType){
		return WEBIM.GROUPCHAT==chatType;
	},
	isUserId:function(userId){
		return WEBIM.userId==userId;
	},
	/*判断消息是否加密*/
	isEncrypt:function(msg){

		return true==msg.isEncrypt;

	},
	//消息加密
	encryptMessage:function(msg){
		var key=WEBIM.getMsgKey(msg);
		
		console.log("encryptMsg content  "+msg.content);
		var content=WEBIM.encryptDES(msg.content,key);
		//msg.content=content;
		console.log( "encryptMsg key "+key+"  content "+content);
		return content;
	},//消息解密
	decryptMessage:function(msg) {
		//检查消息是否加密 并解密
		/*if(msg.type==26){
			return cb(msg,o);
		}*/

		if(WEBIM.isEncrypt(msg)){
			msg.content=msg.content.replace(" ", "");
			var key=WEBIM.getMsgKey(msg);
			//console.log("decryptMsg content  "+msg.content);
			var content=WEBIM.decryptDES(msg.content,key);
			if(myFn.isNil(content)){
				return msg.content;
			}
			//console.log( "decryptMsg key "+key+"  content "+content);
			return content;
			
		}else{
			return msg.content;
		}
		
	},
	createOpenApiSecret(obj){
		if(!obj){
			obj={};
		}
		obj.time=getCurrentSeconds();
		var api_time=AppConfig.apiKey+obj.time;
		
		var md5Key=$.md5(api_time);
		obj.secret=md5Key;
		return obj;
	},
	//创建 密钥
	createCommApiSecret(obj){
		obj.time=WEBIM.getServerTimeSecond();
		var key="";
		if(!myFn.isNil(myData.userId)&&!myFn.isNil(obj.access_token)){
			key = AppConfig.apiKey+obj.time+myData.userId+obj.access_token;
		}else{
			return WEBIM.createOpenApiSecret(obj);
		}
		var md5Key=$.md5(key);
		obj.secret=md5Key;
		return obj;
	},
	createRedSecret(obj){
		obj.time=WEBIM.getServerTimeSecond();
		var api_time=AppConfig.apiKey+obj.time;
		var userId_token=WEBIM.userId+WEBIM.token;
		var md5ApiTime=$.md5(api_time);
		var md5Password=$.md5(obj.password);
		var key=md5ApiTime+userId_token+md5Password;
		var md5Key=$.md5(key);
		obj.secret=md5Key;
		return obj;
	},
	receiveRedSecret(obj){
		obj.time=WEBIM.getServerTimeSecond();
		var api_time=AppConfig.apiKey+obj.time;
		var userId_token=WEBIM.userId+WEBIM.token;
		var md5ApiTime=$.md5(api_time);
		var key=md5ApiTime+userId_token;
		var md5Key=$.md5(key);
		obj.secret=md5Key;
		return obj;
	},
	getMsgKey:function(msg){
		var key= AppConfig.apiKey+parseInt(msg.timeSend)+msg.messageId;
		return $.md5(key);
	},
	encryptDES:function(message,key){
	 	var keyHex = CryptoJS.enc.Utf8.parse(key);
        var encrypted = CryptoJS.TripleDES.encrypt(
                       message, 
                        keyHex, {  
                        iv:CryptoJS.enc.Utf8.parse(iv),    
                        mode: CryptoJS.mode.CBC,    
                        padding: CryptoJS.pad.Pkcs7
                        });
        //encrypted=CryptoJS.enc.Utf8.stringify(decrypted);
       // console.log("encryptDES "+encrypted);
       var result= encrypted.ciphertext.toString(CryptoJS.enc.Base64);
       return result;
	},
	decryptDES:function(message,key){
		//把私钥转换成16进制的字符串
        var keyHex = CryptoJS.enc.Utf8.parse(key);
         
        //把需要解密的数据从16进制字符串转换成字符byte数组
        var decrypted = CryptoJS.TripleDES.decrypt({
            ciphertext: CryptoJS.enc.Base64.parse(message)
        }, keyHex, {
            iv:CryptoJS.enc.Utf8.parse(iv), 
            mode: CryptoJS.mode.CBC,
            padding: CryptoJS.pad.Pkcs7
        });
        //以utf-8的形式输出解密过后内容
        var result = decrypted.toString(CryptoJS.enc.Utf8);
        return result;
	},
	//格式化 要显示的 消息标题 如 [图片] [位置]
	parseShowMsgTitle:function(msg){
		var content;
		switch (msg.type){
			case 1:
				content=msg.content;
			  break;
			case 2:
				content="[图片]";
			  break;
			case 3:
				content="[语音]";
			  break;
			case 4:
				content="[位置]";
			  break;
			case 5:
				content="[动画]";
			  break;
			case 6:
				content="[视频]";
			  break;
			case 8:
				content="[名片]";
			  break;
			case 9:
				content="[文件]";
			  break;
			case 10:
				/*控制消息和通知*/
				content=msg.content;
			  break;
			case 28:
				content="[红包]";
			  break;
			case 83:
				content="[领取了红包]";
			  break;
			default://默认 其他
				content="";
				break ;
		}
		if(myFn.isNil(content)){
			if((99<msg.type&&130>msg.type)||(99<msg.contentType&&130>msg.contentType)){
				//音视频 消息 
				 content=msg.content;
			}else if(400<msg.type)
				content="[群控制消息]";
		}
		if(myFn.isNil(content))
			content="[不支持 请在手机端查看]";
		return content;
	},
	/*转换 群控制消息*/
	converGroupMsg : function(msg) {
		var content =null;
		msg.text=msg.content;
		var appendTime=true;
		switch(msg.type){
			case 83:
				msg.content=msg.fromUserName+" 领取了你的红包 ";
			  	break;
			case 401:
				var fileName=msg.fileName.substring(msg.fileName.lastIndexOf("/")+1);
			  	msg.content=msg.fromUserName+" 上传了群文件 "+fileName;
			  	break;
			case 402:
			  	msg.content=msg.fromUserName+" 删除了群文件 ";
			  	break;
			case 901:
			  	msg.content=msg.fromUserName+" 群昵称修改为 "+msg.content;
			  	break;
			case 902:
			   	msg.content="群组名称修改为： "+msg.content;
			  	break;
			case 903:
			   	msg.content="群组被删除";
			  	break;
			case 904:
				if(msg.fromUserId==msg.toUserId)
			 		  msg.content=msg.toUserName+" 已退出群组";
			 	else 
			 		 msg.content=msg.toUserName+" 已被移出群组";
			  	break;
			case 905:
			   	msg.content="新公告为: "+msg.content;
			  	break;
			case 906:
				if(!WEBIM.isGroupType(msg.chatType))
					return null;
				msg.talkTime=msg.content;
				if(0==msg.content||"0"==msg.content)
					 msg.content=msg.toUserName+" 已被取消禁言 ";
				else
			  		 msg.content=msg.toUserName+" 已被禁言 ";
			  	break;
			case 907:
				if(msg.fromUserId==msg.toUserId)
			   		msg.content=msg.fromUserName+" 已加入群组";
			   	else msg.content=msg.fromUserName+" 邀请 "+msg.toUserName+" 加入群组";
			  	break;
			case 913:
				if(!WEBIM.isGroupType(msg.chatType))
					return null;
			  	if(1==msg.content||"1"==msg.content)
					msg.content=msg.toUserName+" 被设置管理员 ";
				else
					msg.content=msg.toUserName+" 被取消管理员 ";
			  	break;
			case 915:
			  	//群已读消息开关
			 	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了显示消息已读人数";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了显示消息已读人数";
			 	break;
			case 916:
			  	if(myFn.isNil(msg.content)){
			  		//邀请好友
			  		appendTime=false;
			  		var inviteObj=eval("(" +msg.objectId+ ")");
			  		if("0"==inviteObj.isInvite||0==inviteObj.isInvite){
			  			var count=inviteObj.userIds.split(",").length;
			  			msg.content=msg.fromUserName+" 想邀请 "+count+" 位朋友加入群聊 ";
			  		}else{
			  			msg.content=msg.fromUserName+" 申请加入群聊 ";
					}
			  		msg.content+=GroupManager.createGroupVerifyContent(msg.messageId);
			  	}else{
			  		if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了进群验证";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了进群验证";
			  	}
			 	break;
			case 917:
			  	//群公开状态
			 	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 修改为隐私群组";
			  	}else
			  	 	msg.content=msg.fromUserName+" 修改为公开群组";
			 	break;
			case 918:
			 	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了显示群成员列表";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了显示群成员列表";
			 	break;
			case 919:
			  	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了允许普通群成员私聊";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了允许普通群成员私聊";
			 	break;
			case 920:
			  	if(0==msg.content||"0"==msg.content){
			  		msg.content=msg.fromUserName+"已取消全体禁言";
			  	}else{
			  		msg.content=msg.fromUserName+"已开启全体禁言";
			  	}
				break;
			case 921:
			  	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了允许普通成员邀请好友";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了允许普通成员邀请好友";
			 	break;
			case 922:
			  	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了允许普通成员上传群共享文件";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了允许普通成员上传群共享文件";
			 	break;
			case 923:
			  	if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了允许普通成员召开会议";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了允许普通成员召开会议";
			 	break;
			case 924:
			  if(1==msg.content||"1"==msg.content){
			  		msg.content=msg.fromUserName+" 开启了允许普通成员讲课";
			  	}else
			  	 	msg.content=msg.fromUserName+" 关闭了允许普通成员讲课";
			 	break;
			 
			 case 925:
				 if(!WEBIM.isGroupType(msg.chatType))
						return null;
			 	msg.content=msg.toUserName+" 已成为新群主";
			 	break;

			 case 931:  //群锁定、解锁
			 	msg.content= "此群已"+(msg.content==-1?"被锁定":"解除锁定");
			 	break;
			default:
				break;
		}
		msg.contentType=msg.type;
		msg.type=10;
		if(true==appendTime)
			msg.content+="  ("+myFn.toDateTime(msg.timeSend)+")";
		console.log(msg.content);
		return msg;
	},
    initConfig:function(){
		mySdk.getConfig(function(result){
			shikuLog("====> initConfig > "+JSON.stringify(result));
			if(myFn.isNil(result))
				return;
			/*if(result.apiUrl.endWith("/")){
				result.apiUrl+="__";
				result.apiUrl=result.apiUrl.replace("/__","");
			}
			AppConfig.apiUrl=result.apiUrl;*/

			
			if(!myFn.isNil(result.XMPPHost)){
				AppConfig.xmppHost=result.XMPPHost;
			}

			if(!myFn.isNil(result.meetingHost)){
				AppConfig.meetingHost=result.meetingHost;
			}
			if(result.jitsiServer){
				AppConfig.jitsiServer=result.jitsiServer.replace("https://","");
			}

			AppConfig.companyId = result.customer_companyId; //客服模块公司id
			AppConfig.departmentId = result.customer_departmentId; //客服部门id

			AppConfig.uploadUrl=AppConfig.uploadServer+"upload/UploadifyServlet";
			AppConfig.uploadAvatarUrl=AppConfig.uploadServer+"upload/UploadifyAvatarServlet";
			AppConfig.uploadVoiceUrl=AppConfig.uploadServer+"upload/UploadVoiceServlet";
			AppConfig.deleteFileUrl=AppConfig.uploadServer+"upload/deleteFileServlet";
			AppConfig.avatarBase=AppConfig.fileServer+"avatar/o/";
			AppConfig.defaultAvatarUrl=AppConfig.fileServer+"avatar/t/104/10000104.jpg";
			AppConfig.defaultAvatarUrl=AppConfig.fileServer+"image/ic_avatar.png";

			if(result.xmppPingTime){
				myData.keepalive=result.xmppPingTime;
			}

			AppConfig.isOpenReceipt=result.isOpenReceipt;
			if(1==AppConfig.isOpenReceipt){
				AppConfig.isOpenReceipt=1;
			}
			
			AppConfig.isOpenReceipt=1;

			AppConfig.isOpenSMSCode=result.isOpenSMSCode;
			AppConfig.registerInviteCode=result.registerInviteCode;
			AppConfig.regeditPhoneOrName=result.regeditPhoneOrName;
			AppConfig.isOpenRoomSearch = myFn.isNil(result.isOpenRoomSearch)?1:result.isOpenRoomSearch;
		});
	},



}
var ivKey=[1,2,3,4,5,6,7,8];
function getStrFromBytes (arr) {
    var r = "";
    for(var i=0;i<arr.length;i++){
        r += String.fromCharCode(arr[i]);
    }
    //console.log(r);
    return r;
}
var iv=getStrFromBytes(ivKey);

function getCurrentSeconds(){
  return Math.round(new Date().getTime() / 1000);
}

function getCurrentMilliSeconds(){
    return Math.round(new Date().getTime());
}

  // 时间统一函数
//type  1 上午10:00  否则 10:00   
function getTimeText(argument,type,isSecond) {
  if(0==argument)
    return "";
	argument=new Number(argument);
    var timeDesc="";
    var timeSend =0;
    
    if(1==isSecond){
    	timeSend=new Date(argument*1000);
    }else{
		timeSend=new Date(argument);
    }
   var nowTime=new Date();
   var delaySeconds=((nowTime.getTime())-timeSend.getTime())/1000;
   if(delaySeconds<65){
      if(type){
                  timeDesc="刚刚";
        }else{
             timeDesc=timeSend.format("hh:mm");
        }
   }else if(delaySeconds<60*30){
       if(type){
                 timeDesc=parseInt(delaySeconds/60)+" 分钟前";
        }else{
             timeDesc=timeSend.format("hh:mm");
        }
    }else if(delaySeconds<60*60*24){
        if(nowTime.getDay()-timeSend.getDay()==0){
            //今天
            if(type){
            	timeDesc=(timeSend.getHours()<13 ? "上午":"下午")+timeSend.format("hh:mm");
            }else{
            	 timeDesc=timeSend.format("hh:mm");
            }
    	}else{
            //昨天
            timeDesc="昨天"+timeSend.format("hh:mm");
            // if(type){
            // 	timeDesc=(timeSend.getHours()<13 ? "昨天上午":"昨天下午")+timeSend.format("hh:mm");
            // }else{
            // 	 timeDesc="昨天"+timeSend.format("hh:mm");
            // }
        }
    }else{
    	 if(type){
            	 timeDesc=timeSend.format("MM-dd hh:mm");
            }else{
            	 timeDesc=timeSend.format("MM-dd hh:mm");
            }
    }

    return timeDesc;
       
    
}


var MessageType={
  	Type:{

    /**
     * 消息类型：群聊提示消息
     */
     _900:900,// 已进群
     _901:901,// 已退群
   
    /**
     * 消息类型：商务圈消息
     */
     NEW_COMMENT:600,// 新评论
     _601:601,// 新礼物
     _602:602,// 新赞
     _603:603,// 新公共消息


    /**
     * 消息类型：音视频通话 会议消息
     */
    //单聊 语音
    VOICE_ASK:100,//询问能否接听语音通话 
    VOICE_ANSWER:101,//确定可以接听语音通话
    VOICE_CONNECT:102,//接听语音通话  无用
    VOICE_CANCEL:103,//拒绝取消语音拨号 
    VOICE_STOP:104,//接通后结束语音通话
    //单聊视频
    VIDEO_ASK:110,//询问能否接听通话 
    VIDEO_ANSWER:111,//确定可以接听通话
    VIDEO_CONNECT:112,//接听通话  无用
    VIDEO_CANCEL:113,//拒绝取消拨号 
    VIDEO_STOP:114,//接通后结束通话
    //视频会议
    Conference_VIDEO_INVITE:115,//邀请进行视频会议
    Conference_VIDEO_JOIN:116,//加入视频会议
    Conference_VIDEO_EXIT:117,//退出视频会议
    Conference_VIDEO_OUT:118,//踢出视频会议
     //语音会议
    Conference_VOICE_INVITE:120,//邀请进行视频会议
    Conference_VOICE_JOIN:121,//加入视频会议
    Conference_VOICE_EXIT:122,//退出视频会议
    Conference_VOICE_OUT:123,//踢出视频会议
    



    /**
     * 消息类型：新朋友消息
     */
     SAYHELLO:500,// 打招呼
     PASS:501,// 同意加好友
     FEEDBACK:502,// 回话
     NEWSEE:503,// 新关注
     DELSEE:504,// 删除关注
     DELALL:505,// 彻底删除
     RECOMMEND:506,// 新推荐好友
     BLACK:507,// 黑名单
     FRIEND:508,// 直接成为好友
     REFUSED:509,//取消黑名单

     READ:26, // 是否已读的回执类型
     COMMENT:27, // 通知评论消息
     RED:28, // 红包消息

     ////////////////////////////以下为在聊天界面显示的类型/////////////////////////////////
     TEXT:1,// 文字
     IMAGE:2,// 图片
     VOICE:3,// 语音
     LOCATION:4,// 位置
     GIF:5,// gif
     VIDEO:6,// 视频
     SIP_AUDIO:7,// 音频
     CARD:8,// 名片
     FILE:9,//文件
     TIP:10,// 自己添加的消息类型,代表系统的提示

     DEVICEONLINE:200, //用户的其它设备上线
     DEVICE_UPDATE_SETTING:800, //多设备更新用户设置
     DEVICE_UPDATE_USER_INFO:801, //多设备更新用户信息

     INPUT:201, // 正在输入消息
     REVOKE:202,
     IMAGE_TEXT:80, // 单条
     IMAGE_TEXT_MANY:81, //多条

     //PINGLUN:42, // 正在输入消息
   
    // 群聊推送
     CHANGE_NICK_NAME:901,// 修改昵称
     CHANGE_ROOM_NAME:902,// 修改房间名
     DELETE_ROOM:903,// 删除房间
     DELETE_MEMBER:904,// 删除成员
     NEW_NOTICE:905,// 新公告
     GAG:906,// 禁言
     NEW_MEMBER:907,// 增加新成员




  	},

   
}
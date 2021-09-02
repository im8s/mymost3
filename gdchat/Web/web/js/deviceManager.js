//多设备 管理

var DeviceManager = {
	jid:"",//没有resource 的jid  10000@im.server.com
	//所有设备列表
	allDeviceArr:["ios","android","pc","mac"],
	//在线的设备列表
	onlineDeviceArr:[],
	//初始化
	initJid:function(){
		DeviceManager.jid = WEBIM.userIdStr;
	},
	init:function(){

		//DeviceManager.initMyDevices();
		DeviceManager.login();

	},
	//登陆
	login:function(){
		
		/*var msg=null;
		var key;
		for(var i in DeviceManager.allDeviceArr){
			 key=DeviceManager.allDeviceArr[i];
			 msg=WEBIM.createMessage(200,1,myData.userId);
			 DeviceManager.sendMsg(msg,key);
		}*/
	},
	//更新设备状态
	updateDeviceStatus:function(key,status){
		console.log("updateDeviceStatus key "+key+"  status "+status);
		var device=DeviceManager.onlineDeviceArr[key];
		if(!device){
			if(0==status)
				return;
			 device=new DeviceManager.Device(key);
			 DeviceManager.onlineDeviceArr[key]=device;
			 
		}
		device.updateDeviceStatus(status);
	},
	//设备对象
	Device:function(key,isOnline,isPingOk) {
		if(key)
			this.key=key;
		//在线状态
		if(isOnline)
			this.isOnline=isOnline;
		else
			this.isOnline=false;
		//最后一次ping 是否收到回执
		if(isPingOk)
			this.isPingOk=isPingOk;
		else
			this.isPingOk=false;

		//更新设备状态
		this.updateDeviceStatus=function(status){
			var isOnline=false;
			var isPingOk=false;
			if(1==status){
				isOnline=true;
				isPingOk=true;
			}
			this.isOnline=isOnline;
			this.isPingOk=isPingOk;
			if(isOnline){
				//this.resetTimer();
				$("#deviceStatus_"+this.key).html("(在线)");
				//DeviceManager.onlineDeviceArr[this.key]=this;
			}else{
				$("#deviceStatus_"+this.key).html("(离线)");
				//this.stopTimer();
				DeviceManager.onlineDeviceArr[this.key]=null;
			}
		};
		//停止计时器
		this.stopTimer=function(){
			window.clearTimeout(this.timer);   
		};
		//重制计时器
		this.resetTimer=function(){
			shikuLog("==resetTimer start key "+this.key);
			this.stopTimer();
			this.startTimer();
		};
		//开启计时器
		this.startTimer=function(){
			var time = new Date().format("yyyy-MM-dd hh:mm:ss");
			shikuLog(time+"==startTimer start key "+this.key);
			this.timerInit();
		};
		//定时器 执行
		this.timerFinished=function(device){
			var time = new Date().format("yyyy-MM-dd hh:mm:ss");
			shikuLog(time+"==timerFinished start key > "+device.key+" isOnline > "+device.isOnline+" isPingOk > "+device.isPingOk);
			if(device.isPingOk){
				device.isPingOk=false;
				shikuLog("==timerFinished end key > "+device.key+" isOnline > "+device.isOnline+" isPingOk > "+device.isPingOk);
				DeviceManager.sendOnLineMessage(device.key);
				device.resetTimer();
			}else{
				device.isOnline=false;
				DeviceManager.onlineDeviceArr[device.key]=null;
				shikuLog("==timerFinished end key > "+device.key+" isOnline > "+device.isOnline+" isPingOk > "+device.isPingOk);
				shikuLog("== key > "+device.key+" isOnline > "+device.isOnline+" 离线 定时器销毁 》");
			}
			
			

		};
		this.timerInit=function(){
		 this.timer=window.setTimeout(this.timerFinished,60000*2,this);
		 return this.timer;
		};
		//定时器对象
		this.timer=null;
		


	},
	//发送上线消息
	sendOnLineMessage:function(key){
		var msg=WEBIM.createMessage(200,1,myData.userId);
		if(key){
			DeviceManager.sendMsg(msg,key);
		}else
			DeviceManager.sendMsgToMyDevices(msg);
	},
	//发送离线消息
	sendOffLineMessage:function(){
		var msg=WEBIM.createMessage(200,0,myData.userId);
		DeviceManager.sendMsgToMyDevices(msg);
	},
	//发送消息到 我的在线设备
	sendMsgToMyDevices:function(msg){
		var device;
		for(var i in DeviceManager.onlineDeviceArr){
			device=DeviceManager.onlineDeviceArr[i];
			if(myFn.isNil(device))
				continue;
			DeviceManager.sendMsg(msg,device.key);
		}
	},
	//发送xmpp 消息
	sendMsg:function(msg,key){
		//shikuLog("sendMsg  "+msg);
		msg.to = myData.userId+"/"+key;
		WEBIM.sendMessage(msg);
	},
	//收到好友消息
	receiverMessage:function(message){
		var from =message.from;
		if(myFn.isNil(from))
			return;
		var fromUserId = WEBIM.getUserIdFromJid(from);
		if(fromUserId==WEBIM.userId)
			return;
		//发送者的 resource
		/*var resource=WEBIM.getResource(from);
		shikuLog(" device receiverMessage > "+resource);
		if(myFn.isNil(resource)||resource==WEBIM.resource)
			return;*/
		DeviceManager.sendMsgToMyDevices(message);
	},
	receiverDeviceMessage:function(message){
		//收到当前账号其他设备消息
				//判断收到回执
		var from =message.from;
		if(myFn.isNil(from))
			return;
		var fromUserId = WEBIM.getUserIdFromJid(from);
		if(fromUserId!=myData.userId)
			return;
		//发送者的 resource
		var resource=WEBIM.getResource(from);
		shikuLog("receive message > "+resource);
		if(myFn.isNil(resource)||resource==WEBIM.resource)
			return;
		/*var received=message.getElementsByTagName('received')[0];
		//发送ping消息的回执
		if(!myFn.isNil(received)){
			DeviceManager.updateDeviceStatus(resource,1);
		}*/

		var type = message.chatType;
		var msg=message;
		

		var status=0;
		//是否为自己 在线状态 的消息
		var isReceived=false;
		if(200==msg.type){
			status=parseInt(msg.content);
			isReceived=true;
			DeviceManager.updateDeviceStatus(resource,status);
		}else if(26==msg.type){
			UI.showMsg(msg,msg.fromUserId,0,0);
			var message=DataUtils.getMessage(msg.content);
			if(myFn.isNil(message))
				return false;
			if(myFn.isReadDelMsg(message)){
				DataUtils.removeMsgRecordList(msg.toJid,msg.content);
				DataUtils.deleteMessage(msg.content);
				return true;
			}
			message.isRead=1;
			DataUtils.saveMessage(message,msg.content);
			isReceived=true;
		}
		return isReceived;
	},
	receiveReceived:function(message){
		/*收到其他设备发送的回执*/
		var id = message.messageId;
		var from = message.from;
		if(myFn.isNil(from))
			return;
		var fromUserId = WEBIM.getUserIdFromJid(from);
		if(fromUserId!=myData.userId)
			return;
		//发送者的 resource
		var resource=WEBIM.getResource(from);
		shikuLog("receiveReceived > "+resource);
		if(myFn.isNil(resource)||resource==WEBIM.resource)
			return;
		DeviceManager.updateDeviceStatus(resource,1);
		
		

	},
	//处理主动发送给其他设备的消息
	processUiSendMessage:function(msg){
		var from=ConversationManager.from;
		var resource=WEBIM.getResource(from);
		if(myFn.isNil(resource))
				return;
	},
	//处理收到要显示的消息
	processShowMessage:function(msg,isSend,isOpen){


		var from;//对方
		//isSend 是否发送出去的消息
		if(!isSend){
			//正在输入状态 终止执行
			if(MessageType.Type.INPUT==msg.type)
				return;
			if(MessageType.Type.READ==msg.type)
				return;
			//接收到的消息
			if(myData.userId!=msg.toUserId){
				//自己其他设备发送给好友的消息 转发给我的
				//msg.fromUserId=msg.toUserId;
				UI.playSound();
				return msg;
			}
			//同账号 其他设备发送给当前设备的消息
			from=msg.fromJid;
		}else{
			//发送出去的消息
			from=ConversationManager.from;
			msg.fromJid = WEBIM.userIdStr;
			msg.toJid = from;
			DataUtils.saveMessage(msg);
		}
			
		var resource=WEBIM.getResource(from);
		if(myFn.isNil(resource))
			return;
		msg.isMyDevice=1;
		msg.deviceKey=resource;

		msg.fromUserName=DeviceManager.getDeviceName(resource);
		
		if(!isSend)
			msg.imgUrl=DeviceManager.getDeviceImg(resource);
		else
		 	msg.imgUrl=DeviceManager.getDeviceImg("web");	

		var content=WEBIM.parseShowMsgTitle(msg);
		if(!isSend&&!isOpen||from!=ConversationManager.from){
			if(MessageType.Type.INPUT==msg.type)// 正在输入状态 终止执行
				return;
			UI.showNotification(msg.imgUrl,msg.fromUserName,content);
			this.moveFriendToTop(msg,msg.fromUserId,1);
			
		}else if(!isSend&&isOpen&&from==ConversationManager.from){
			UI.showMsg(msg, msg.fromUserId,0,0);
			this.moveFriendToTop(msg,msg.fromUserId,0);
			ConversationManager.sendReadReceipt(from, msg.messageId); //发送已读回执
			
		}else if(isSend){ //发送出去的消息
			//type=2 图片  type=9 文件 如果是图片或文件，因为在上传时已经做了UI预加载，这里不用进行UI显示
			if (msg.type==2 || msg.type==9 ) {
				this.moveFriendToTop(msg,msg.fromUserId,0);
			}else{
				UI.showMsg(msg,msg.fromUserId,1,1);
				this.moveFriendToTop(msg,msg.fromUserId,0);
			}	
		}
			

		return null;
	},
	
	moveFriendToTop:function(msg,fromUserId,showNum,updateUI){
		//收到消息移动好友位置
		var userIdKey=null;
		if(myFn.isContains(fromUserId,"/")){
			msg.deviceKey=fromUserId.split("/")[1];
			msg.imgUrl=DeviceManager.getDeviceImg(msg.deviceKey);
			msg.fromUserName=msg.name;
			fromUserId=fromUserId.split("/")[0];
		}else if(!msg.deviceKey){
			return;
		}
		var deviceKey= fromUserId+"/"+msg.deviceKey;
			userIdKey=fromUserId+"_"+msg.deviceKey;
	
		if(!updateUI)
			updateUI=1;
		var friendHtml = $("#myMessagesList #friends_"+userIdKey).prop("outerHTML");

		var content=WEBIM.parseShowMsgTitle(msg);
		var timeSendStr=getTimeText(msg.timeSend,1);
		content=202!=msg.type?content:"撤回了一条消息";

		if(myFn.isNil(friendHtml)){ //不存在
			imgUrl=msg.imgUrl;
			friendHtml = this.createDevicesItem(imgUrl, fromUserId, msg.fromUserName,content,
				msg.deviceKey,timeSendStr);
			$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
			if(1==showNum)
				UI.showMsgNum(userIdKey,updateUI,1,deviceKey);
		}else{ //存在 则直接加入到新朋友下方
			$("#myMessagesList #friends_"+userIdKey).remove();
			$(friendHtml).insertAfter("#myMessagesList #friends_10001");
			if(1==showNum)
				UI.showMsgNum(userIdKey,updateUI,1,deviceKey);
				var parseContent = myFn.parseContent(content,1);
				$("#myMessagesList #titfriends_"+userIdKey).html(parseContent);
			
			
		}
		if(1==updateUI){
			UI.updateMessageListTimeSendStr();
			DataUtils.putUIMessageList(msg,deviceKey,msg.fromUserName);
			DataUtils.putMsgRecordList(deviceKey,msg.messageId);
		}
			
	},
	initMyDevices:function(){
		//我的设备 
        
	    var my_device_html ='<div class="" id="friends_MyDevice" onclick="DeviceManager.showMyDevice();">'
			               +     '<div class="chat_item slide-left active">'
						   +        '<div class="avatar">'
						   +         	'<img class="img roundAvatar" src="img/im_10002.png" alt="">'
						   +         	'<i id="msgNum_10002" class="icon web_wechat_reddot_middle">1</i>'
						   +     	'</div>'
					       +     	'<div id="friends_10000Div" class="info">'
					       +        	'<div class="nickname">'
					       +            	'<span class="nickname_text">我的设备</span>'
					       +				'<span id="timeSend_10002" class="timeStr" value=""></span>'
					       +         	'</div>'
					       +         	'<p class="msg">'
					       +            	'<span style="color: #3c3b3b;">设备信息</span>'
					       +         	'</p>'
					       +    	'</div>'
					       + 	'</div>'
					       +'</div>';

		var first=$("#myFriendsList div").first();
		$(my_device_html).insertBefore(first);
	},
	showMyDevice:function(){
		$("#myFriendsList").hide();
		var html ="<div id='deviceList'>";
		var status="(离线)";
		var imgUrl;
		var deviceStr;
		for(var i in DeviceManager.allDeviceArr){
			var key=DeviceManager.allDeviceArr[i]
			var device=DeviceManager.onlineDeviceArr[key];
			if(!myFn.isNil(device)&&1==device.isOnline)
				status="(在线)";
			else 
				status="(离线)";
			imgUrl=DeviceManager.getDeviceImg(key);
			deviceStr=DeviceManager.getDeviceName(key);
			html+="<div class='media-main' >"
				+"<div style='cursor: pointer;' class='media-body'>"
				+"<a class='pull-left media-avatar'>"
				+    "<img onerror='this.src=&quot;img/ic_avatar.png&quot;' width='40' height='40' alt='' src='"
				+   imgUrl+ "' class='media-object roundAvatar'>"
				+"</a>"
				+  "<div style='font-size:14px;margin-top:10px' onclick='ConversationManager.open(\"" + (myData.userId+"/"+key) + "\",\"" + deviceStr + "\");'>" 
				+      deviceStr+" "+"<span id='deviceStatus_"+key+"'>"+ status+"</span>"
				+   "</div></div></div>";
		}

		html +="</div>";
		$("#friendsTabTitle").html("<span style='margin-left:-65px'>我的设备</sapn>");
		$("#add_friend").hide();
		$("#btnFooter").hide();
		$("#myFriendsList").html(html);
		$("#myFriendsList").show();
		
		$("#back").show();
		// 让新的朋友不显示
		$("#tabCon_new").hide();

	},
	getDeviceName:function(key){
		var deviceStr;
		if("ios"==key)
			deviceStr="我的iPhone";
		else if("android"==key)
			deviceStr="我的Android";
		else if("pc"==key)
			deviceStr="我的Window电脑";
		else if("mac"==key)
			deviceStr="我的Mac电脑";
		return deviceStr;
	},
	getDeviceImg:function(key){
		var imgUrl;
		if("ios"==key||"android"==key)
				imgUrl="img/fdy.png";
		else if("pc"==key||"mac"==key||"web"==key)
			imgUrl="img/feb.png";
		return imgUrl;
	},
	createDevicesItem : function(imgUrl, userId, nickname,content,key,time) {
		

		var _item = "<div  class='' id='friends_"+userId+"_"+key+"' onclick='UI.isChoose(\"" + userId+"_"+key + "\");'>"
				  +     "<div class='chat_item slide-left active'>"
				  +          "<div class='avatar'>"
				  +              "<img class='img roundAvatar' src="+ imgUrl + ">"
				  +              "<i id='msgNum_"+userId+"_"+key+"' class='icon web_wechat_reddot_middle'>1</i>"
				  +          "</div>"
				  +          "<div class='info' onclick='ConversationManager.open(\"" + (userId +"/"+key) + "\",\"" + nickname + "\");'>"
				  +              "<div class='nickname'>"
				  +                  "<span class='nickname_text'>" + nickname + "</span>"
				  +					 "<span id='timeSend_"+userId+"' class='timeStr' value='"+time+"'>"+time+"</span>"
				  +              "</div>"
				  +              "<p class='msg'>"
				  +                  "<span style='color:#3a3f45' id='titfriends_"+userId+"_"+key+"'>" +content+ "</span>"
				  +              "</p>"
				  +          "</div>"
				  +      "</div>"
				  +  "</div>";


		return _item;
	},
	//显示同账号的历史消息
	showHistoryToHtml:function(msg){
		var itemHtml = "";
		//当前打开窗口的 设备 标识
		var deviceResource=ConversationManager.resource;
			//检查是否是该设备发送的消息
			var fromJid=msg.from;
			var toJid=msg.to;

			/*var fromXml=o.message.substr(o.message.indexOf("from=")+1,o.message.length);
				fromXml=fromXml.substr(fromXml.indexOf('"')+1,fromXml.length);
				fromXml=fromXml.substr(0,fromXml.indexOf('"'));
			var toXml=o.message.substr(o.message.indexOf("to=")+1,o.message.length);
			toXml=toXml.substr(toXml.indexOf('"')+1,toXml.length);
			toXml=toXml.substr(0,toXml.indexOf('"'));*/

			

			var fromResource=WEBIM.getResource(fromJid);
			var toResource=WEBIM.getResource(toJid);
			//不是该设备发送的消息
			if(myData.resource!=fromResource&&myData.resource!=toResource)
				return;
			var resource=myData.resource==fromResource?toResource:fromResource;

			msg.imgUrl=DeviceManager.getDeviceImg(resource);
			
			if (WEBIM.resource==fromResource&&deviceResource==toResource) {
					msg.fromUserName=myData.nickname;
					msg.imgUrl=DeviceManager.getDeviceImg("web");
					itemHtml += UI.createItem(msg,msg.fromUserId, 1);
			}else if(deviceResource==fromResource&&WEBIM.resource==toResource){
				msg.fromUserName=DeviceManager.getDeviceName(resource);
				itemHtml += UI.createItem(msg,msg.fromUserId, 0);
				if(1!=msg.isRead){
					if(1!=msg.type){
						//发送已读回执
						ConversationManager.sendReadReceipt(ConversationManager.from,msg.messageId);  
					}else if(!myFn.isReadDelMsg(msg))
						ConversationManager.sendReadReceipt(ConversationManager.from,msg.messageId);  
				}
				
			}
		return itemHtml;
		
	},
	showDeviceOnlineStatus:function(key){
		var device=DeviceManager.onlineDeviceArr[key];
		if(!myFn.isNil(device)&&1==device.isOnline)
			status="(在线)";
		else 
			status="(离线)";

		var deviceStr=DeviceManager.getDeviceName(key);
		var imgUrl=DeviceManager.getDeviceImg(key);
		var avatarHtml="<div class='imgAvatar'>"
			           +	"<figure style='height:40px;width:40px;'>"
		               +	  "<img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl+ "' class='chat_content_avatar' >"
		               +	"</figure>"
		               +"</div>";
		 $("#chatAvator").html(avatarHtml);
		setTimeout(function(){
			//$("#chatTitle ").html("<span>"+deviceStr+"</span><span id='state'>"+status+"</span>");
			$("#chatTitle #state").html(status);
			
		},200);
		
	}

}


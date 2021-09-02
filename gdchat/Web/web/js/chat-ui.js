var key_num=-10;
var playMusic=document.getElementById("myMusic");
playMusic.status=false;
var UI = {
	
	choiceEmojl : function(key) {

		$("#messageBody").val($("#messageBody").val()+key);
		//$("#emojl-panel #gifList").getNiceScroll().hide();//隐藏滚动条
		//$("#emojl-panel #emojiList").getNiceScroll().hide();
		$("#emojl-panel").hide();
	},
	// 提醒用户打开通知
	noticeUserOpen:function(){
		if(null!=ConversationManager.notice){
			return;
		}else{
			ConversationManager.notice="requesting"
			Notification.requestPermission(function(status) {
				ConversationManager.notice=status;
                // if(status === 'granted') {
                    //弹出一个通知
                //btn.addEventListener('click', function() {
	                    
	                   /* notification.onclick(function(){
	                    	 notification.close()
	                    });*/
	                    //两秒后关闭通知
	                    /*setTimeout(function() {
	                        notification.close();
	                    }, 5000);*/

				// });
                // }
            });
		}
		
	},
	//显示通知
	showNotification:function (url,name,body){
        if(!window.Notification) {
           return;
        }
       if(ConversationManager.notice=="granted"){
        	var notification=new Notification(name+":",{
	                        body : body, //显示内容
	                        //以下是可选参数
	                        icon :url,
	                        silent:true,
	                        renotify:true,
	                       
	                         tag:"imWeb",
	                        //lang :
	                        onclick:function(){
	                        	this.close();
	                        }
	                        
	                       
	                    });
        }
        
    },
    // 播放消息提醒声音
	playSound:function(){
		if(playMusic.status)
			return;
		try {
			playMusic.status=true;
			 playMusic.play();
			setTimeout(function(){
				playMusic.status=false;
			},500);
		 	
		} catch (e) {
		 	//console.log(e.name + ": " + e.message);
		 return false;
		}
		
		
	},
	online:function(){
		// 用户在线
		$("#myAvatar").removeClass("headChang");
		$("#user_online").removeClass("user_online");
		$("#user_online").addClass("user_back");
	},
	offline:function(){
		// 用户离线
		$("#myAvatar").addClass("headChang");
		$("#user_online").removeClass("user_back");
		$("#user_online").addClass("user_online");
	},
	createItem : function(msg, fromUserId, direction,isSend) {   //消息Item
		//direction  1 自己发送的   0 别人发送的
		//isSend  发送后创建消息
		//shikuLog(" createItem msg => "+ JSON.stringify(msg));
		var messageHtml = $("#messageContainer #msgs_"+msg.messageId).prop("outerHTML");
		if(messageHtml)
			return "";
		if (!WEBIM.isGroupChat(ConversationManager.chatType)) {
			if (myData.userId!=msg.fromUserId) {
				var friend =DataMap.friends[msg.fromUserId];
				if(!myFn.isNil(friend)){
					if(friend.remarkName)
						msg.fromUserName=friend.remarkName;
					else if(!msg.fromUserName)	
						msg.fromUserName=friend.toNickname;
				}
			}
			
		} else {
			if(myData.userId!=msg.fromUserId)
				DataUtils.getGroupMsgFromUserName(msg,msg.fromUserId);
				
		}

		var contentHtml = this.createMsgContent(msg,direction,isSend);
		var html="";
		
		if(myFn.isNil(contentHtml))
			return "";
		var imgUrl=msg.imgUrl;
		//用户头像
		if(myFn.isNil(msg.imgUrl)){
			imgUrl=myFn.getAvatarUrl(WEBIM.CHAT==msg.chatType?fromUserId:msg.fromUserId);
		}
		var delayTime=msg.timeSend-DataMap.timeSendLogMap[ConversationManager.fromUserId];
		
		var timeSendStr = "";
		//||delayTime< -(60*10)
		if(delayTime>(10*60*1000)||delayTime< -(60000*10)){
				// var timeSendHtml=UI.createTimeSendLog(msg.timeSend);
				// html+=timeSendHtml;
				DataMap.timeSendLogMap[ConversationManager.fromUserId]=msg.timeSend;
				timeSendStr = getTimeText(msg.timeSend,0);
		}


		html+= "<div id=msg_"+msg.messageId+" msgType="+msg.type+" class='msgDiv' >"
            +		"<div class='clearfix'>"
			+			"<div style='overflow: hidden;' >"
			+	    		"<div  class='message " + (0 == direction ? "you" : "me")+"'>"
			+			        "<div  class='message_system'>"
			+			        	"<div  class='content'>"+timeSendStr+"</div>"
			+			        "</div>"
			+	        		"<img  class='"+ (WEBIM.isGroupChat(ConversationManager.chatType) && 0==direction ? " group_avatar":" avatar") + "' onerror='this.src=\"img/ic_avatar.png\"' src='" +imgUrl+ "' >"
			+	        		"<div class='content'>"
			//群组聊天显示昵称  (msg type = 5 表示 gif 动态图 ，若为gif消息则不添加消息气泡背景 )
			+	(WEBIM.isGroupChat(ConversationManager.chatType)&&0==direction ? "<h4  class='nickname'>" + msg.fromUserName + "</h4>" : "")
            +	            	"<div class='bubble js_message_bubble  "+ (0 == direction ?(5 == msg.type?"left'>":"bubble_default left'>"):(5 == msg.type?"right'>":"bubble_primary right'>"))  
			+	               		 "<div class='bubble_cont'>"
			+                          contentHtml
			+	               		 "</div>"
			+	            	"</div>"
			+	        	"</div>"
			+	    	"</div>"
			+		"</div>"
			+	"</div>"
       		+"</div>";


		return html;

	},
	/*type 为1  的文本消息*/
	createTextMsgContent:function(msg,direction,isSend,contentHtml,msgStatusHtml){
		var content = "";
		content=myFn.parseContent(msg.content);
		if(99<msg.type&&125>msg.type){
			content=showMsgContent(msg.type);
			content+="  <img class='dianhua' src='img/dianhua.png' onclick='Call.mic();' style='width:25px; height:25px;'> ";
		}
		contentHtml += "<div class='plain' length='"+msg.content.length+"' >";
		if(!WEBIM.isGroupChat(ConversationManager.chatType)&& 0==direction&&myFn.isReadDelMsg(msg)){
			contentHtml+= "<pre class='js_message_plain hide'>"+ content +"</pre>"
					   +  "<a href='javascript:void(0)' onclick='UI.showReadDelMsg(\""+msg.messageId+"\");' style=''> 点击查看  T</a>"
					   +  "<span id='msgReadTime_"+msg.messageId+"' class='msg_status_common read_del_time'>10</span>"
					   +"</div>";

			if(1==msg.isShow){
				setTimeout(function(){
					UI.showReadDelMsg(msg.id);
				},1000);
			}
		}else{
			contentHtml += "<pre class='js_message_plain'>"+ content +"</pre>"
								   + msgStatusHtml
								   + "</div";
		}
		return contentHtml;
	},
	createMsgContent:function(msg,direction,isSend){

			var contentHtml = "";
			
			if(myFn.isNil(msg.content)){
				return null;
			}
			msg.content=(msg.content+"").replaceAll('\n','<br/>');

			var msgStatusHtml  ="";  
			this.createMsgStatusIteam(msg,direction,isSend);
			if(99<msg.type&&125>msg.type){
				contentHtml=this.createTextMsgContent(msg,direction,isSend,contentHtml,msgStatusHtml);
				return contentHtml;
			}
			   msgStatusHtml=this.createMsgStatusIteam(msg,direction,isSend);
			switch (msg.type){

				case 1:// 文字、表情

					contentHtml=this.createTextMsgContent(msg,direction,isSend,contentHtml,msgStatusHtml);
					
				  break;

				case 2:// 图片

                   	contentHtml +=  '<div class="picture">';
				 	if("true"==msg.isReadDel ||1==msg.isReadDel){ //判断是否为阅后即焚消息
				 		contentHtml += '<img id="readDelImg" class="shade" src="' + msg.content + '" style="max-width:320px;max-height:320px;"  onclick="UI.showImgZoom(\'' + msg.content + '\',\''+msg.messageId+'\')"/>';
				 	}else{ //不是
				 		contentHtml += '<img class="msg-img" onerror="this.src=\'img/overdue.png\'" src="' + msg.content + '" onclick="UI.showImgZoom(\'' + msg.content + '\')">';
				 	}

				 		contentHtml += '</div>'
				 				    +msgStatusHtml;
				 	

				  break;

				case 3:// 语音 

					if( WEBIM.GROUPCHAT == msg.chatType && myData.isShowGroupMsgReadNum){
						contentHtml = "<p id='voiceP_"+msg.messageId+"' class='chat_content' onclick='UI.showAudio(\"" + msg.content + "\",\"" + msg.messageId + "\",\""+(myFn.isNil(msg.isReadDel)?0:msg.isReadDel)+"\");GroupManager.sendRead(\"" + msg.messageId + "\")'>"
								+     "<img id='voiceImg' src='img/voice.png' style='width:25px; height:25px;margin-top:-2.5px'> <span style='display:inline; margin-left:10px; margin-right:10px;'>"+(myFn.isNil(msg.timeLen)?"  ":msg.timeLen)+"\" </span>"
								+	  "<div id='voice_"+msg.messageId+"'></div>"
								+ "</p>"
								+msgStatusHtml;
					}else{
						contentHtml = "<p id='voiceP_"+msg.messageId+"' class='chat_content' onclick='UI.showAudio(\"" + msg.content + "\",\"" + msg.messageId + "\",\""+(myFn.isNil(msg.isReadDel)?0:msg.isReadDel)+"\")'>"
								+     "<img id='voiceImg' src='img/voice.png' style='width:25px; height:25px;margin-top:-2.5px'> <span style='display:inline; margin-left:10px; margin-right:10px;'>"+(myFn.isNil(msg.timeLen)?"  ":msg.timeLen)+"\" </span>"
								+	  "<div id='voice_"+msg.messageId+"'></div>"
								+ "</p>"
								+msgStatusHtml;
					}
					
				  break;

				case 4:// 位置


 					contentHtml = '<div class="location">'
 								+	'<a href="javascript:void(0)" onclick="showToMap(this)"'+' lng="'+msg.location_x+' "lat="'+msg.location_y+'">'
 								+		'<img alt="" class="img" src="'+BaiduMap.imgApiUrl+msg.location_y+','+msg.location_x+' ">'
 								+		'<p class="desc ng-binding">'+msg.objectId+'</p>'
 								+	'</a>'
 								+ '</div>'
 								+ msgStatusHtml;
     				break;				
				 	
				  
				case 5:// GIF 动画

					contentHtml = '<div class="emoticon">'
			                	+	'<img  class="custom_emoji msg-img"  src="./gif/'+ msg.content +'">'
			            		+ '</div>'
			            		+ msgStatusHtml;

				   break;
				case 6:// 视频

					if(WEBIM.GROUPCHAT==msg.chatType && myData.isShowGroupMsgReadNum){

						contentHtml ="<video class='video' controls  onended='UI.videoPlayEnd(\"" + msg.messageId + "\",\""+(undefined==msg.isReadDel?0:msg.isReadDel)+"\")' style='width:240px;height:240px;'>"
					  				+	"<source src='"+msg.content+"' type='video/mp4'>"
									+"</video>"
									// +"<script>plyr.setup();</script>";

					}else{

						contentHtml ="<video class='video' controls  onended='UI.videoPlayEnd(\"" + msg.messageId + "\",\""+(undefined==msg.isReadDel?0:msg.isReadDel)+"\")' style='width:240px;height:240px;'>"
				  	            	+		"<source src='"+msg.content+"' type='video/mp4'>"
					            	+"</video>"
					            	// +	"<script>plyr.setup();</script>"
					            	

					}			

				  break;
				case 7:// 音频
				 
				  break;
				case 8: // 名片

					contentHtml =	'<div class="card" onclick="UI.showUser(\''+ msg.objectId + '\')">'
				                +        '<div class="card_bd">'
				                +            '<div class="card_avatar">'
				                +                '<img class="img"  onerror=\'this.src=\"img/ic_avatar.png\"\' src=\'' + myFn.getAvatarUrl(msg.objectId) + '\' >'
				                +            '</div>'
				               	+            '<div class="info">'
				                +                '<h3 class="display_name">'+ msg.content +'</h3>'
				                +            '</div>'
				                +        '</div>'
				                +        '<div class="card_hd">'
				                +        	'<p class="">个人名片</p>'
				                +        '</div>'
				                +    '</div>'
								+ msgStatusHtml;
				  	break;
				  
				case 9:// 文件
					var fileStr="";
					var fileName="";
					if(!myFn.isNil(msg.fileName)){
						fileStr=msg.fileName.substring(msg.fileName.lastIndexOf("/")+1);
						fileName=fileStr.substring(0,fileStr.indexOf("."));
					}else{
						fileStr=msg.content.substring(msg.content.lastIndexOf("/")+1);
						fileName=fileStr.substring(0,fileStr.indexOf("."));
					}
					contentHtml = '<div class="bubble_cont primary">'
								+		'<div class="attach">'
				                +        	'<div class="attach_bd">'
				                +            	'<div class="cover">'
				                +                	'<i class="icon_file"></i>'
				                +           	'</div>'
				                +            	'<div class="cont">'
				                +                	'<p class="title">'+fileStr+'</p>'
				                +                	'<div class="opr">'
				                +                    	'<span  class="">'+myFn.parseFileSize(msg.fileSize)+'</span>'
				                +                    	'<span class="sep">  |  </span>'
				                +                   	'<a target="_blank" id="fileDown_'+msg.messageId+'" download="'+fileName+'"  filename="'+fileName+'"  href="' + msg.content+ '"  class="">下载</a>';
				   	if(1 == direction && 1==isSend ){
					    contentHtml +=						'<p id="fileProgress_'+msg.messageId+'" class="progress_bar">'
					            	+                            '<span class="progress" style="width: 0%;"></span>'
					                +                       '</p>';
					}
				     contentHtml+=                	'</div>'
				                +            	'</div>'
				                +        	'</div>'
				                +    	'</div>'
								+ '</div>'
								+ msgStatusHtml;

				  	break;
				case 10://提醒
				 	UI.showMsgLog(msg.content,msg.messageId);
				 	return;
				  break;
				case 26:// 已读回执
					DataMap.msgStatus[msg.content]  =  2; //将发送消息状态进行储存 2:已读
			 		var message = DataUtils.getMessage(msg.content);
			 		if(myFn.isNil(message))
			 			return;
			 		if(0 == direction&&myFn.isReadDelMsg(message)){
			 			/*if(1==msg.isRead)
			 				return;*/
			 			DataUtils.deleteMessage(msg.content);
			 			if(1 == message.type||2 == message.type||3 == message.type||
			 				6 == message.type){
			 				$("#msg_"+msg.content+"").remove();
			 				if(msg.fromUserId==ConversationManager.fromUserId){
			 					UI.refreshLastMsgtoMessageList();
			 					UI.showMsgLog("对方查看了你的这条阅后即焚消息");

			 				}
			 				return ;
			 			}
			 			
			 		}
			 		if(myFn.isReadDelMsg(message))
			 			DataUtils.deleteMessage(msg.content);
			 		$("#msgStu_"+msg.content+"").css("background-color" ,"#7BD286");
			 		$("#msgStu_"+msg.content+"").text("已读").show();
			 		return;
				  break;
				case 28://红包
					contentHtml = '<div onclick="UI.openRedPacket(\''+msg.objectId+'\')" class="" style="background:#ff8a2a;">'
								+		'<div class="attach" style="background:#ff8a2a;padding-top:4px">'
				                +        	'<div class="attach_bd">'
				                +            	'<div class="cover">'
				                +                	'<img src="img/ic_chat_hongbao.png">'
				                +           	'</div>'
				                +            	'<div class="cont" style="line-height:60px;">'
				                +               '<p style="color:white">'+(msg.fileName==3?"口令: ":"")+msg.content+'</p>'
				                +            	'</div>'
				                +        	'</div>'
				                +    	'</div>'
								+ '</div>'
								+ msgStatusHtml;
					break;
				 
				  	
				  break;
				case 501://同意加好友
					UI.showMsgLog(msg.content);
					UI.showNewFriends(0);
				  break;
				case 201:// 正在输入
					// ownAlert(3,"正在输入");
					$("#chatHint").empty().text("对方正在输入......");
				 	$("#chatHint").show();
					setTimeout(function () {  //过5秒后隐藏
						$("#chatHint").empty();
		        		$("#chatHint").hide();
		    		}, 5000);
					return;
				  break;
				case 80://单条图文
				 	
				  break;
				case 81://多条图文
				 
				  break;
				case 202://消息撤回
					//msg.messageId=msg.content;
					var recallHtml = "";
					if(msg.fromUserId==myData.userId){ //我自己
						recallHtml = "<div class='logContent'><span>你撤回了一条消息 ("+myFn.toDateTime(msg.timeSend)+")</span></div>";
					}else{
						recallHtml = "<div class='logContent'><span>"+msg.fromUserName+" 撤回了一条消息 ("+myFn.toDateTime(msg.timeSend)+")</span></div>";
					}
					
					
					$("#messageContainer #msg_"+msg.msgId).remove();
					$("#messageContainer").append(recallHtml);
					
				 	return;
				  break;

				default://默认 其他
				contentHtml+="<p class='plain'>";
							contentHtml+= "[web不支持 请在手机上查看]</p>";
					
			}
			if(WEBIM.isGroupChat(ConversationManager.chatType)&&msg.type>400){
				WEBIM.converGroupMsg(msg);
				if(MessageType.NEW_MEMBER==msg.type&&msg.fromUserId==WEBIM.userId&&msg.toUserId==WEBIM.userId)
					return ;
				UI.showMsgLog(msg.content,msg.messageId);
				 	return;
			}
			return contentHtml;
	},
	//生成消息状态标签 (包括：loading  送达 已读  失败重发 阅后即焚计时 群已读人数等)
	createMsgStatusIteam:function(msg,direction,isSend){

		// <span class="msg_status_common send_status ok_bg" style="">送达</span> 
		// <span class="msg_status_common send_status read_bg" style="">已读</span> 
		// <span class="msg_status_common read_del_time" style="">15</span>
		// <img  class="msg_status_common ico_loading" src="./img/loading.gif" alt=""> 
		// <i class="msg_status_common ico_fail web_wechat_message_fail ng-hide"  title="重新发送"></i>

		var  msgStatusHtml = "";

		//单聊消息
		if(!WEBIM.isGroupChat(ConversationManager.chatType)) {
				//0 == direction  表示接受到的消息       1 == direction  表示用户自己发送的消息
				msgStatusHtml += ( 0 == direction ? "" : 1==isSend ? "<span id='msgStu_"+msg.messageId+"'  class='msg_status_common send_status'></span>"
					+"<img id='msgLoad_"+msg.messageId+"' class='msg_status_common ico_loading' src='./img/loading.gif'>" :
					(true == msg.isRead ?"<span class='msg_status_common send_status read_bg'>已读</span>" :
						(1 == msg.isReadDel ? "<img class='msg_status_readDel ico_readDel' src='./img/fire.png'><span  id='msgStu_"+msg.messageId+"' class='msg_status_readDel send_status ok_bg'>送达</span>" :
							"<span  id='msgStu_"+msg.messageId+"'  class='msg_status_common send_status ok_bg' style=''>送达</span>")) );       
		   
		//群组消息
		}else{

			if (1==GroupManager.roomData.showRead) {//开启群消息已读  若为@消息强制显示
				//获取群消息已读人数
				var readNum = DBUtils.getMsgReadNum(msg.messageId);
				//0 == direction  表示接受到的消息       1 == direction  表示用户自己发送的消息
				msgStatusHtml += ( 0 == direction ? "<span id='groupMsgStu_"+msg.messageId+"' class='msg_status_common send_status ok_bg click'  onclick='GroupManager.showReadList(\"" + msg.messageId + "\")'>"+(readNum+"人")+"</span>" : 
					"<span id='groupMsgStu_"+msg.messageId+"' class='msg_status_common send_status ok_bg click' onclick='GroupManager.showReadList(\"" + msg.messageId + "\")'>"+(readNum+"人")+"</span>"
			 		+(1==isSend?"<img id='groupMsgLoad_"+msg.messageId+"' class='msg_status_common ico_loading' src='./img/loading.gif'>" : ""));
				
			}else{
			 	msgStatusHtml += (0 == direction ? "" : "<span id='groupMsgStu_"+msg.messageId+"'></span>"+(1==isSend?"<img id='groupMsgLoad_"+msg.messageId+"'  class='msg_status_common ico_loading' src='img/loading.gif'>":""));
			}
		} 
		return  msgStatusHtml;
	},
	forwardingMsg:function(msg,userIdArr){
		//转发消息
		var toUserId=null;
		for (var i = 0; i < userIdArr.length; i++) {
			toUserId=userIdArr[i];
			WEBIM.refreshMessage(msg,toUserId);
			UI.sendMsg(msg,toUserId);
			msg.isGroup=WEBIM.isGroup(toUserId);
			UI.moveFriendToTop(msg,msg.toUserId,null,0);

		}
	},
	//创建 红包详情界面
	createRedPacketDetailsHtml:function(redPacket,list){
		var html="";
		var sendName="";
		var receiveName
		if(WEBIM.isGroupChat(ConversationManager.chatType)){
			var member=Temp.members[redPacket.userId];
			if(myData.userId==GroupManager.roomData.userId&&
				!myFn.isNil(member.remarkName)){
				sendName=member.remarkName;
			}
			sendName=member.nickname;
		}
		else
			sendName=redPacket.userName;
		
		html="<p><img onerror='this.src=\"img/ic_avatar.png\"' width=35 height=35 src=\'" + myFn.getAvatarUrl(redPacket.userId) + "\'>"
				+"<span>来自"+sendName+"的红包共"+redPacket.money+"元</span></p>"
				+"<p>红包已领取"+list.length+"/"+redPacket.count+"剩余"+redPacket.over.toFixed(2)+"元</p>";
			for(var i=0;i<list.length;i++){
				if(WEBIM.isGroupChat(ConversationManager.chatType))
					receiveName=Temp.members[list[i].userId].nickname;
				else{
					if(myData.userId==list[i].userId)
						receiveName=myData.nickname;
					else{
						receiveName=DataMap.friends[list[i].userId].remarkName;
						if(myFn.isNil(receiveName))
						receiveName=list[i].userName;
					}
						
				}

				html+="<p style='border-bottom:1px solid #81999933;'>"
				+"<img onerror='this.src=\"img/ic_avatar.png\"' width=35 height=35 src=\'" + myFn.getAvatarUrl(list[i].userId) + "\'>"
				+"<span>"+receiveName+"&nbsp;&nbsp;&nbsp;&nbsp;"+myFn.toDateTime(list[i].time)+"&nbsp;&nbsp;&nbsp;&nbsp;"+list[i].money.toFixed(2)+"元</span></p>";
			}
		$("#redpacket_details").html(html);
		$("#getredpacket").modal("show");
	},
	//领取红包
	openRedPacket:function(packetId){
		$("#redpacket_details").empty();
		
		mySdk.getRedPacket(packetId,function(result){
			
			var redpacket=result.data["packet"];//红包实体
			var list="";
			list=result.data["list"];
			var num=0;
			var over;
			if(redpacket.type==1&&redpacket.userId==myData.userId&&myFn.isNil(redpacket.roomJid)){//普通红包，自己发的
				UI.createRedPacketDetailsHtml(redpacket,list);
			}else if(redpacket.type!=3){//除了口令红包
				if(result.resultCode==1){
					mySdk.openRedPacket(packetId,function(result){//收到红包的实体
						list=result.data["list"];
						redpacket=result.data["packet"];
						if(result.resultCode==1){
							UI.createRedPacketDetailsHtml(redpacket,list);
						}
					});
				}else if(result.resultCode==0){
					list=result.data["list"];
					UI.createRedPacketDetailsHtml(redpacket,list);
				}
			}else{//口令红包
				if(result.resultCode==1&&redpacket.userId!=myData.userId&&!myFn.isNil(redpacket.roomJid)){
					$("#getredpacket").modal("hide");
					var command=prompt("请输入口令","");
					if(redpacket.greetings==command){
						mySdk.openRedPacket(packetId,function(result){//收到红包的实体
							list=result.data["list"];
							redpacket=result.data["packet"];
							if(result.resultCode==1){
								UI.createRedPacketDetailsHtml(redpacket,list);
							}else{
								UI.createRedPacketDetailsHtml(redpacket,list);
							}
						});
						
					}
				}else{
					UI.createReadPacketDetailsHtml(redpacket,list);
				}
				
			}
		});
		
	},
	//selete事件
	commandRedPacket:function(){
		var vs = $('select  option:selected').val();
		if(vs==3){
			$("#spanGreetings").empty();
			$("#spanGreetings").append("口令");
		}else{
			$("#spanGreetings").empty();
			$("#spanGreetings").append("祝福语");
		}
	},
	//发送消息
	sendMsg : function(msg,toJid) {
        mySdk.getMyRoom(0,100,function(result){
            if(myFn.isNil(result)){
                // ownAlert(3,"当前没有成员信息");
                return;
            }
            for (var i = 0; i < result.length; i++) {
                var obj = result[i];
                DataMap.myRooms[obj.jid]=obj;
                DataMap.rooms[obj.id]=obj;
                if(obj.member)
                    DataMap.talkTime[obj.jid]=obj.member.talkTime;
            }
        });
		if (!myFn.isNil(DataMap.deleteRooms[ConversationManager.fromUserId]&&200>msg.type)) { 
			//判断用户是否被踢出该群
			ownAlert(3,"你已被踢出该群，无法发送消息");
			return;
		}
		msg.id=msg.messageId;
		var jid=null;
		if(myFn.isNil(toJid))
			jid=ConversationManager.fromUserId;
		else
			jid=WEBIM.getUserIdFromJid(toJid);

		if(!WEBIM.isGroup(jid)){
			UI.processSendMsg(msg,toJid);
			return;
		}
		var talkTime=DataMap.talkTime[jid];
		if(!talkTime){
			UI.processSendMsg(msg,toJid);
			return;
		}

		talkTime=Number(talkTime);
		if(0==talkTime){
			UI.processSendMsg(msg,toJid);
			return;
		}else if(0<GroupManager.roomData.talkTime&&3!=GroupManager.roomData.member.role){
			UI.processSendMsg(msg,toJid);
			return;
		}

		var serverTime=WEBIM.getServerTime();
		if(talkTime*1000>serverTime){
				 var date = new Date(talkTime* 1000);//时间戳为10位需*1000，时间戳为13位的话不需乘1000
			      var  Y = date.getFullYear() + '-';
			      var  M = (date.getMonth()+1 < 10 ? '0'+(date.getMonth()+1) : date.getMonth()+1) + '-';
			      var  D = date.getDate() + ' ';
			      var  h = date.getHours() + ':';
			      var  m = date.getMinutes() + ':';
			      var  s = date.getSeconds();
				ownAlert(2,Y+M+D+h+m+s+"之前,您被禁止发言");
				return ;
			}else if(serverTime<GroupManager.roomData.talkTime){
				ownAlert(3,"全员禁言中不能发送消息");
				return;
			}
			UI.processSendMsg(msg,toJid);
	},
	//处理发送消息
	processSendMsg:function(msg,toJid){
		var content=msg.content;

		ConversationManager.sendMsg(msg,function(){
			//接受方 为当前打开界面目标用户 才添加消息到界面
			if(ConversationManager.from==msg.toJid){
				msg.content=content;
				if(!WEBIM.isGroupChat(ConversationManager.chatType))
					
				$("#messageBody").val("");
				//其他设备的处理
				if(!WEBIM.isGroupChat(ConversationManager.chatType)&&myData.userId==msg.toUserId&&1==myData.multipleDevices){
					DeviceManager.processShowMessage(msg,1,0);
				}else{
					if(!(msg.type==2||msg.type==9)||((msg.type==2||msg.type==9)&&1==msg.forward)){ 
					    //图片type=2、文件 type=9 消息上传前已做了UI预加载，这里不再次显示UI
					    //转发的图片需要显示
						UI.showMsg(msg,myData.userId,1);
					}
				 	var isGroup=WEBIM.isGroupChat(ConversationManager.chatType)?1:0;
					if(toJid){
						isGroup=WEBIM.isGroup(WEBIM.getUserIdFromJid(toJid))?1:0;
					}

						msg.isGroup=isGroup;
						if(300>msg.type)
							UI.moveFriendToTop(msg,msg.toUserId,null,0);
				}
			}
				
		},toJid);
	},
	sendImg:function(){
		var imgUrl = $("#myFileUrl").val();
		var arr=new Array();
		arr=imgUrl.split(",");
		for(var i = 0;i<arr.length;i++){
			var msg=WEBIM.createMessage(2, arr[i]);
			UI.sendMsg(msg);
		}
	},
	sendFile:function(){
		var content = $("#myFileUrl").val();
		var arr=new Array();
		arr=content.split(",");
		var arr2=new Array();
		arr2=$("#filePath").val().split(",");
		for(var i=0;i<arr.length;i++){
			var msg=WEBIM.createMessage(9, arr[i]);
			msg.fileName=arr2[i];
			msg.fileSize=$("#filePath").attr("size");
			UI.sendMsg(msg);
		}
	},
	sendGif:function(gifName){
		$("#emojl-panel #gifList").getNiceScroll().hide(); //隐藏滚动条
		$("#emojl-panel").hide();//隐藏表情面板
		var msg = WEBIM.createMessage(5, gifName);
		UI.sendMsg(msg);
	},
	showMsg : function(msg, fromUserId, direction,isSend,isNewMsg) {
		/**
		 * direction  1 自己发送的   0 别人发送的
		 * isSend 是否 显示发送等待符
		 * isNewMsg 是否为新消息  "newMsg"表示新消息
		 */
		if(myFn.isNil(msg.content))
			return;
		if(myFn.isNil(isSend))
			isSend=1;
		else
			isSend=0==isSend?0:1;
		var itemHtml = this.createItem(msg, fromUserId, direction,isSend);
		if(myFn.isNil(itemHtml))
			return "";
		//direction==0  表示收到消息 ，然后根据坐标判断用户是否在查看聊天记录,如果是则在新消息前添加分割标识
		if(isNewMsg =="newMsg" && direction==0  && UI.getElementPos("messageEnd").y > UI.getElementPos("sendMsgScopeDiv").y+300){
			 //在新建分割线之前移除之前的分割线
			 ConversationManager.curViewUnreadNum+=1;
			if (ConversationManager.isShowUnreadCount) { //判断是否需要显示新消息未读统计
				$("#messagePanel").after('<div id="bottomUnreadCount" class="unread-bottom ng-binding" onclick="UI.scrollToBottomUnread()">'+
										'<span class="unread-bottom-icon"></span><span class="unreadNum">1</span> 条新消息</div>');
				ConversationManager.isShowUnreadCount = false;
			}else{
				 $("#bottomUnreadCount .unreadNum").text(ConversationManager.curViewUnreadNum);
			}

			if(ConversationManager.isShowNewMsgCut){
				$("#messageContainer .message_system #newMsg_tips").remove();
				$("#messageContainer").append('<div class="message_system"><div id="newMsg_tips" class="content unread-content">'+
				'<div class="line-left"></div>以下是新消息<div class="line-right"></div></div></div>');
			  	ConversationManager.isShowNewMsgCut = false;
			}
			
		}
		//将消息显示到界面		
		$("#messageContainer").append(itemHtml);
		// 滚动到底部
		setTimeout(function(){
			$("#messagePanel").nanoScroller();//刷新滚动条

			if("newMsg"==isNewMsg){
				UI.scrollToEnd("receive");//滚动到底部
			}else{
				UI.scrollToEnd();
			}
		},500);
		
	},
	showReSendImg:function(messageId){
		// $("#msgStu_"+id+"").attr("class","msgStatus msgStatusBG"); //改变背景
		if (WEBIM.isGroupChat(ConversationManager.chatType)) { //群聊
			
			$("#groupMsgLoad_"+messageId+"").after("<i id='groupMsgResend_"+messageId+"'  class='msg_status_common ico_fail web_wechat_message_fail'  onclick='UI.reSendMsg(\""+messageId+"\")'></i>");
			//移除loading
			$("#groupMsgLoad_"+messageId+"").remove();

		}else{
		// 	//消息框显示重发标志
		// 	$("#msgStu_"+messageId+"").empty();
		// 	$("#msgStu_"+messageId+"").append("<img id='resendMsg' src='img/resend.png' width='20px;' height='20px' onclick='UI.reSendMsg(\""+messageId+"\")'>");
			$("#msgLoad_"+messageId+"").after("<i id='msgResend_"+messageId+"'  class='msg_status_common ico_fail web_wechat_message_fail'  onclick='UI.reSendMsg(\""+messageId+"\")'></i>");
			//移除loading
			$("#msgLoad_"+messageId+"").remove();

			

		}
	},
	//点击消息重发
	reSendMsg:function(msgId){
		//改变UI
		if(!WEBIM.isGroupChat(ConversationManager.chatType)){
			
			$("#msgResend_"+msgId+"").after("<img id='msgLoad_"+msgId+"' class='msg_status_common ico_loading' src='./img/loading.gif'>");
			$("#msgResend_"+msgId+"").remove();
		}else{
			
			$("#groupMsgResend_"+msgId+"").after("<img id='msgLoad_"+msgId+"' class='msg_status_common ico_loading' src='./img/loading.gif'>");
			$("#groupMsgResend_"+msgId+"").remove();
		}
		//消息重发
		var msg=DataUtils.getMessage(msgId);
		if(myFn.isNil(msg))
			return;
		ConversationManager.sendMsgAfter(msg);
		ConversationManager.sendTimeoutCheck(msgId); //调用方法进行重发检测
		
	},
	showMsgLog:function(log,messageId){
		var logHtml ="<div class='logContent' >"
						+"	<span >"+log+"</span> "
						+"</div>";
		if(messageId){
			logHtml="<div id='msg_"+messageId+"' >"
			 +logHtml+ "</div>";  
		}
		$("#messageContainer").append(logHtml);
		UI.scrollToEnd();
	},
	showTimeSendLog:function(msg){
		var timeSendStr=getTimeText(msg.timeSend,1);
		UI.showMsgLog(timeSendStr);
	},
	/*
	userId 用户id
	isAdd  是否增加数量
	userIdKey  我的设备标识
	addNum 需要增加的数量
	*/
	showMsgNum :function(userId,isAdd,addNum,userIdKey){
		//显示消息数量
		if(!userIdKey)
			userIdKey=userId;
		var msgNum = DataUtils.getMsgNum(userIdKey);
		var messageNumber = DataUtils.getMsgNumCount();
		if(1==isAdd){
			if(!addNum){
				addNum=1;
			}
			if(myFn.isNil(msgNum)){
				// var i=$("#msgNum_"+userId+"  #span").html();
				// msgNum=parseInt(i);
				msgNum =0;
			}
			msgNum+=addNum;
			
			DataUtils.setMsgNum(userIdKey,msgNum) ;
			messageNumber +=addNum; //将好友发送的未读消息汇总
			DataUtils.setMsgMumCount(messageNumber);
		}
		if(0<msgNum){
			/*if(99<msgNum)
				$("#myMessagesList #msgNum_"+userId+"").html("99+");
			else
				$("#myMessagesList #msgNum_"+userId+"").html(msgNum);*/
			$("#myMessagesList #msgNum_"+userId+"").html(msgNum);
			$("#myMessagesList #msgNum_"+userId).removeClass("msgNumHide");
			$("#myMessagesList #msgNum_"+userId).addClass("msgNumShow");
			
		}
	
		// ConversationManager.changMessageNum(0,messageNumber);
		UI.setUIMsgNumCount(messageNumber);

		
		/*if("NewFriend"==Temp.nowList&&10001==userId)
			UI.showNewFriends(0);*/
	},
	clearMsgNum:function(userId,userIdKey){
		if(!userIdKey)
			userIdKey=userId;
		var msgNum = DataUtils.getMsgNum(userIdKey);
		if(myFn.isNil(msgNum))
			msgNum = 0;
		var messageNumber=DataUtils.getMsgNumCount();
		messageNumber-=msgNum; //将已读的消息数从未读消息汇总数中减去
		DataUtils.setMsgNum(userIdKey,0);
		DataUtils.setMsgMumCount(messageNumber);

		UI.setUIMsgNumCount(messageNumber);

		
		$("#myMessagesList #msgNum_"+userId).html(0);
		
		$("#myMessagesList #msgNum_"+userId).removeClass("msgNumShow");
		$("#myMessagesList #msgNum_"+userId).addClass("msgNumHide");
		
		
		
	},
	showReadDelMsg:function(messageId){
		var msg=DataUtils.getMessage(messageId);
		if(!msg)
			return;
		$("#msg_"+messageId+" a").remove();
		$("#msg_"+messageId+" .js_message_plain").removeClass("hide");
		var length=$("#msg_"+messageId+" .plain").attr("length");
		var timeOut=null;
		var count=0;
		
		count=parseInt(length)/10;
		count=count<1?10:count*10;
		shikuLog("==========> showReadDelMsg  length > "+length+" count > "+count);
		
		shikuLog("==========> showReadDelMsg  count > "+count);
		$("#msgReadTime_"+messageId).html(count);
		//点击查看发送已读回执
		if(1!=msg.sendReceipt){
			ConversationManager.sendReadReceipt(ConversationManager.from, messageId,1); 
		}
		/*发送已读回执标记*/
		msg.sendReceipt=1;

		msg.isShow=1;
		//msg.count=count;
		DataUtils.saveMessage(msg);
		timeOut= setInterval(function(){
			var msg=DataUtils.getMessage(messageId);
			if(msg.fromUserId!=ConversationManager.fromUserId){
				clearInterval(timeOut);
				return;
			}
			count=count-1;
		/*	msg.count=count;
			DataUtils.saveMessage(msg);*/
			if(count>0){
				$("#msgReadTime_"+messageId).html(count);
			}
			else{
				ConversationManager.sendReadReceipt(ConversationManager.from, messageId,1); //发送已读回执

				clearInterval(timeOut);
				$("#msg_"+messageId).remove();
				UI.refreshLastMsgtoMessageList();
			  if((3!=msg.type&&6!=msg.type)){
			  	/*删除本地缓存消息*/
				DataUtils.deleteMessage(messageId);
			  }

			}
		},1000,messageId,timeOut,count);
	},
	showImgZoom : function(src,messageId) {

		var maxWidth = (undefined!=document.body.clientWidth)?document.body.clientWidth-100:800;
		var maxHeight = (undefined!=document.body.clientHeight)?document.body.clientHeight-80:700;
     	if(Temp.msgImgLayerOpen){
    		return;
    	}
       	$("#imgZoom_div").append("<img src="+src+" class='imgZoom_img' style='max-width:"+maxWidth+"px; max-height:"+maxHeight+"px;'/>");

        //弹出层
		layer.open({
            type: 1,
            title: false,
            btn:false,
            shade:0.6,
            closeBtn: 0,
            skin: 'layui-layer-nobg',//去掉背景
            shadeClose: true, //点击外围关闭弹窗
            scrollbar: false, //不现实滚动条
            maxWidth : maxWidth,
            maxHeight : maxHeight,
            //area:  ['auto', 'auto'],
            content: $("#imgZoom_div"),//自定义 html 内容，注意这里的整个 html 内容背景肯定是透明的
            success: function(layero, index){
            	Temp.msgImgLayerOpen = true;
            },
            end: function(){
            	$("#imgZoom_div").empty().hide();
            	Temp.msgImgLayerOpen = false;
            	return false;
            },
            cancel: function(index, layero){

				layer.close(index)
				$("#imgZoom_div").empty().hide();
				Temp.msgImgLayerOpen = false;
				return false;
			},
        });





     	if(!myFn.isNil(messageId)){ //阅后即焚消息
     		var msg=DataUtils.getMessage(messageId);
     		if(myData.userId==msg.fromUserId)
     			return;
     		ConversationManager.sendReadReceipt(ConversationManager.from, messageId,1);
     		if(!myFn.isNil(msg))
     			mySdk.deleteFile(msg.content);
			$("#messageContainer #msg_"+messageId).remove();
			//$("#messageContainer #msg_"+messageId+" #chat_content").append("<img src='img/delete.gif'  style='max-width:100%;'/>");

			//将此条阅后即焚消息从缓存消息中删除
			myFn.deleteReadDelMsg(messageId);
		}

	},
	videoPlayEnd : function(messageId,readDel) { //视频播放结束后执行
		if(readDel=="true" || readDel==1){ //判断是否为阅后即焚消息
			//播放结束后显示阅后即焚图片
			$("#messageContainer #msg_"+messageId+"").remove();
			var msg=DataUtils.getMessage(messageId);
			ConversationManager.sendReadReceipt(ConversationManager.from, messageId,1);
     		if(!myFn.isNil(msg))
     			mySdk.deleteFile(msg.content);
			//$("#messageContainer #vidoePlay_"+messageId+"").empty().append("<img src='img/delete.gif' style='width:180px;'>");
			//将此条阅后即焚消息从缓存消息中删除
			myFn.deleteReadDelMsg(messageId);
		}
		
	},
	showAudio : function(videoUrl,messageId,readDel) {
		var type=videoUrl.substr(videoUrl.lastIndexOf('.')+1,videoUrl.length);
		if("amr"==type){
			var url=AppConfig.uploadUrl.substr(0,AppConfig.uploadUrl.lastIndexOf('/'))+"/amrToMp3";
			var data=WEBIM.createOpenApiSecret();
			data.paths=videoUrl;
			
			$.ajax({
				type:"POST",
				url:url,
				jsonp:"callback",
				data:data,
				success : function(result) {
					//if (1 == result.resultCode) {
						var res = eval("(" + result + ")");
						videoUrl=res.data[0].oUrl;
						UI.showAudioInUrl(videoUrl,messageId,readDel);
					//}
				},
				error : function(result) {
					
				}
			});
				
		}else if("wav"==type){
			// videoUrl = videoUrl.substr(0, videoUrl.lastIndexOf('.')) + ".mp3";
			UI.showAudioInUrl(videoUrl,messageId,readDel);
		}else{	
			videoUrl = videoUrl.substr(0, videoUrl.lastIndexOf('.')) + ".mp3";
			UI.showAudioInUrl(videoUrl,messageId,readDel);
			// videoUrl =
			// "http://96.f.1ting.com/56401610/e02941274d5babb817f2abcf5f6d0220/zzzzzmp3/2009fJun/10/10gongyue/02.mp3";
			
		}
	},
	//根据url 开始播放语音
	showAudioInUrl:function(videoUrl,msgId,readDel){
		//将页面上的语音消息都恢复成静态图片
		$("#messageContainer #voiceImg").attr("src","img/voice.png");

		//ownAlert(3,"开始播放语音");
		
		var voiceHtml = '<audio id="audio" autoplay="autoplay">'
					  +		'<source src="'+videoUrl+'" type="audio/mpeg"/>'
					  +'</audio>'
		$("#messageContainer #voice_"+msgId+"").empty().append(voiceHtml);
		//显示播放的gif图
		$("#messageContainer #voiceP_"+msgId+" #voiceImg").attr("src","img/voice.gif");

		//播放结束后恢复
		$("#messageContainer #voice_"+msgId+" #audio").bind('ended',function () {
			if(readDel=="true" || readDel==1 ){ //判断是否为阅后即焚消息
				$("#messageContainer #msg_"+msgId+"").remove();
				var msg=DataUtils.getMessage(msgId);
     		if(!myFn.isNil(msg))
     			ConversationManager.sendReadReceipt(ConversationManager.from, msgId,1);
     			mySdk.deleteFile(msg.content);
				setTimeout(function(){
					UI.scrollToEnd();
				},400);

				//将此条阅后即焚消息从缓存消息中删除
				myFn.deleteReadDelMsg(msgId);

			}else{ // 不是阅后即焚 则恢复为静态图片
				$("#messageContainer #voiceP_"+msgId+" #voiceImg").attr("src","img/voice.png");
			} 
			
			
		});
		// setTimeout(function(){
		// 		$("#messageContainer #voiceP_"+msgId+" #voiceImg").attr("src","img/voice.gif");
		// },timeLen*1000);

	},
	deleteMsg:function(type,del,msgId,roomJid,refreshUI,callback){
		//删除消息
		mySdk.deleteMsg(type,del,msgId,function(){
			//上一条消息的Id
			$("#messageContainer #msg_"+msgId).remove();
			if(refreshUI){
				UI.refreshLastMsgtoMessageList();
			}
			if(callback)
				callback();
		},roomJid);       
	},
	//消息面板滚动到底部  type ：类型分为发送和接收两种
	scrollToEnd : function(type) {

		if(type=="receive" && UI.getElementPos("messageEnd").y> UI.getElementPos("sendMsgScopeDiv").y+300){  //类型为接收
  			//根据坐标判断用户是否在浏览历史消息
		    return;
		}
		$("#bottomUnreadCount").remove();
		//document.getElementById("messageEnd").scrollIntoView();
		$("#messagePanel").nanoScroller({ scrollBottom: -100000000000});
	},
	createFriendsItem : function(imgUrl, userId, nickname,content,timeSend,timeSendStr) {
		//timeSend  发送时间值
		//timeSendStr 发送时间转换字符串
	  if(10000==userId)
		return"";

      var _item =  "<div  class='' id='friends_"+userId+"' onclick='UI.isChoose(\"" + userId + "\");'>"
			    +    "<div class='chat_item slide-left  active' onclick='ConversationManager.open(\"" + userId + "\",\"" + nickname + "\");' >"
			    +        "<div class='avatar'>"
			    +            "<img onerror='this.src=\"img/ic_avatar.png\"' class='img roundAvatar' src="+ imgUrl + " alt=''>"
			    +            "<i id='msgNum_"+userId+"' class='icon web_wechat_reddot_middle'>"+ 1+"</i>"
			    +        "</div>"
			    +        "<div class='info'>"
			    +            "<div class='nickname'>"
			    +                "<span class='nickname_text'>"+nickname+"</span>"
			    +				 (myFn.isNil(timeSendStr)?"<span id='timeSend_"+userId+"' class='timeStr'></span>" : "<span id='timeSend_"+userId+"' class='timeStr' value='"+timeSend+"'>"+timeSendStr+"</span>")
			    +            "</div>"
			    +            "<p class='msg'>"
			    +                "<span id='titfriends_"+userId+"'>" +content+"</span>"
			    +            "</p>"
			    +        "</div>"
			    +    "</div>"
			    +"</div>";


		return _item;
	},
	createSysFriendsItem : function() {
		//系统消息
		var	_item = "<div class='' id='friends_"+10000+"' onclick='UI.isChoose(\"" + 10000 + "\");' style='border-bottom:1px solid #EEF0F5'>" 
					+	"<div class='media-main' onclick='UI.showUser(" + 10000+");'>"
					+      "<a href='javascript:UI.showUser(" + 10000 + ")' class='pull-left media-avatar'>"
					+                 "<img onerror='this.src=\"img/ic_avatar.png\"' width='40' height='40' alt='' src=\"img/im_10000.png\"' class='roundAvatar'>"
				    +      "</a>"
				    +      "<div onclick='ConversationManager.open(\"" +10000 + "\", \"系统客服\");' style='cursor: pointer;' class='media-body'>"
				    +         "<h5 class='media-heading'>" + "系统客服" + "</h5>"
				    +	" <span id='timeSend_"+10000 +"' class='timeSend' value='"+timeSend+"' >" + timeSendStr + "</span>"
				    +"       <div id='msgNum_"+10000+"' class='news' style='float:right;display:none'><span style='background-color: #FA6A43;border-radius: 12px;padding:0 4px;color:white'>"
				    +"1</span></div>"
				    +         "<div class='text-length msgListTitle id='titfriends_"+10000+" '>" +  "系统消息" + "</div>"
				    +      "</div>"
				    +   "</div>"
				    +"</div>";

				 //新朋友
		 _item+= "<div class='' id='friends_"+10001+"' onclick='UI.isChoose(\"" + 10001 + "\");' style='border-bottom:1px solid #EEF0F5'>" 
					+	"<div class='media-main' onclick='UI.showNewFriends(" + 0+");'>"
					+      "<a href='javascript:(0)' class='pull-left media-avatar'>"
					+                 "<img onerror='this.src=\"img/ic_avatar.png\"' width='40' height='40' alt='' src=\"img/im_10001.png\"' class='roundAvatar'>"
				    +      "</a>"
				    +      "<div style='cursor: pointer;' class='media-body'>"
				    +         "<h5 class='media-heading'>" + "新的朋友" + "</h5><div id='msgNum_"+10001+"' class='news' style='float:right;display:none'><span style='background-color: #FA6A43;border-radius: 12px;padding:0 4px;color:white'>"
				    +1+"</span></div>"
				    +         "<div class='media-desc'>" +  "好友验证消息" + "</div>"
				    +      "</div>"
				    +   "</div>"
				    +"</div>";
		return _item;
	},
	createNewFriendsItem : function(obj) {

		var _item = "<div class='newFriend_item'>"
				  +		"<div class='media-avatar' onclick='javascript:UI.showUser(" + obj.toUserId + ")' style='margin-left:10px; float:left'>"
				  +			"<img onerror='this.src=\"img/ic_avatar.png\"' style='width:40px;' src='"+myFn.getAvatarUrl(obj.toUserId)+"' class='roundAvatar'>"
				  +		"</div>"
				  +		"<div class='newFriend_body'>"
				  +			"<div class='newFriend_nickname'>"+myFn.getText(obj.toNickname)+"</div>";

				if(0==obj.direction){
					
						/*我发送的*/
						if(500==obj.type){
							// _item=_item+"<div  colspan='3' style='color:#7E7979'>"
								// +"等待对方验证&nbsp;&nbsp;&nbsp;&nbsp;"+obj.content+"</div>";
							_item += "<div class='newFriend_msgContent'>等待对方验证中</div></div>";
								
						}else if(502==obj.type){
							 _item += "<div class='newFriend_msgContent'>"+obj.content+"</div></div>"
							 	   +"<div class='newFriend_option'>";
							 if(myData.userId!=obj.from){
								_item += "<button onclick='UI.acceptFriends(" + obj.toUserId + ")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>同意</button>";
							 }

							_item += "<button onclick='UI.showReplySeeHai(" + obj.toUserId + ")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>回复</button>"
							 	  +"</div>";

						}else if(503==obj.type){
							
							_item += "<div class='newFriend_msgContent'>等待对方验证</div></div>";
							
						}else if(504==obj.type){

							_item += "<div class='newFriend_msgContent'>已取消好友</div></div>";

						}else if(505==obj.type){

							

							_item +=  "<div class='newFriend_msgContent'>已删除</div>"
							      +"</div>"
								  +"<div class='newFriend_option'>"
								  +   "<button onclick='UI.addFriends("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>加好友</button>"
								  +"</div>";
							
						}else if(507==obj.type){
							
							_item +=  "<div class='newFriend_msgContent'>已拉黑</div>"
							      +"</div>"
								  +"<div class='newFriend_option'>"
								  +   "<button onclick='mySdk.deleteBlacklist("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>移除黑名单</button>"
								  +"</div>";
						}else {
							// _item=_item+"<div style='color:#7E7979'>已互为好友 </div>";
							_item += "<div class='newFriend_msgContent'>已互为好友</div></div>";
						}
					
								
				}else {
					/*接受到的*/
					
						if(500==obj.type){

						 _item +=  "<div class='newFriend_msgContent'>"+obj.content+"</div>"
						       +"</div>"
							   +"<div class='newFriend_option'>"
							   +   "<button onclick='UI.acceptFriends("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>同意</button>"
							   +   "<button onclick='UI.showReplySeeHai("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>回复</button>"
							   +"</div>";

								
						}else if(502==obj.type){

							 _item += "<div class='newFriend_msgContent'>"+obj.content+"</div>"
							 	   +"</div>"
							       +"<div class='newFriend_option'>";
							 if(myData.userId!=obj.from){
								_item += "<button onclick='UI.acceptFriends("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>同意</button>";
							 }
							 _item+="<button onclick='UI.showReplySeeHai("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>回复</button>"
							      +"</div>";

						}else if(503==obj.type){

						
							_item +=  "<div class='newFriend_msgContent'>申请加我为好友</div>"
						       	  +"</div>"
							      +"<div class='newFriend_option'>"
							      +   "<button onclick='UI.acceptFriends("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>加好友</button>"
							      +"</div>";
							
						}else if(504==obj.type||505==obj.type){

							_item +=  "<div class='newFriend_msgContent'>被取消了好友</div>"
						       	  +"</div>"
							      +"<div class='newFriend_option'>"
							      +   "<button onclick='UI.addFriends("+obj.toUserId+")' class='layui-btn layui-btn-normal layui-btn-radius newFriend_button'>加好友</button>"
							      +"</div>";
							
						}else if(507==obj.type){
							_item += "<div class='newFriend_msgContent'>已被拉黑</div></div>";
							
						}else {
							_item += "<div class='newFriend_msgContent'>已互为好友</div></div>";
						}
						
				}

			_item+="</div>";
				
		
		return _item;
	},
	friendRemarkName(userId){
		Temp.updateNameType="friendRemarkName";
		var friend=DataMap.friends[userId];
		$("#myModalLabel").html("修改好友备注");
		if(!myFn.isNil(friend.remarkName))
			$("#newNickname").val(friend.remarkName);
		else
			$("#newNickname").val("");
		$("#updategname").modal("show");
	},
	msgWithFriend:function(msg){
		//处理 接受到的 好友验证类型消息
		
			/*if(501==msg.type){
				UI.showFriends(0);
				UI.showNewFriends(0);
			}else*/ 
			if(504==msg.type||505==msg.type||507==msg.type){
				if(myData.userId==msg.fromUserId&&507==msg.type)
					DataMap.blackListUIds[msg.toUserId]=msg.toUserId;

				if(msg.fromUserId==myData.userId){
					if(ConversationManager.fromUserId==msg.toUserId){
						UI.hideChatBodyAndDetails();
						UI.clearMsgNum(msg.toUserId);
						$("#myMessagesList #friends_"+msg.toUserId).remove();
						DataUtils.removeUIMessageList(msg.toUserId);
						DataUtils.deleteFriend(msg.toUserId);
					}
					DataMap.allFriendsUIds[msg.toUserId]=null;
				}else {
					if(ConversationManager.fromUserId==msg.fromUserId){
						UI.hideChatBodyAndDetails();
					}
					UI.clearMsgNum(msg.fromUserId);
					$("#myMessagesList #friends_"+msg.fromUserId).remove();
					DataUtils.removeUIMessageList(msg.fromUserId);
					DataMap.allFriendsUIds[msg.fromUserId]=null;
					DataUtils.deleteFriend(msg.fromUserId);
				}
				UI.showFriends(0);
				// UI.createNewFriendsItem();
			}else if(501==msg.type||508==msg.type){
				var friendId=null;
				if(msg.fromUserId==myData.userId){
					DataMap.allFriendsUIds[msg.toUserId]=msg.toUserId;
					friendId=msg.toUserId;
				}else{
					DataMap.allFriendsUIds[msg.fromUserId]=msg.fromUserId;
					friendId=msg.fromUserId;
				}
				var message=WEBIM.createMessage(1,"已成为好友,我们开始聊天吧",friendId);
				UI.moveFriendToTop(message,friendId,null,1,1);
				//UI.showFriends(0);
			}else if(509==msg.type){
				if(myData.userId==msg.fromUserId)
					delete DataMap.blackListUIds[msg.toUserId];
			}else{
				UI.showFriends(0);
			}

	},
	showMessages : function(){
		$("#charMessage").empty();
		$("#charMessage").append("聊天消息");
		$("#o").show();
		
		$("#messagemyFriend").show();
		$("#deviceList").hide();
		$("#tabCon_new").hide();
		$("#back").hide();
		$("#prop").hide();
		/*$("#friends_10000").show();
		$("#friends_10001").show();*/
		$("#myMessagesList").show();
		$("#myMessagesList div").removeClass("fActive");
		$("#list").remove();

	   //UI.hideChatBodyAndDetails();
		$("#setPassword").hide();
		$("#privacy").hide();
		
		UI.updateMessageListTimeSendStr();

	},
	/*showFriends_old : function(pageIndex) {
		$("#back").hide();
		$("#add_friend").show();
		$("#o").show();
		$("#btnFooter").show();
		$("#roomTab").hide();
		$("#prop").hide();
		$("#friendsTabTitle").html("我的好友");
		$("#setPassword").hide();
		$("#privacy").hide();

		$("#search_all_user").bind("input propertychange",function(){
			UI.showNearbyUser(0);
		});

		if(myFn.isNil(pageIndex))
			pageIndex=0;
		$("#myFriendsList").hide();
		$("#myNearUserList").hide();
		mySdk.getFriendsList(myData.userId, null, 2, pageIndex, function(result) {

			//储存好友列表当前页码数，及当前页的好友数量
			myData.friendListPage = pageIndex;
			myData.friendListNum = result.pageData.length;
			//清空已记录的当前页中所有好友的userId
			myData.friendListUserIds=[];

			var html = "";
			if(pageIndex==0){
				html+='<div  class="" id="friends_10001" onclick="UI.isChoose(10001);">'
					+	'<div class="chat_item slide-left active" onclick="UI.showNewFriends(0);" >'
					+		'<div class="ext"> <p class="attr"></p> </div>'
					+		'<div class="avatar">'
					+			'<img class="img roundAvatar" src="img/im_10001.png" alt="">'
					+			'<i id="msgNum_10001" class="icon web_wechat_reddot_middle">1</i>'
					+		 '</div>'
					+		 '<div class="info">'
					+			  '<h3 class="nickname">'
					+				   '<span class="nickname_text">新的朋友</span>'
					+			   '</h3>'
					+			   '<p class="msg">'
					+				    '<span style="color:#3a3f45">新朋友消息</span>'
					+			   '</p>'
					+		 '</div>'
					+	'</div>'
					+'</div>';
			}
			for (var i = 0; i < result.pageData.length; i++) {
				var obj = result.pageData[i];
				//缓存好友
				DataMap.friends[obj.toUserId]=obj;
				//自己和黑名单好友不显示
				//被拉黑好友不显示
				if(myData.userId==obj.toUserId||1==obj.blacklist||1==obj.isBeenBlack)
					continue;
				//记录当前页中所有好友的userId
				myData.friendListUserIds.push(obj.toUserId);

				var imgUrl = myFn.getAvatarUrl(obj.toUserId);
				html += UI.createFriendsItem(imgUrl, obj.toUserId,myFn.isNil(obj.remarkName)?obj.toNickname:obj.remarkName, '暂无签名');
				// tbFriendsListHtml += "<tr><td><img src='" + imgUrl + "' width=30 height=30 /></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + obj.toNickname
				// 		+ "</td><td><input id='userId' name='userId' type='checkbox' value='" + obj.toUserId + "' /></td></tr>";
			}
			if(myFn.isNil(html)){
				return;
			}
			html="<table width='100%'>"+html + "</table>"

			html += GroupManager.createPager(pageIndex, result.pageCount, 'UI.showFriends',9);
			$("#myFriendsList").empty();
			$("#myFriendsList").append(html);
			$("#myFriendsList").show();
			
			$("#btnAttentionList").removeClass("border");
			$("#btnMyFriends").addClass("border");

			if(1==myData.multipleDevices&&0==pageIndex){
				DeviceManager.initMyDevices();
			}

		});
	}, */
	showFriends : function(pageIndex,type) {
		$("#back").hide();
		$("#add_friend").show();
		$("#o").show();
		$("#btnFooter").show();
		$("#roomTab").hide();
		$("#prop").hide();
		$("#friendsTabTitle").html("我的好友");
		$("#setPassword").hide();
		$("#privacy").hide();

		$("#blackList").hide();

		$("#deviceList").remove();

		$("#search_all_user").bind("input propertychange",function(){
			UI.showNearbyUser(0);
		});

		$("#myNearUserList").hide();

		$("#myFriendsList").show();

		$("#btnMyFriends").addClass("border");
		$("#btnAttentionList").removeClass("border");

		if(1==type) //type = 1, 只做UI切换,不加载数据
			return;

		layui.flow.load({
			    elem: '#myFriendsList' //流加载容器
			    ,end: "<span style='font-size: 10px;color: #b4afaf;'>没有更多了</span>"
			    ,isAuto:false
			    ,done: function(page, next){ //执行下一页的回调
			      	
			    	if( myFn.isNil($("#myFriendsList #friends_MyDevice").prop("outerHTML")) &&
			    				 1==myData.multipleDevices && 1==page ){
							DeviceManager.initMyDevices();
					}
			        
			        mySdk.getFriendsList(myData.userId, null, 2, page-1, function(result) {
			      		
			      		var lis = [];

			      		console.log("showFriends ===========>>  page : "+page);
				      	//清空已记录的当前页中所有好友的userId
						myData.friendListUserIds=[];

				      	var html = "";
				      	for (var i = 0; i < result.pageData.length; i++) {
							var obj = result.pageData[i];
							//缓存好友
							DataMap.friends[obj.toUserId]=obj;
							//自己和黑名单好友不显示,被拉黑好友不显示
							if(myData.userId==obj.toUserId||1==obj.blacklist||1==obj.isBeenBlack)
								continue;
							//记录当前页中所有好友的userId
							myData.friendListUserIds.push(obj.toUserId);

							var imgUrl = myFn.getAvatarUrl(obj.toUserId);
							html = UI.createFriendsItem(imgUrl, obj.toUserId,myFn.isNil(obj.remarkName)?obj.toNickname:obj.remarkName, '暂无签名');
							if(!myFn.isNil(html))
								lis.push(html+'');
						}

						//首页,返回的数据为10条及以上作则显示加载更多  //非首页返回数据大于0条则显示加载更多
						var isEnd = ( page==1 && result.pageData.length>=10 ) ||  ( page>1 && result.pageData.length>0 );

						next(lis.join(''),isEnd);
			        });

			    }
		});

		
	}, 
	handoverImg : function(that){ //切换图标 和背景

		var otherPId = ["friend","messages","room","company","mydata","privacySet","pswmanage","liveP"];

		//切换背景操作
		var thisId = $(that).attr('id');
		//更改自己的背景
		$("#"+thisId+"").addClass("back");
		$("#"+thisId+"").removeClass("left_title_old");
		$("#"+thisId+"").addClass("left_title");
		//将其它兄弟的背景还原
		for (var j = 0; j < otherPId.length; j++) {
			if (thisId == otherPId[j] ) {
				continue;
			}
			$("#"+otherPId[j]+"").removeClass("back");
			$("#"+otherPId[j]+"").addClass("left_title_old");
			$("#"+otherPId[j]+"").removeClass("left_title");
		}

		Temp.leftTitle=thisId;
		var msgCount=DataUtils.getMsgNumCount();
		//切换图标操作
		// var imgId =$(that.children[0]).attr('id');
		switch(thisId){
			case "friend":
				$("#"+thisId+" #friendImg").attr("src","img/friendImg.png");
				break;
			case "messages":
				$("#"+thisId+" #messageImg").attr("src","img/messageImg.png");
				break;
			case "room":
				$("#"+thisId+" #roomImg").attr("src","img/roomImg.png");
				break;
			case "company":
				$("#"+thisId+" #compImg").attr("src","img/compImg.png");
				break;
			case "liveP":
				$("#"+thisId+" #live").attr("src","img/live.png");
				break;
			default:
				break;
		}
		
		/**更改自己的图标，将其它兄弟的图标还原*/
		//所有 img 的Id
		var otherImgId = ["friend","messages","room","company","myProfile","privacy","password","liveP"];
		for (var i = 0; i < otherImgId.length; i++) {
			var oImgId = otherImgId[i];
			if(thisId == oImgId){
				continue;
			}
			switch(oImgId){
				case "friend":
					$("#"+oImgId+" #friendImg").attr("src","img/friendImg2.png");
					break;
				case "messages":
					$("#"+oImgId+" #messageImg").attr("src","img/messageImg2.png");
					break;
				case "room":
					$("#"+oImgId+" #roomImg").attr("src","img/roomImg2.png");
					break;
				case "company":
					$("#"+oImgId+" #compImg").attr("src","img/compImg2.png");
					break;
				case "liveP":
					$("#"+oImgId+" #live").attr("src","img/live2.png");
					break;
				default:
					break;
			}
		}

	},
	showAddFriendList : function(pageIndex){
		mySdk.getFriendsList(myData.userId, null, 2, pageIndex, function(result) {
			var userIds = Checkbox.parseData();//调用方法解析数据
			var tbFriendsListHtml = "<tbody>";
			var obj=null;
			var imgUrl=null;
			for (var i = 0; i < result.pageData.length; i++) {
				obj = result.pageData[i];

				//解决bug 8088 公众号不能进群问题
				if (6==obj.fromAddType){
					continue;
				}

				if(10000==obj.toUserId){
					continue;
				}
				imgUrl = myFn.getAvatarUrl(obj.toUserId);
				//这里的Id createGroupShow 表示已选展示区的id
				var inputHtml = "<input id='createGroupShow' name='userId' type='checkbox' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
				
				if(0 != userIds.length){
					for (var j = 0; j < userIds.length; j++) {
						var userId = userIds[j];

						if(obj.toUserId == userId){
							//$("#input_"+obj.toUserId+"").attr("checked",'checked'); 
							inputHtml = "<input id='createGroupShow' name='userId' type='checkbox' value='" + obj.toUserId + "' checked='checked' onclick='Checkbox.checkedAndCancel(this)'/>" 
						}
					}
				}
				tbFriendsListHtml += "<tr><td style='padding: 5px;'>"
				                  +     "<img onerror='this.src=\"img/ic_avatar.png\"'  src='" + imgUrl + "' width=30 height=30 class='roundAvatar' /></td>"
				                  +     "<td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + myFn.getText(obj.toNickname)  + "</td>"
				                  +     "<td>"
				                  +     inputHtml  
				                  +     "</td>"
				                  +  "</tr>";
			}
			tbFriendsListHtml += "</tbody>";
			var pageHtml = GroupManager.createPager(pageIndex, result.pageCount, 'UI.showAddFriendList',result.pageData.length);
			$("#tbFriendsList").empty();
			$("#friends_page").empty();
			$("#tbFriendsList").append(tbFriendsListHtml);
			$("#friends_page").append(pageHtml);

		});
	},
	showNearbyUser : function(pageIndex) {
		myFn.invoke({
			url : '/nearby/nearbyUserWeb',
			data : {
                pageIndex : pageIndex,
				pageSize : 10,
				nickname : $("#search_all_user").val()
			},
			isShowAlert:false, //不显示弹框
			success : function(result) {
				if (1 == result.resultCode && !myFn.isNil(result.data)) {
					var html = "<div id='nearbyUserList' >";
					var obj=null;
					for (var i = 0; i < result.data.pageData.length; i++) {
						obj = result.data.pageData[i];
						if(myData.userId==obj.userId)
							continue;
						DataMap.userMap[obj.userId]=obj;
						
						html+= "<div class='' id='nearUser_"+obj.userId+"'>"
							+		"<div class='chat_item slide-left  active'>"
							+			"<div class='avatar'>"
							+				 "<img onerror='this.src=\"img/ic_avatar.png\"' class='img roundAvatar' src='"+ myFn.getAvatarUrl(obj.userId) + "'>"
							+			"</div>"
							+			"<div class='info' style='width: 190px;'>"
							+				"<div class='nickname'>"
							+					"<span class='nickname_text'>"+obj.nickname+"</span>"
							+					"<img class='sex_icon' src='"+(1==obj.sex?'./img/man.png':'./img/woman.png')+"'>"
							+				"</div>"
							+				"<p class='msg'>"
							+					"<span>" +(myFn.isNil(obj.desc) ? "暂无签名" :  myFn.getText(obj.desc))+"</span>"
							+				"</p>"
							+			"</div>"
							+			"<div class='ext'>";
							if (obj.userId!=DataMap.allFriendsUIds[obj.userId]&&myFn.isNil(DataMap.allFriendsUIds[obj.userId]) ){
								html+=	   "<button title='加为好友' class='btn_addFriend'  onclick='UI.addFriends("+obj.userId+",event)'>"
								 	+			"<img  style='height:20px; width:18px;'  src='img/addFriend.png'>"
							     	+		"</button>";
						    }
							html+=		"</div>"
							+		"</div>"
							+	"</div>";

					}

					html += GroupManager.createPager(pageIndex, result.data.pageCount, 'UI.showNearbyUser');
					
					$("#_myNearUserList").empty();
					$("#_myNearUserList").append(html);
					
					$("#addfriend").modal("show");
					
				}else{
					$("#_myNearUserList").empty();
					$("#addfriend").modal("show");
				} 
			},
			error : function(result) {
			}
		});
	},
	addFriends : function(toUserId,ev) {
		if(!myFn.isNil(ev)){
			ev.stopPropagation(); //阻止事件向父元素冒泡
		}

		mySdk.getUser(toUserId,function(user){

			var friend=user.friends;
				if(!myFn.isNil(friend)&&1==friend.isBeenBlack){
					ownAlert(3,"已被对方拉黑 不能加好友!");
					return;
				}else if(1==user.settings.friendsVerify){
					//好友需要验证
					UI.showSeeHai(user.userId);
					return;
				}

				mySdk.addFriends(toUserId,function(result){
					//关注成功 已互为好友
						$("#addfriend").modal('hide');
						$("#divNewFriendList").hide();
						
							UI.showFriends(0);
							friendRelation[toUserId] = true;
						
						//关注成功后将数据储存到好友和单向关注userId 列表中
						DataMap.allFriendsUIds[toUserId] = toUserId;
						
						UI.showMessages();
						/*var imgUrl =myFn.getAvatarUrl(user.userId);
						friendHtml = UI.createFriendsItem(imgUrl, user.userId, user.nickname, user.description);
						$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
						UI.isChoose(user.userId);
						UI.showMsgNum(toUserId);*/

						ConversationManager.open(user.userId ,user.nickname);

						var msg=WEBIM.createMessage(1,"你们已互为好友，请开始聊天吧");
						msg.fromUserId=toUserId;
							
				},user.nickname);			
						
		},1);

		

	},
	/*同意加好友*/
	acceptFriends:function(toUserId,ev){
		if(!myFn.isNil(ev)){
			ev.stopPropagation(); //阻止事件向父元素冒泡
		}

		mySdk.getUser(toUserId,function(user){
			if(!myFn.isNil(user.friends)&&2==user.friends.status){
				layui.layer.msg("已经是好友了");
				return;
			}
			mySdk.addFriends(toUserId,function(result){
				//关注成功 已互为好友
				$("#addfriend").modal('hide');
				$("#divNewFriendList").hide();
			
				UI.showFriends(0);
				friendRelation[toUserId] = true;
				
				//关注成功后将数据储存到好友和单向关注userId 列表中
				DataMap.allFriendsUIds[toUserId] = toUserId;
				
				UI.showMessages();
				/*var imgUrl =myFn.getAvatarUrl(user.userId);
				friendHtml = UI.createFriendsItem(imgUrl, user.userId, user.nickname, user.description);
				$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
				UI.isChoose(user.userId);
				UI.showMsgNum(toUserId);*/

				ConversationManager.open(user.userId,user.nickname);

				var msg=WEBIM.createMessage(1,"你们已互为好友，请开始聊天吧");
				msg.fromUserId=toUserId;
							
			},user.nickname);			
						
		},1);
	},
	refuseFriends:function(toUserId){
		//拒绝加好友
		var msg=WEBIM.createMessage(MessageType.Type.REFUSED,"",toUserId);
		UI.sendMsg(msg,toUserId);
	},
	newCreateRoome : function(){ //新建房间
		$("#createGroupShow").empty();  //清空已选好友列表
		Checkbox.cheackedFriends = {};  //清空储存的数据
		$("#newRoomModal #roomName").val("");
		$("#newRoomModal #roomDesc").val("");
		$('#newRoomModal').modal('show'); //显示弹框

		$("#btnCreateGroup").show();
		$("#loading_1").hide();
		$("#createGroupSetting #isLook").attr("value",1);

		UI.showAddFriendList(0); //展示第一页的好友
		
	},
	//打开设置面板
	showSetting:function() {
		$("#o").hide();
		UI.hideChatBodyAndDetails();
		$("#setPassword").hide();
		var setting = null;
		//设置相关数据回显
		mySdk.getUser(myData.userId, function(result) {
			myData.user = result;
			setting =myData.user.settings;
			$("#privacy").show();
			$("#prop").hide();

			if(1==setting.friendsVerify)
				UI.switchToggle("friendsVerify",1);
			if(1==setting.openService)
				UI.switchToggle("customerService",1);
			if(1==myData.isEncrypt)
				UI.switchToggle("infoEncrypt",1);
				
		});

		//初始化设置开关切换事件的监听
		
		//允许加好友
		layui.form.on('switch(allowAtt)', function(data){
	  		
	  		var sign = this.checked;
	  		setting.allowAtt = (true == sign?1:0);
			mySdk.updateUserSetting(setting);//调用接口更新用户数据
			
  		});

		//需要好友验证
		layui.form.on('switch(friendsVerify)', function(data){
	  		var sign = this.checked;
	  		setting.friendsVerify = (true == sign?1:0);
			mySdk.updateUserSetting(setting);//调用接口更新用户数据
  		});

		//消息加密传输
		layui.form.on('switch(infoEncrypt)', function(data){
	  		var sign = this.checked;
	  		DataUtils.setIsEncrypt((true == sign?1:0));
  		});

  		//客服模式
		layui.form.on('switch(customerService)', function(data){
	  		var sign = this.checked;
	  		setting.openService = (true == sign?1:0);
	  		CustomerService.openService(sign,setting,function(){
					var obj = $(data.elem);
				    obj.prop('checked',!sign);
					layui.form.render('checkbox');
	  		});
			
  		});
	},
	showPwd:function() {
		
		$("#o").hide();
		UI.hideChatBodyAndDetails();
		$("#privacy").hide();
		$("#prop").hide();
		$("#setPassword").show();

	},
	showMe:function() {

		$("#o").hide();
		UI.hideChatBodyAndDetails();
		$("#privacy").hide();
		$("#setPassword").hide();
 		$("#avatarUserId").val(myData.userId);
		mySdk.getUser(myData.userId, function(result) {
			myData.user = result;

			$("#avatar_preview").attr("src", myFn.getAvatarUrl(myData.userId)+"?x="+Math.random()*10);
			
			$("#mynickname").val(myData.user.nickname);
			// $("#mydescription").val(myData.user.description);
			$("input[type=radio][name='sex'][value='"+myData.user.sex+"']").attr("checked",'checked');
			$("#mybirthday").val(0 == myData.user.birthday ? "" : myFn.toDate(myData.user.birthday*1000));
			// $("#provinceId").val(myData.user.provinceId);
			// $("#cityId").val(myData.user.cityId);
			layui.form.render('radio');
			layui.laydate.render({elem: '#mybirthday',max: 0});
			$("#prop").show();
			
		});
	},
	showUser : function(userId) {
		
		if(10000==userId)
			return;

		mySdk.getUser(userId,function(result){
			var obj = result;
			Temp.toNickname=obj.nickname;
			Temp.toJid=obj.userId;
			Temp.toUserId=obj.userId;
			var imgUrl=10000==userId?"img/im_10001.png":myFn.getAvatarUrl(obj.userId);

			var html =	'<div class="user_info" style="" >'
					+		'<img style="width:80px;height:80px;" onerror="this.src=&quot;img/ic_avatar.png&quot;" src="'+imgUrl+'" class="roundAvatar">'
					+		'<div style="margin-top:20px;">'
					+			'<h5 class="media-heading">'+obj.nickname+'</h5>'
					+			'<img src="'+(1 == obj.sex ? "./img/man.png" : "./img/woman.png")+'" style="width:30px;">'
					+		'</div>'
					+		'<div class="details">'
					+			'<p>签名:<span>'+(myFn.isNil(obj.description) ? "暂无签名" : obj.description)+'</span></p>'
					+			'<p>通讯号:<span>'+obj.account+'</span></p>'
					+			'<p>生日:<span>'+(myFn.toDate(obj.birthday))+'</span></p>'
					+			'<p>地区:<span>'+(myFn.isNil(TB_AREAS_C[obj.provinceId]) ? "" : TB_AREAS_C[obj.provinceId])+'-'+(myFn.isNil(TB_AREAS_C[obj.cityId]) ? "暂无" : TB_AREAS_C[obj.cityId])+'</span></p>'    
					+		'</div>'
					+		'<div class="option">'
					+			'<button class="addAttention" onclick="UI.addFriends(\''+obj.userId+'\');">加好友</button>'
					+			'<button class="sendMsg" onclick="ConversationManager.open(\''+(userId )+'\',\''+myFn.getText(obj.nickname)+'\');">发消息</button>'
					+		'</div>'
					+	'</div>'			

			$("#userModalBody").empty();
			$("#userModalBody").append(html);
			$("#userModal").modal('show');
			var friend=obj.friends;

			if(myFn.isNil(friend)){
				if(1==obj.settings.friendsVerify){	
					$("#userModalBody .addAttention").show();
				}
				$("#userModalBody .sendMsg").hide();
				
			}else if(1==friend.blacklist){
				$("#userModalBody .sendMsg").hide();
				$("#userModalBody .addAttention").hide();
			}else if(1==friend.isBeenBlack){
				
				$("#userModalBody .sendMsg").hide();
				$("#userModalBody .addAttention").hide();
			}else if(0==friend.status){
				if(1==obj.settings.friendsVerify){
					
					$("#userModalBody .addAttention").hide();
				}
				
				$("#userModalBody .sendMsg").hide();
				$("#userModalBody .addAttention").show();
				
			}else if(1==friend.status){
				//已经关注 打招呼
				if(1==obj.settings.friendsVerify){
					$("#userModalBody .addAttention").show();
				}
				
				$("#userModalBody .sendMsg").hide();

			}else{
				//已经是好友了
				$("#userModalBody .addAttention").hide();
				$("#userModalBody .sendMsg").show();
			}
					
		},1);
	},
	//文件上传
	upload:function(){
		
		var file = $("#myfile")[0].files[0];
		
		Temp.file=file;
		var filesize =file.size/1024/1024;
		if(filesize > 20){
            ownAlert(3,"文件大小超过限制，最多20M");
            return false;
        }
        $("#filePath").val(file.name);
        $("#filePath").attr("size",file.size);
        
			
		$("#uploadFileFrom").ajaxSubmit(function(data) {//成功
			
			 //$("#uploadFileFrom #icon").hide();
	        var obj = eval("(" + data + ")");
			if (!myFn.isNil(obj.url)) {
				Temp.file.url=obj.url;
				$("#myFileUrl").val(obj.url);
				$("#myfile").val("");
				if(Temp.uploadType=="sendImg"){
					$("#myImgPreview").attr("src",obj.url);
					UI.sendImg();
				} else if("uploadFile"==Temp.uploadType){
					//群文件上传
					GroupManager.addGroupFile(Temp.file);
				}else{
					$("#myFilePreviewPrant #myFilePreview").append(file.name);
					$("#myFilePreviewPrant").show();
					UI.sendFile();
					// ownAlert(3,"上传成功!");
				}
				
				
			}    
	    });




		


	},
	//聊天图片上传
	uploadImg:function(){
		layui.upload.render({
		        elem: '#btnImg', //文件选择元素
		        accept:'images',
		        acceptMime: 'image/*',
		        url: AppConfig.uploadUrl+'',
		        size:5000,
		        data:{
		        	id:"",
		        	userId:myData.userId,
		        },
		        progress: function(e , percent) {
		          //console.log("进度：" + percent + '%');
		        },
		        choose: function(obj) {//选择完成事件
		          var imgMsg = WEBIM.createMessage(2, " ");
		          this.data.id=imgMsg.messageId;

		          obj.preview(function(index, file, result) {
					 	
						var reader = new FileReader();
						reader.onload = function(evt){
							imgMsg.content = evt.target.result;
		          			UI.showMsg(imgMsg,myData.userId,1,1,"newMsg");
		          			DataUtils.saveMessage(imgMsg);//储存消息
						}
						reader.readAsDataURL(file);
		          });
		        },
		        done: function(res) { //上传完成事件
					var imgMsg=DataUtils.getMessage(this.data.id);
					imgMsg.content = res.url;
					UI.sendMsg(imgMsg);
		          
		          //UI.sendImg();
		        },
		        error: function(res) {
		          //layui.layer.msg(res.msg);
		        }
		});	


	},
	uploadFile:function(){
		
		layui.upload.render({
		        elem: '#btnFile', //文件选择元素
		        accept:'file',
		        url: AppConfig.uploadUrl+'',
		        data:{id:""},
		        progress: function(e , percent) {
		          //更新进度条
		          document.getElementById('fileProgress_'+this.data.id+'').childNodes[0].style.cssText="width: "+percent+"%;";
		        },
		        choose: function(obj) {//选择完成事件
		          var fileMsg = WEBIM.createMessage(9, "fileUrl");
		          this.data.id = fileMsg.messageId;
		          obj.preview(function(index, file, result) {
		          		//开始ui预加载
						fileMsg.fileName=file.name;
						fileMsg.fileSize=file.size;
	          			UI.showMsg(fileMsg,myData.userId,1,1,"newMsg");
		           		DataUtils.saveMessage(fileMsg);//储存消息
		          });
		          
		        },
		        done: function(res) { //上传完成事件
		          
		          //移除进度条
		          $("#fileProgress_"+this.data.id+"").remove();
		          //替换下载url
		          $("#fileDown_"+this.data.id+"").attr("href",res.url);
		          //发送消息
		          var fileMsg=DataUtils.getMessage(this.data.id);
				  fileMsg.content = res.url;
				  UI.sendMsg(fileMsg);
		        },
		        error: function(res) {
		          if(res.msg)
		          		layui.layer.msg(res.msg);
		        }
		});	

	},
	//文件上传
	uploadVoice:function(obj){
		var file= obj;
		Temp.file=file;
		var filesize =file.size/1024/1024;
			if(filesize > 20){
                ownAlert(3,"文件大小超过限制，最多20M");
                return false;
            }
            // $("#filePath").val($("#filePath").val()+","+file.name);
            // $("#filePath").attr("size",file.size);
            // $("#filePath").after("<img id='loadingimg' src='img/loading.gif'>");
			$("#voiceFileForm").ajaxSubmit(function(data) {//成功
				// $("#loadingimg").hide();
		          var obj = eval("(" + data + ")");
				if (!myFn.isNil(obj.url)) {
					Temp.file.url=obj.url;
					if(Temp.uploadType=="sendImg"){

						// $("#myImgPreview").attr("src",obj.url);

					}else{
						// $("#myFilePreviewPrant #myFilePreview").append(file.name);
						// $("#myFilePreviewPrant").show();
						// ownAlert(3,"上传成功!"); 
					}
					// $("#voiceUrl").val(obj.url);
					var msg=WEBIM.createMessage(4, obj.url);
					UI.sendMsg(msg);
					
				}    
		  });
	},
	//头像上传
	uploadPhoto:function(docObj){

		/*//判断图片后缀是否为png或jpg
		var f = $(docObj).val();
	    f = f.toLowerCase();
	    var strRegex = ".png|jpg|jpeg$";
	    var re=new RegExp(strRegex);
	    if (!re.test(f.toLowerCase())){
	    	ownAlert(2,"请选择正确格式的图片");
	    	return;
	    }


	    //检测上传文件的大小        
	    var isIE = /msie/i.test(navigator.userAgent) && !window.opera;  
	    var fileSize = 0;           
	    if (isIE && !docObj.files){       
	        var filePath = docObj.value;       
	        var fileSystem = new ActiveXObject("Scripting.FileSystemObject");          
	        var file = fileSystem.GetFile (filePath);       
	        fileSize = file.Size;      
	    } else {      
	        fileSize = docObj.files[0].size;       
	    }     

	    var size = fileSize / 1024*1024;   

	    if(size>(1024*1000)){    
	        ownAlert(3,"图片大小不能超过1M");
	        return;   
	    }


		$("#avatarForm").ajaxSubmit(function(data) {//成功
		        var obj = eval("(" + data + ")");
				var obj = eval("(" + data + ")");
			if (1 == obj.resultCode) {
				ownAlert(1,"头像上传成功！");
				//上传成功后更新头像
				$("#avatar_preview").attr("src", myFn.getAvatarUrl(myData.userId,1));
				$("#photo #myAvatar").attr("src", myFn.getAvatarUrl(myData.userId,1));
				$("#avatar_preview").show();
			}else 
			 	ownAlert(3,"上传头像失败!");  
		  });*/


		   
		    layui.upload.render({
			        elem: '#avatar_preview', //文件选择元素
			        accept:'images',
			        url: AppConfig.uploadAvatarUrl+'',
			        data:{userId : myData.userId},
			        done: function(res) { //上传完成事件
			          
			          	ownAlert(1,"头像上传成功！");
						//上传成功后更新头像
						$("#avatar_preview").attr("src", myFn.getAvatarUrl(myData.userId,1));
						$("#photo #myAvatar").attr("src", myFn.getAvatarUrl(myData.userId,1));
						$("#avatar_preview").show();
			        },
			        error: function(res) {
			          if(res.msg)
			          		layui.layer.msg(res.msg);
			        }
			});	



	},
	showSeeHai : function(userId) {
		//$("#userModal").modal('hide');
		Temp.toJid=userId;
		Temp.toUserId=userId;
		$("#divSeeHai #seeText").val("你好,我是"+myData.nickname);
		$("#divSeeHai").modal('show');
	},
	showReplySeeHai : function(userId) {
		Temp.toJid=userId;
		Temp.toUserId=userId;
		$("#divReplySeeHai #replyText").val("你是？");
		$("#divReplySeeHai").modal('show');
	},
	quit : function() {

		ownAlert(4,"是否确认退出登录？",function(){

				WEBIM.disconnect();
				DataUtils.setLogoutTime(WEBIM.getServerTime());
				$.cookie("telephone", "");
				$.cookie("password", "");
				$.cookie("loginData", "");
				window.location.href = "login.html";

		});

	},
	showBlackList : function(pageIndex){ //黑名单

		
		var isEmpty = true; //是否为空
		
		$("#myFriendsList").hide();
		$("#blackList").empty();

		 var blackListHtml= "<div id='blacklist_tool' style='overflow: hidden; outline: currentcolor none medium;'><table id='blackList' style='margin-left:10px; border-top:1px;'>";
		 var itemHtml="";
		 key_num=key_num+10;
		 	myFn.invoke({
		 		url:"/friends/queryBlacklistWeb",
		 		data:{
		 			pageIndex:pageIndex,
		 			pageSize:10
		 		},
		 		success:function(result){
		 			for(var key=0;key<result.data.pageData.length;key++){ //遍历黑名单map
			
						var blackUserId = result.data.pageData[key].toUserId;
						isEmpty = false;
						itemHtml="";
						mySdk.getUser(blackUserId, function(data){
							itemHtml+=" <tr id='blacklist_"+data.userId+"' style='border-bottom:1px solid #eeeeee;margin-left:10px'>"
							  		+	"<td   width=63 height=63>"
							  		+		"<a href='javascript:UI.showUser(" + data.userId + ")'>"
									+			"<img onerror='this.src=&quot;img/ic_avatar.png&quot;' width='40' height='40' src='"+myFn.getAvatarUrl(data.userId) + "' class='media-object roundAvatar'>"
									+   	"</a>"
									+   "</td>"
									+   "<td width='150'><p style='font-size:13px; width:10em;' class='textFlow'>" 
									+    myFn.getText(data.nickname) 
									+   "</p></td>"
									+	"<td  width='80' style='font-size:12px;'>"
									+		"<a href='javascript:mySdk.deleteBlacklist(" + data.userId + ");'>移除黑名单"
									+   "</a></td></tr>";
								blackListHtml+=itemHtml;
								
							});
					}
					
                    blackListHtml+=GroupManager.createPager(pageIndex,result.data.pageCount, 'UI.showBlackList',9);
		 		}
		 	})
		
		
		
		
		if(isEmpty){ //显示暂无数据
			$("#blackList").append("<div style='text-align:center;margin-top:60px;'><img src='img/noData.png' style='width:20px;margin-left:10px;margin-top:-5px;'><span style='margin-left:5px; color:#716C6C;; font-size:16px;'>暂无数据</span></div>");
		}else{
			blackListHtml+="</table></div>";
			
			$("#blackList").append(blackListHtml);
			
			
		}
		$("#btnMyFriends").removeClass("border");
		$("#btnAttentionList").addClass("border");
		
		$("#blackList").show();
		// 点击黑名单让新的朋友不显示
		$("#tabCon_new").hide();	

	

	},
	isChoose : function(userId){ //好友列表选中状态切换
	$("#friends_"+userId+"").siblings().removeClass("fActive");
     $("#friends_"+userId+"").addClass("fActive");
     
     $("#myMessagesList #friends_"+userId+"").siblings().removeClass("fActive");
     $("#myMessagesList #friends_"+userId+"").addClass("fActive");
     // if(10001!=userId)
     //  	changeTab('0','msgTab'); //恢复顶部切换按钮的状态
	},
	switchReadDel:function(isReadDel){ //isReadDel true： 开启  false 关闭
			if(isReadDel){
				ownAlert(3,"当前状态为阅后即焚，对方看完您发送的图片和语音以及视频消息后会立即删除");
				myData.isReadDel=1; //更新内存数据 1:是阅后即焚消息
				DataUtils.setFriendReadDelStatus(ConversationManager.fromUserId,1);
			}else{
				ownAlert(3,"已取消阅后即焚");
				myData.isReadDel=0; //更新内存数据 0:不是阅后即焚消息
				DataUtils.setFriendReadDelStatus(ConversationManager.fromUserId,0);
			}
	},
	showNewFriends:function(pageIndex){
		
		$("#tabCon_new").show();
		$("#tabCon_0").hide();
		$("#tabCon_1").hide();
		$("#tabCon_2").hide();
		$("#tabCon_3").hide();
		Temp.nowList="NewFriend";

		mySdk.getNewFriendsList(myData.userId, pageIndex, function(result) {
			var html = "<div id='list'>";
			var toUserId=null;
			for (var i = 0; i < result.pageData.length; i++) {
				var obj = result.pageData[i];
				toUserId=obj.toUserId;
				if(10020>obj.toUserId)
					continue;
				if(obj.userId==myData.userId&&obj.userId==obj.toUserId)
					continue;
				if(obj.toUserId==myData.userId)
					toUserId=obj.userId;
				/*if(507==obj.type){ //排除黑名单用户
					continue;
				}*/
				html += UI.createNewFriendsItem(obj);
				
			}
			html += GroupManager.createPager(pageIndex, result.pageCount, 'UI.showNewFriends');
			html +="<div>"
			
			
			$("#divNewFriendList").html(html);
			$("#divNewFriendList").show();
			// $("#charMessage").empty();
			// $("#charMessage").append("新的朋友");
			UI.clearMsgNum(10001);

		});
		
	},
	changeDetailsBtn : function(userId,type,friend){ //改变详情页面的按钮 type:0表示不是好友  type:1  表示已经互为好友  type:-1 //加入黑名单
		var detailsHtml =null;
		var blacklist=0;
		if(myFn.isNil(type)){
			if(myFn.isNil(friend))
				type=0;
			else if(2==friend.status){
				type=1;
			}else{
				blacklist=friend.blacklist;
				type=-1;
			}

		}
		$("#tabCon_1 #friendDetailsBtn").empty();
		if(10000==userId||myData.userId==userId) 
			return;
		else if(type==-1){ //黑名单
			
			detailsHtml="<button onclick='mySdk.deleteFriends(\"" + userId+"\");' class='btn danger_btn' style='margin-right: 25px;width: 150px'>删除好友</button>";
			detailsHtml+="<button onclick='mySdk.deleteBlacklist(\"" + userId+"\");' class='btn danger_btn' style='background-color: black;width: 150px'>取消黑名单</button>";
							
			$("#tabCon_1 #friendDetailsBtn").append(detailsHtml);
			return;
		}else if(type==1){ //好友
			
			detailsHtml="<button onclick='mySdk.deleteFriends(\"" + userId+"\");' class='btn danger_btn' style='margin-right: 25px;width: 150px'>删除好友</button>";
			if(1==blacklist)
				
				detailsHtml+="<button onclick='mySdk.deleteBlacklist(\"" + userId+"\");' class='btn danger_btn' style='background-color: black;width: 150px'>取消黑名单</button>";
			else 
				
				detailsHtml+="<button onclick='mySdk.addBlacklist(\"" + userId+"\");' class='btn danger_btn' style='background-color: black;width: 150px'>加入黑名单</button>";
		
		}else if(type==0){ //非好友
			$("#tabCon_1 #friendDetailsBtn").empty();
			
			detailsHtml="<button onclick='UI.addFriends(\"" + userId+"\");' class='btn danger_btn' style='margin-right: 25px;width: 150px'>加好友</button>"+
			"<button onclick='UI.showSeeHai(\"" + userId +"\");' class='btn danger_btn' style='background-color: black;width: 150px'>打招呼</button>";
		}
		
		$("#tabCon_1 #friendDetailsBtn").append(detailsHtml);
	

	},
	hideChatBodyAndDetails:function(){
		//隐藏右侧界面  聊天界面 和好友详情界面
		ConversationManager.isOpen=false;
		ConversationManager.from="";
		$("#tabCon_2").hide();
		$("#tabCon_1").hide();
		$("#tabCon_0").hide();
		$("#tabCon_new").hide();
		$("#tab").hide();

	},
	showDetails:function(from,chatType,name){
		console.log("UI : "+ "from:"+from+" name:"+name)
				//阅后即焚开关
		if(WEBIM.isGroupChat(ConversationManager.chatType)){
			$("#switchReadDelDiv").hide();
			myData.isReadDel=0;
			$("#groupDetails").show();
		}else{
			/*自己的其他设备不显示音视频通话 */
			if(ConversationManager.fromUserId!=WEBIM.userId){
				$("#btncall").show();
				$("#btnvideo").show();
			}else{
				$("#btncall").hide();
				$("#btnvideo").hide();
			}

			$("#switchReadDelDiv").show();
			$("#groupDetails").hide();
		}
			$("#messageContainer").empty();
			$("#messageBody").empty();
			$("#chatTitle").empty();
			$("#desname").empty();
			$("#dessign").empty();
			$("#dessex").empty();
			$("#gname").empty();
			$("#gnickname").empty();
			$("#gnotice").empty();
			$("#creator").empty();
			$("#desbirthday").empty();
			$("#descountry").empty();
			$("#gdesc").empty();
			$("#gcreateTime").empty();
			
			$("#desname").append(name);
			$("#tab").show();
			$("#tabCon_1").hide();
			$("#tabCon_2").hide();
			$("#tabCon_new").hide();
			$("#tabCon_0").show();
			$("#word").addClass('word');
			$("#details").removeClass('word');
			$("#chatPanel").show();

			$("#btncall").show();
		  	$("#btnvideo").show();
			var fromUserId = WEBIM.getUserIdFromJid(from);

			//判断是单聊还是群聊
			if (WEBIM.isChatType(chatType)){  //单聊
				if(fromUserId!=myData.userId)
					ConversationManager.showAvatar(fromUserId,0);//显示聊天窗口顶部头像(单聊)
				else{
					ConversationManager.showAvatar(fromUserId,0,WEBIM.getResource(from));
				}
				//$("#chatTitle").append("<span>"+name+"</span><span id='state'>(离线)</span>");
				$("#chatTitle").append("<span>"+name+"</span>");

				myData.isReadDel=DataUtils.getFriendReadDelStatus(fromUserId);
				if(myFn.isNil(myData.isReadDel))
					myData.isReadDel=0;
				if(0==myData.isReadDel){
					UI.switchToggle("switchReadDel",0);
				}else{
					UI.switchToggle("switchReadDel",1);
				}
					
				//显示对话框顶部对方的在线状态
				/*if(10000==fromUserId)
					$("#state").empty();
				else{
					mySdk.getUserOnLine(fromUserId,function(status){
						if(status==1)
							$("#state").html("(在线)");
					});
				}*/
				
				mySdk.getUser(fromUserId,function(user){
					DataMap.friends[fromUserId]=user.friends;
					$("#desprovince").empty();
					$("#dessex").append((1 == user.sex ? "男" : "女"));
					if(user.description==""){
						$("#dessign").append("暂无签名");
					}else{
						$("#dessign").append(user.description);
					}
					if(user.countryId==1){
						$("#descountry").append("中国");
					}
					$("#desbirthday").append(myFn.toDate(user.birthday));
					$("#desprovince").append(TB_AREAS_C[user.provinceId]);
					delete DataMap.userMap[user.userId]; //清除缓存数据
					// UI.changeDetailsBtn(user.userId,null,user.friends);
					UI.changeDetailsBtn(user.userId,1);//出现在好友列表中的数据均为好友关系
					/*setTimeout(function(){
						
					},2000);*/
					
				});
				$("#g_toolbar").hide();
				$("#details").click(function(){
						changeTab(1,"detailsTab");
				});
				$("#btnmin").show();
				$("#chatBannedDiv").hide();
				
			} else { //群聊
				$("#chatTitle").append(name);
				$("#btnInvite").show();
				mySdk.getRoomOnly(GroupManager.roomData.id,function(result){

					if(!myFn.isNil(result.member)){
						$("#gnickname").append(result.member.nickname);
					 	ConversationManager.talkTime=result.member.talkTime; 
					 	
					 		
					 	if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowConference){
			 				$("#btncall").hide();
					  		 $("#btnvideo").hide();
					  	}
			  				
					}
					//给群组详情界面添加群头像
					// var imgUrl = myFn.getAvatarUrl(result.userId);
					$("#tabCon_2 #desphoto").empty();
					$("#tabCon_2 #desphoto").append("<img src='./img/group_avatar.png' style='margin-left: 50px;width:40px; height:40px;'  class='roundAvatar'>");
					$("#gdesc").append(result.desc);
					$("#creator").empty();
					$("#creator").append(result.nickname);
					$("#gcreateTime").append(myFn.toDate(result.createTime));
					$("#gname").append(result.name);
					if(myFn.notNull(result.notice)&&myFn.notNull(result.notice.text)){
						$("#gnotice").append(myFn.getText(result.notice.text,25));
					}else{
						$("#gnotice").append("暂无公告");
					}
					GroupManager.showGroupSetting();
					if(myData.userId==GroupManager.roomData.userId){
							$("#btnDelete").show();
							$("#btnexit").hide();
					}else{
						$("#btnDelete").hide();
						$("#btnexit").show();
					}
					mySdk.getMembersList(GroupManager.roomData.id,null,function(result){
						Temp.members={};
						for (var i =0; i<result.length; i++) {
							var member={};
							if(myData.userId==GroupManager.roomData.userId){
								if(!myFn.isNil(result[i].remarkName))
									member.remarkName=result[i].remarkName;
							}
							member.nickname=result[i].nickname;
							
							Temp.members[result[i].userId]=member;
						}
					});
					
			});
				
				$("#g_toolbar").show();
				$("#details").click(function(){ //点击详情按钮
						changeTab(2,"detailsTab");	
				})
			}

	},
	/* 开关切换*/
	switchToggle:function(id,isOpen){
		if(isOpen==1){ //开启
			//$("input[type=checkbox][id='"+id+"']").attr("checked",'checked');
			$("#"+id+"").prop('checked',true);
		}else{
			//$("input[type=checkbox][id='"+id+"']").removeAttr("checked");
			$("#"+id+"").prop('checked',false);
		}
		layui.form.render('checkbox');
	},
	/*初始化聊天列表页面*/
	initUIMessageList:function(){
		var messageList=DataUtils.getUIMessageList();
		if(myFn.isNil(messageList))
			return;

		/*按照timeSend 排序*/
		var sortList=Utils.objSort(messageList,"timeSend",1,"lastTime");
		var message=null;
		var msgNum=0;
		for (i in sortList){
			message=messageList[sortList[i]];
			if(myFn.isNil(message))
				continue;
			var jid=message.id.split("/")[0];
			message.isGroup=WEBIM.isGroup(jid);
			/*message.fromUserId=message.id;
			message.fromUserName=message.name;*/
			if(1==message.isGroup){
				if(message.lastTime>message.timeSend){
					//DataUtils.clearMsgRecordList(message.id);
					/*var timeSend=message.timeSend;
					if(0==timeSend){
						timeSend=DataUtils.getLogoutTime();
					}
					//console.log(" timeSend > "+timeSend);
					var seconds=message.lastTime-timeSend;
					if(seconds>1000){
						DataUtils.clearMsgRecordList(message.id);
						WEBIM.joinGroupChat(message.id,null,seconds);
					}*/
					
				}
				UI.moveFriendToTop(message,message.id,message.name,1,0);
			}else{
				if(message.lastTime>message.timeSend){
					DataUtils.clearMsgRecordList(message.id);
				}
				if(jid==myData.userId){
					DeviceManager.moveFriendToTop(message,message.id,message.name,1,0);
					continue;
				}
				
				UI.moveFriendToTop(message,message.id,message.name,1,0);
			}
			/* msgNum=DataUtils.getMsgNum(message.id);
			if(0<msgNum){
				$("#myMessagesList #msgNum_"+message.id+" #span").html(msgNum);
				$("#myMessagesList #msgNum_"+message.id).show();
			}*/
			
		}
		var messageNumber=DataUtils.getMsgNumCount();
		UI.setUIMsgNumCount(messageNumber);

		UI.showMsgNum(10001);
	},
	removeFriendMessagesList(userId){
		$("#myMessagesList #friends_"+userId).remove();
	},
	removeGroupMessagesList(jid){
		$("#myMessagesList #groups_"+jid).remove();
	},
	moveFriendToTop : function(msg,fromUserId,fromUserName,showNum,updateUI) { 
		//content消息的内容
		//将发送消息的好友移动到消息列表顶部
		//然后显示消息提醒
		if(1100==fromUserId)
			return;
		var friendHtml=null;
		//No1 将发送消息的好友移动到新朋友的下方

		var content=WEBIM.parseShowMsgTitle(msg);
		var timeSend=0!=msg.timeSend?msg.timeSend:msg.lastTime;
		var timeSendStr=getTimeText(timeSend,1);

		var roomId=null;
		if(myFn.isNil(updateUI))
			updateUI=1;

		content=202!=msg.type?content:"撤回了一条消息";
		if(1==msg.type&&myFn.isReadDelMsg(msg))
			content="[阅后即焚消息]";

		
		if(myData.userId==msg.fromUserId)
			showNum=0;
		if(0!=updateUI){
			UI.updateMessageListTimeSendStr();
			DataUtils.putUIMessageList(msg,fromUserId,fromUserName);
			if(1==msg.isGroup&&10==msg.type)
				DataUtils.putMsgRecordList(916!=msg.contentType?msg.objectId:msg.roomJid,msg.messageId);
			else	
				DataUtils.putMsgRecordList(fromUserId,msg.messageId);
		}
		if(!fromUserId)
			fromUserId=msg.fromUserId;
		if(!fromUserName&&myData.userId!=msg.fromUserId)
			fromUserName=msg.fromUserName;


		if(myFn.isNil(content))
			content="&nbsp";
		var i=0;
		if(1==msg.isGroup)
			 friendHtml = $("#myMessagesList #groups_"+fromUserId).prop("outerHTML");
		else
			 friendHtml = $("#myMessagesList #friends_"+fromUserId).prop("outerHTML");


		//判断发送消息的好友是否在当前页中
		if(!myFn.isNil(friendHtml)){ //存在
			//存在 则直接加入到新朋友下方
			if(1==msg.isGroup){
				$("#myMessagesList #groups_"+fromUserId).remove();
			}
			else{
				if(10000!=fromUserId)
				$("#myMessagesList #friends_"+fromUserId).remove();
			}
			if(10000!=fromUserId)	
				$(friendHtml).insertAfter("#myMessagesList #friends_10001");
			if(1==showNum){
				UI.showMsgNum(fromUserId,updateUI);
			}
			//改变新消息内容

		 	$("#myMessagesList #timeSend_"+fromUserId).html(timeSendStr);
		 	$("#myMessagesList #timeSend_"+fromUserId).attr("value",timeSend);

			if(1==msg.isGroup){
				 $("#myMessagesList #titgroups_"+fromUserId).html(myFn.getText(content,20));
			
			}else{
			    var parseContent = myFn.parseContent(content,1);

			    //$("#myMessagesList #titfriends_"+fromUserId).html(myFn.getText(content,20));
			    $("#myMessagesList #titfriends_"+fromUserId).html(parseContent);
			}
		  
		}else{ 
			if(i==1)
				return;
			i=1;
			//创建好友的html
			if(1==msg.isGroup){//群组的
				var room=DataMap.myRooms[fromUserId];
				if(myFn.isNil(room)){
					mySdk.getRoomOnly(msg.fileName,function(result){
						room=result;
						friendHtml= GroupManager.createMyItem(room,content,timeSend,timeSendStr);
						fromUserName=room.name;
						$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
						if(1==showNum){
							UI.showMsgNum(fromUserId,updateUI);
						}
					});
				}else{
					var roomId=DataMap.myRooms[fromUserId].id;
					 room=DataMap.rooms[roomId];
					 fromUserName=room.name;
					friendHtml= GroupManager.createMyItem(room,content,timeSend,timeSendStr);
					$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
					if(1==showNum){
						UI.showMsgNum(fromUserId,updateUI);
						
					}
				}
				
				
			}else{//好友的
				var imgUrl =myFn.getAvatarUrl(fromUserId);
				if(myData.userId==fromUserId)
					fromUserName=myData.nickname;

				var friend=DataMap.friends[fromUserId];
				if(myFn.isNil(friend)){
					mySdk.getFriends(fromUserId,function(user){
						if(myFn.isNil(user))
							return;
						fromUserName=myFn.isNil(user.remarkName)?user.toNickname:user.remarkName;

						DataMap.friends[fromUserId]=user;
						friendHtml = UI.createFriendsItem(imgUrl, fromUserId, fromUserName,content,timeSend,timeSendStr);
						$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
						if(1==showNum){
							UI.showMsgNum(fromUserId,updateUI);
							
						}
					});
				}else{
					fromUserName=myFn.isNil(friend.remarkName)?friend.toNickname:friend.remarkName;
				}
				

				if(myFn.isNil(fromUserName))
					return;
				if(myFn.isNil(friendHtml)){
					friendHtml = UI.createFriendsItem(imgUrl, fromUserId, fromUserName,content,timeSend,timeSendStr);
					$(friendHtml).insertAfter("#myMessagesList #friends_10001"); //加入到新朋友下方
					if(1==showNum){
						UI.showMsgNum(fromUserId,updateUI);
						
					}
				}
			}
		  	i=0;
				
		}
		
				

	},
	//刷新 聊天列表的 发送时间 描述
	updateMessageListTimeSendStr:function(){
		$("#myMessagesList .timeSend").each(function(){
  			var timeSend=$(this).attr("value");
  			if(myFn.isNil(timeSend))
  				return true;
  			var timeSendStr=getTimeText(timeSend,1);
  			$(this).html(timeSendStr);
  		});
	},
	/*删除消息 后 更新最后一条消息到聊天列表 */
	refreshLastMsgtoMessageList:function(){
		var lastElem=$("#messageContainer .msgDiv").last();
		if(lastElem.length<1)
			return;
		var lastMsgId=$(lastElem).attr("id").split("msg_")[1];
		if(myFn.isNil(lastMsgId))
			return;
		var msg=DataUtils.getMessage(lastMsgId);
		if(myFn.isNil(msg))
			return;
			UI.moveFriendToTop(msg,ConversationManager.fromUserId,null,0);
			DataUtils.putMsgRecordList(ConversationManager.fromUserId,msg.messageId);
			//$(lastElem).nextAll().remove();
	},
	sendCard : function(){ //发送名片
		Checkbox.cheackedFriends = {};  //清空储存的数据
		Temp.friendListType="sendCard";
		UI.loadFriendList(0);
	},
	loadFriendList : function(pageIndex,cb){ //加载好友列表，带翻页和记忆上一页的数据功能
	    var tbInviteListHtml = "";
		mySdk.getFriendsList(myData.userId,null,2, pageIndex, function(result) {
			var friendsList = result.pageData;
			var obj=null;
			var choosedUIds = Checkbox.parseData(); //调用方法获取已勾选的好友
			for(var i = 0; i < friendsList.length; i++){
				 obj = friendsList[i];
				 if(10000==obj.toUserId)
				 	continue;
				 var inputItem = "<input id='false' name='invite_userId' type='checkbox' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
				 if(0 != choosedUIds.length){
					 for (var j = 0; j < choosedUIds.length; j++) {
					 	 cUId = choosedUIds[j]
					 	 if(obj.toUserId == cUId){
					 	 	inputItem = "<input id='false' name='invite_userId' type='checkbox' checked='checked' value='" + obj.toUserId + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
					 	 }
				 	}	 
				 }
				tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.toUserId)
				+ "' width=30 height=30 class='roundAvatar'/></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" +myFn.getText(obj.toNickname) 
				+ "</td><td>"+inputItem+"</td></tr>";
			}
			var pageHtml = GroupManager.createPager(pageIndex,result.pageCount,'UI.loadFriendList');
			$("#card #cardPage").empty().append(pageHtml);
			$("#friends").empty();
			$("#friends").append(tbInviteListHtml);
			$("#card").modal('show');
		});
	},
	callvideosFriendList : function(pageIndex,cb){
		var tbInviteListHtml = "";
		mySdk.getMembersList(GroupManager.roomData.id,null, function(result) {
			var friendsList = result;
			var obj=null;
			var choosedUIds = Checkbox.parseData(); //调用方法获取已勾选的好友
			for(var i = 0; i < friendsList.length; i++){
				 obj = friendsList[i];
				 if(10000==obj.toUserId)
							continue;
				 else if(obj.userId==myData.userId)
				 	continue;
				 var inputItem = "<input id='false' name='invite_userId' type='checkbox' value='" + obj.userId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
				 if(0 != choosedUIds.length){
					 for (var j = 0; j < choosedUIds.length; j++) {
					 	 cUId = choosedUIds[j]
					 	 if(obj.userId == cUId){
					 	 	inputItem = "<input id='false' name='invite_userId' type='checkbox' checked='checked' value='" + obj.userId + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
					 	 }
				 	}	 
				 }
				tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.userId)
				+ "' width=30 height=30 class='roundAvatar'/></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + myFn.getText(obj.nickname) 
				+ "</td><td>"+inputItem+"</td></tr>";
			}
			var pageHtml = GroupManager.createPager(pageIndex, 1,'UI.callvideosFriendList',friendsList.length);
			$("#callvideos #callvideoscardPage").empty().append(pageHtml);
			$("#callvideosfriends").empty();
			$("#callvideosfriends").append(tbInviteListHtml);
			$("#callvideos").modal('show');
			});
	},
	searchFriendAndMember:function(){
		//搜索好友 和搜索群成员
		var keyword=$("#divFriendList #keyword").val();
		if(myFn.isNil(keyword)){
			ownAlert(3,"请输入搜索关键字");
			return;
		}
		if("@Member"==Temp.friendListType){
			mySdk.getMembersList(GroupManager.roomData.id,keyword,function(result){
	     		Temp.MemberHttping=null;
	     		var tbInviteListHtml = "";
	            var obj=null;
	            for(var i = 0; i < result.length; i++){
	                 obj = result[i];
	                tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.userId)
	                + "' width=30 height=30 /></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + myFn.getText(obj.nickname) 
	                + "</td><td><input id='divFriendListSelect'  type='checkbox' value='" + obj.userId +"' nickname='"+obj.nickname+"' "
	                + " onclick='Checkbox.checkedAndCancel(this)'  />"
	                + "</td></tr>";
	            }
	            $("#friendlist").empty();
	            $("#friendlist").append(tbInviteListHtml);
	            $("#divFriendList").modal('show');
       		});
		}
	},  //获取标签的坐标
    getElementPos : function(elementId){     
        var ua = navigator.userAgent.toLowerCase();    
        var isOpera = (ua.indexOf('opera') != -1);    
        var isIE = (ua.indexOf('msie') != -1 && !isOpera); // not opera spoof    
     
        var el = document.getElementById(elementId);    
     
        if (el.parentNode === null || el.style.display == 'none') {    
            return false;    
        }    
     
        var parent = null;    
        var pos = [];    
        var box;    
        if (el.getBoundingClientRect){ //IE    
            box = el.getBoundingClientRect();    
            var scrollTop = Math.max(document.documentElement.scrollTop, document.body.scrollTop);    
            var scrollLeft = Math.max(document.documentElement.scrollLeft, document.body.scrollLeft);    
            return {    
                x: box.left + scrollLeft,    
                y: box.top + scrollTop    
            };    
        }else if (document.getBoxObjectFor) {    // gecko  
     
                box = document.getBoxObjectFor(el);    
                var borderLeft = (el.style.borderLeftWidth) ? parseInt(el.style.borderLeftWidth) : 0;    
                var borderTop = (el.style.borderTopWidth) ? parseInt(el.style.borderTopWidth) : 0;    
                pos = [box.x - borderLeft, box.y - borderTop];    
        }else{    // safari & opera
                pos = [el.offsetLeft, el.offsetTop];    
                parent = el.offsetParent;    
                if (parent != el) {    
                    while (parent) {    
                        pos[0] += parent.offsetLeft;    
                        pos[1] += parent.offsetTop;    
                        parent = parent.offsetParent;    
                    }    
                }    
                if (ua.indexOf('opera') != -1 || (ua.indexOf('safari') != -1 && el.style.position == 'absolute')) {    
     
                    pos[0] -= document.body.offsetLeft;    
                    pos[1] -= document.body.offsetTop;    
                }    
            }    
     
        if (el.parentNode) {    
            parent = el.parentNode;    
        }else {    
            parent = null;    
        }  

        while (parent && parent.tagName != 'BODY' && parent.tagName != 'HTML') { // account for any scrolled ancestors    
     
            pos[0] -= parent.scrollLeft;    
            pos[1] -= parent.scrollTop;    
     
            if (parent.parentNode) {    
                parent = parent.parentNode;    
            }else {    
                parent = null;    
            }    
     
        }    
     
        return {    
            x: pos[0],    
            y: pos[1]    
        };    
     
    } ,
    scrollToBottomUnread : function(){
    	//让滚动条移动到消息位置
		$("#bottomUnreadCount").remove();
		$("#messagePanel").nanoScroller({ scrollTo: $('.message_system') });
    },
    /*清除聊天界面的聊天记录*/
    cleanUIMessage:function(){
    	$("#messageContainer").html("");
    },
    /*清除好友的未读消息数量*/
    cleanFirendMsgCount:function(userId){
    	let friendCount=DataUtils.getMsgNum(userId);
    	if(0<friendCount){
    		let msgCount=DataUtils.getMsgNumCount();
    		if(0<msgCount){
    			msgCount=msgCount-friendCount;
	    		DataUtils.setMsgMumCount(msgCount);
	    		UI.setUIMsgNumCount(msgCount);
    		}

    	}
    },
    setUIMsgNumCount:function(msgCount){
    	//显示到页面
		if(!msgCount>0){
			$("#messages #messageNum").removeClass("msgNumShow");
			$("#messages #messageNum").addClass("msgNumHide");
		}else{
			if(msgCount > 99){  //数量大于99 则显示99+
				$("#messages #messageNum").text("99+");
			}else{
				$("#messages #messageNum").text(msgCount);
			}
			$("#messages #messageNum").removeClass("msgNumHide");
			$("#messages #messageNum").addClass("msgNumShow");
		}
    }

};


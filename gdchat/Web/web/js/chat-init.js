layui.use(['form', 'layedit', 'laydate'], function(){
	var form = layui.form,
	    layer = layui.layer,
	    layedit = layui.layedit,
	    laydate = layui.laydate;

	var loginDataObj=null;

	var init_loading_index = 0;
	var isInit=true;

	var  initTime = new Date();

	$(document).ready(function() { 
		//初始加载loading框
		init_loading_index = layui.layer.load(1, {shade: [0.4,'#383535']  }); 

	});



	$(function() {

		
		WEBIM.initConfig();

		var loginData = $.cookie("loginData");

		if (myFn.isNil(loginData)) {
			shikuLog("loginData  "+loginData);
			loginDataObj=DataMap.loginData;
			if(myFn.isNil(loginDataObj)){
					if(window.sessionStorage){
						loginDataObj=JSON.parse(window.sessionStorage.getItem('loginData'));
					}
					if(myFn.isNil(loginDataObj)){
						ownAlert(2,"您尚未登录或登录已超时，请重新登录");
						window.location.href = "login.html";	
					}
						
					
			}else{
					loginDataObj=loginData;
			}
		}else{
			loginDataObj = eval("(" + loginData + ")");
		}

		myData.userId = loginDataObj.userId;
		dbStorage.userId = myData.userId;
		

		myData.telephone = loginDataObj.telephone;
		myData.password = loginDataObj.password;
		myData.access_token = loginDataObj.access_token;
		myData.httpKey = loginDataObj.httpKey;
		myData.nickname=loginDataObj.loginResult.nickname;
		myData.loginResult = loginDataObj.loginResult;


		WEBIM.setUserIdAndToken(myData.userId,myData.access_token);
		WEBIM.initWebIM(AppConfig.websocketUrl,myData.userId,"web"
			,myData.access_token,myData.keepalive,myData.nickname);

		mySdk.autoLogin(function(result){
			var logoutTime=DataUtils.getLogoutTime();
			console.log("autoLogin "+JSON.stringify(result));
			myData.nickname=result.nickname;
			myData.settings=result.settings;
			myData.multipleDevices=result.settings.multipleDevices;
			if(1==myData.multipleDevices)
				myData.resource="web";
			myData.jid = myData.userId+"/"+myData.resource;
			
			try{
				if(0==logoutTime){
					logoutTime=result.login.offlineTime;
					if(0<logoutTime)
					   DataUtils.setLogoutTime(logoutTime*1000);
					else 
					   DataUtils.setLogoutTime(WEBIM.getServerTime());
				}	
				initWebLogin();
		    }catch(ex){
		            console.log(ex);
		    }
		});

		 console.log("init ===> getLogoutTime "+DataUtils.getLogoutTime());
	   /* window.onbeforeunload=function(){
	        shikuLog("onbeforeunload =========== > ");
	        if(!WEBIM.isConnect()){
	            DataUtils.setLogoutTime(WEBIM.getServerTime());
	        }
	    };*/
		
		
		
		// 百度定位
		//mySdk.locate();
	});
	function initWebLogin(){
		
		$("#uploadUserId").val(myData.userId);
		$("#VoiceuploadUserId").val(myData.userId);
        
       WEBIM.loginIM(function(){
            console.log("ShikuWebIM loginSuccess =========>");
            layui.layer.close(init_loading_index); //关闭loding 
            
            if(isInit){
            	 $("#to").css("pointer-events","auto");
            	 downloadData();
             	isInit=false;
            }
            UI.online();
		});
       
        mySdk.getCurrentTime();
		$("#friends_10000Div").click(function(){
			ConversationManager.open('10000', '系统客服');
		});

		DeviceManager.initJid();

		loadUploadUrl();
	}

	function downloadData(){
		mySdk.downloadAllFriends(function(){
		});
		//下载我的所有好友
		GroupManager.downloadMyRoom(function(){
			DataUtils.getLastChatList(function(){
				UI.initUIMessageList();
				NetWork.networkListener(onNet,offNet);	

			});
		});
		//下载我的所有群组
		init();
	}

	function loadUploadUrl(){   //将上传的url赋到页面
		//我的资料-头像上传
		$("#prop #avatarForm").attr("action",""+AppConfig.uploadAvatarUrl); 
		$("#uploadFileModal #uploadFileFrom").attr("action",""+AppConfig.uploadUrl); 
		$("#voiceFileForm").attr("action",""+AppConfig.uploadUrl);
		$("#uploadFileModal").modal('hide');
	}
	
	function over(){
		var s=Document.getElementById("img1");
		s.src="img/378FMI5VN@}]1D{H5(NOP8D.png"
	}

	function out(){
		var s = Document.getElementById();
	}

	function init() { //进入主页面后执行
				
		DataUtils.getIsEncrypt();

		//进入主页面后加载左上角头像
		var h5="<img onclick="+'UI.showMe()'+" id='myAvatar' onerror='this.src=\"img/ic_avatar.png\"' src='"+myFn.getAvatarUrl(myData.userId,1)+"' class='myAvatar roundAvatar'><div id='user_online' class='user_status user_online'></div>"
		$("#photo").append(h5);
		var sp="<p id='nickname' class='text-length' style='color:white;margin-top:10px'>"+myData.nickname+"</p>"
		$("#photo").append(sp);
		$("#uploadUserId").val(myData.userId);
		$("#VoiceuploadUserId").val(myData.userId);


		
		// 加载聊天消息
		UI.showMessages();
		// 加载所有房间
		/*GroupManager.showAllRoom(0);*/
		
		if(myData.settings&&myData.settings.openService==1){
			CustomerService.modelSwitch(1);
			CustomerService.loadChatText(0); //加载第一页的聊天常用语
		}else{
			CustomerService.modelSwitch(0);
		}
		
		welcome();


		//setInterval
		var xmppInitTime = new Date();
		

		// 我的房间
		$("#btnMyRoom").click(function() {
			$("#btnAllRoom").removeClass("border");
			$("#btnMyRoom").addClass("border");
			
			GroupManager.showMyRoom(0);	
		});


		// 所有房间
		/*$("#btnAllRoom").click(function() {
			$("#btnMyRoom").removeClass("border");
			$("#btnAllRoom").addClass("border");
			
			$("#search_all_room").bind("input propertychange",function(){
				 GroupManager.showAllRoom(0,$(this).val());
			});

			GroupManager.showAllRoom(0);
		});*/
		
		
		//监听阅后即焚开关按钮事件
		form.on('switch(switchReadDel)', function(data){
	    	UI.switchReadDel(this.checked); 
	  	});

	
		//右上角菜单 显示关闭
	    $(".system_menu_opt").on("click",function(event){
	        var e = window.event || event;
			if (e.stopPropagation) {
				e.stopPropagation();
			} else {
				e.cancelBubble = true;
			}
			$('#system_menu_panel').toggle();
	    });

	    
	  
		
		//发送名片
		$("#sendOK").click(function(){
			var myArray = Checkbox.parseData();//调用方法解析数据
			if (0 == myArray.length) {
				ownAlert(3,"请选择要发送的好友名片");
				return;
			} else {
				for(var i=0;i<myArray.length;i++){
					mySdk.getUser(myArray[i],function(result){
								var  msg=WEBIM.createMessage(8, result.nickname);
								msg.objectId=result.userId+"";
								UI.sendMsg(msg);
								sleep(100);
						})


				}
				$("#card").modal('hide');
			}
			
		});
		

		// 发送
		$("#btnSend").click(function() {
			
			var content = $("#messageBody").val();
			if (myFn.isNil(content)) {
				ownAlert(3,"请输入要发送的内容");
				return;
			}
			var msg=WEBIM.createMessage(1, content);
			if(!WEBIM.isGroupChat(ConversationManager.chatType)){ //isGroup//1是群聊 0是单聊
				UI.sendMsg(msg);
				$("#messageBody").val("");
				return;
			}
			//群消息
			msg.fromUserName=GroupManager.roomCard;
			//msg.objectId=ConversationManager.fromUserId;

			var userIdArr=Checkbox.parseData();
			//@群成员了
			if(myFn.isContains(msg.content,"@")&&null!=userIdArr&&0<userIdArr.length){
				msg.objectId="";
				for (var i = 0; i < userIdArr.length; i++) {
					if(i==userIdArr.length-1)
						msg.objectId+=userIdArr[i]+"";
					else 
						msg.objectId+=userIdArr[i]+",";
				}

			}

			UI.sendMsg(msg);
			$("#messageBody").val("");
			Checkbox.cleanAll();
			
			
		});

		// 结束会话
		$("#btnEndChat").click(function() {
			
			CustomerService.endChat();//给对方发送结束会话xmpp消息
		});

		//监听图片上传按钮
		UI.uploadImg();
		
		//监听文件上传按钮
		UI.uploadFile();

		//监听群文件上传按钮
		GroupManager.uploadFile();

		$("#btnVoice").click(function(){
			if(!openUserMedia){
			      initUserMedia(false);
			  }
			  if(!openUserMedia){
			    return;
			  }else{
			  	 $("#voice").modal('show');
			  }
		});
		// 表情
		$("#btnEmojl").click(function(event) {
			$("#userfulText-panel").hide();
			$("#gif-panel").hide();
			$("#gif-panel #gifList").getNiceScroll().hide();
			var e = window.event || event;
			
			if (e.stopPropagation) {
				e.stopPropagation();
				
			} else {
				e.cancelBubble = true;
			}
			$('#emojl-panel').toggle();
			$("#emojl-panel #emojiList").getNiceScroll().show();
			$("#emojl-panel #emojiList").getNiceScroll(0).doScrollTop(0, 0);

		});
		// 常用语
		$("#userfulTextBtn").click(function(event) {
			$('#emojl-panel').hide();
			$("#emojl-panel #emojiList").getNiceScroll().hide();
			$("#gif-panel").hide();
			$("#gif-panel #gifList").getNiceScroll().hide();
			var e = window.event || event;
			if (e.stopPropagation) {
				e.stopPropagation();
				
			} else {
				e.cancelBubble = true;
			}
			$('#userfulText-panel').toggle();
			// $("#userfulText-panel #userfulTextList").getNiceScroll().show();
			// $("#userfulText-panel #userfulTextList").getNiceScroll(0).doScrollTop(0, 0);

		});
		// GIF 动画
		$("#btnGif").click(function(event) {
			$('#emojl-panel').hide();
			$("#userfulText-panel").hide();
			var e = window.event || event;
			if (e.stopPropagation) {
				e.stopPropagation();
			} else {
				e.cancelBubble = true;
			}
			$('#gif-panel').toggle();
			$("#gif-panel #gifList").getNiceScroll().show(); //显示滚动条
			$("#gif-panel #gifList").getNiceScroll(0).doScrollTop(0, 0); // 滚动到顶部
		});
		//@群成员
		$("#messageBody").keyup(function(){
	       if(!WEBIM.isGroupChat(ConversationManager.chatType)||Temp.MemberHttping)
	       	return;
	 		var text=$("#messageBody").val();
	 		if(1>text.length){
	 			Checkbox.cheackedFriends={};//清空选中的数据
	 			return;
	 		}
	       var str =text.charAt(text.length - 1);
	       if("@"!=str)
	       	return;
	       Temp.friendListType="@Member";
	       $("#divFriendListTitle").html("选择成员");
	       $("#divFriendListBtnOk").html("确认");
	       Checkbox.checkedNames=[];
	        Temp.nickname=null;
	      	Temp.MemberHttping=true;//网络请求中 再次触发事件不继续
	     	mySdk.getMembersList(GroupManager.roomData.id,null,function(result){
	     		Temp.MemberHttping=null;
	     		var tbInviteListHtml = "";
	            var obj=null;
	            for(var i = 0; i < result.length; i++){
	                 obj = result[i];
	                 if( myData.userId == obj.userId) //不加载用户自己
	                    continue;

	                tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.userId)
	                + "' width=30 height=30 /></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + obj.nickname	
	                + "</td><td><input id='divFriendListSelect'  type='checkbox' value='" + obj.userId +"' nickname='"+obj.nickname+"' "
	                + " onclick='Checkbox.checkedAndCancel(this)'  />"
	                + "</td></tr>";
	            }
	            $("#friendlist").empty();
	            $("#friendlist").append(tbInviteListHtml);
	            $("#divFriendList").modal('show');
	       });
		});

		//发送红包
		$("#redPacketSend").click(function(){
			 //var reg = new RegExp("^[0-9]+(.[0-9]{2})?$/");
			$("#inputPassword").modal("show");
			$("#divRedPacket").modal("hide");
		});

		// 输入密码完成
		$("#redPacketSendOK").click(function(){
			var reg = /(^[1-9]([0-9]+)?(\.[0-9]{1,2})?$)|(^(0){1}$)|(^[0-9]\.[0-9]([0-9])?$)/;
			 var money=$("#divRedPacket #money").val();
			if(!reg.test(money)){
	        	ownAlert(3,"请输入正确的金额!");
	        	$("#money").val("");
				$("#redp1").val("");
				$("#redp2").val("");
				$("#redp3").val("");
				$("#redp4").val("");
				$("#redp5").val("");
				$("#redp6").val("");
	        	return;
	    	}else if(money>500||money<0.01){
	    		ownAlert(3,"红包总金额在0.01~500之间哦!");
	    		$("#money").val("");
				$("#redp1").val("");
				$("#redp2").val("");
				$("#redp3").val("");
				$("#redp4").val("");
				$("#redp5").val("");
				$("#redp6").val("");
	    		return;
	    	} 
	    	var redType=$("#divRedPacket #redType").val();
	    
			var count=$("#divRedPacket #count").val();
			if((money/count)<0.01){
	    		ownAlert(3,"每个人最少 0.01元!");
	    		$("#money").val("");
				$("#redp1").val("");
				$("#redp2").val("");
				$("#redp3").val("");
				$("#redp4").val("");
				$("#redp5").val("");
				$("#redp6").val("");
	    		return;
	    	}

			var greetings=$("#divRedPacket #greetings").val();
			var roomJid=null;
			if(WEBIM.isGroupChat(ConversationManager.chatType)){//群聊红包
				var room=GroupManager.roomData;
				/*if(count>room.userSize){
					ownAlert(3,"数量不能大于群组人数");
					return;
				}*/
				roomJid=GroupManager.roomData.jid;
			}else 
				count=1;

			if(myFn.isNil(greetings))
				greetings="恭喜发财，万事如意";
			if(greetings.length>9){
				greetings=greetings.substring(0,9);
			}
			var password=$("#redp1").val()+$("#redp2").val()+$("#redp3").val()+$("#redp4").val()+$("#redp5").val()+$("#redp6").val();
			mySdk.sendRedPacket(redType,money,count,greetings,roomJid,password,function(data){
				var msg=WEBIM.createMessage(28,greetings);
				//红包类型
				msg.fileName=data.type;
				msg.fileSize=data.status;
				//红包ID
				msg.objectId=data.id;
				UI.sendMsg(msg);
				$("#divRedPacket").modal("hide");
				$("#inputPassword").modal("hide");
				$("#money").val("");
				$("#redp1").val("");
				$("#redp2").val("");
				$("#redp3").val("");
				$("#redp4").val("");
				$("#redp5").val("");
				$("#redp6").val("");
			});
		});

		// 表情框
		$("#emojl-panel").click(function(event) {
			var e = window.event || event;
			if (e.stopPropagation) {
				e.stopPropagation();
			} else {
				e.cancelBubble = true;
			}
		});

		// 空白点击事件
		document.onclick = function() {
			$("#gif-panel #gifList").getNiceScroll().hide();//隐藏滚动条
			$("#emojl-panel #emojiList").getNiceScroll().hide();
			$("#emojl-panel").hide();
			$("#gif-panel").hide();
			$("#userfulText-panel").hide();

			$('#system_menu_panel').hide();
		};
		
		
		//确认转发  @群成员
		$("#divFriendListBtnOk").click(function(){
			var userIdArr =Checkbox.parseData();
			if("@Member"==Temp.friendListType){
				//@群成员
				if(1>userIdArr.length)
					return;
				var text=$("#messageBody").val();
				var i=0;
				for (var key in Checkbox.checkedNames) {
					if(i==Checkbox.checkedNames.length-1)
					   	text+=Checkbox.checkedNames[key]+"  ";
					else
						text+=Checkbox.checkedNames[key]+"  @";
					i++;
				}
				$("#messageBody").val(text);
				Checkbox.checkedNames=[];
			}

			$("#divFriendList").modal('hide');
			
			
		});
		


		//发红包
		$("#redback").click(function(){
			
	       if(WEBIM.isGroupChat(ConversationManager.chatType)){
	       		$("#trRedCount").show();
	       		$("#luck").show();
	       		/*$("#redType").children('option[value="2"]').wrap('<span>').show();
	       		$("#redType").eq(1).show();
	       		$("#redType").remove();
				var html="<option  value='1' selected='true'>普通红包</option>"+"<option value='2'>口令红包</option>";
				$("#redType").append(html);*/
			}else{
				$("#trRedCount").hide();
				$("#luck").hide();
				/*$("#redType").children('option[value="2"]').wrap('<span>').hide();
				$("#redType").eq(1).hide();
				$("#redType").remove();
				var html1="<option  value='1' selected='true'>普通红包</option>"+"<option value='2'>拼手气红包</option>"+"<option value='3'>口令红包</option>";
				$("#redType").append(html1);*/
			}
			$("#divRedPacket").modal('show');
		});
		
		$("#btnEditOK").click(function() {
			var obj ={};
			var reg=new RegExp("^[\u4e00-\u9fa5A-Za-z0-9-_]*$");
			obj["nickname"]=$("#from #mynickname").val();
			if(!reg.test(obj["nickname"])){
				ownAlert(3,"昵称 输入有误 只能输入 中文 英文 数字!")
				return;
			}
			obj["description"]=$("#from #mydescription").val();
			// obj["nickname"]=$("#from #nickname").val();
			obj["sex"]=$("#from #sex:checked").val();
			obj["birthday"]=$("#from #mybirthday").val();
		
			//obj["cityId"]=$("#from #cityId").val();
		
			var birthday = obj["birthday"];
			var timestamp = Math.round(new Date(birthday).getTime() / 1000);
			if(timestamp>new Date().getTime()/1000){
				ownAlert(3,"时间不能超过当前时间!");
				return;
			}
			obj["birthday"] = timestamp;

			mySdk.updateUser(obj,function(user){
				$("#edit_modal").modal('hide');
				loginDataObj.user=user;
				myFn.setCookie("loginData",loginDataObj);
				$("#photo #nickname").html(user.nickname);
				//更新数据
				DataMap.userMap[user.userId].nickname = obj["nickname"];
				DataMap.userMap[user.userId].description = obj["description"];
				DataMap.userMap[user.userId].sex = obj["sex"];
				DataMap.userMap[user.userId].birthday = obj["birthday"];
				// $("#mybirthday").val(0 == myData.user.birthday ? "" : myFn.toDate(myData.user.birthday));
			});
		});

		$("#btnEditCancel").click(function() {
			$("#edit_modal").modal('hide');
		});
		$("#btnSettingCancel").click(function() {
			$("#edit_setting").modal('hide');
		});
		$("#btnPwdCancel").click(function() {
			$("#edit_pwd").modal('hide');
		});
		$("#seeHaiSendCancel").click(function() {
			$("#divSeeHai").modal('hide');
			Temp.toJid=null;
		});
		//发送打招呼信息
		$("#seeHaiSend").click(function() {
				console.log("发送打招呼信息");
				var msg=WEBIM.createMessage(MessageType.Type.SAYHELLO,$("#seeText").val(),Temp.toUserId,null);
				UI.sendMsg(msg,Temp.toJid);
				// 添加关注
				mySdk.addAttention(Temp.toUserId,function (result) {
                    $("#addfriend").modal('hide');
                    $("#divSeeHai").modal('hide');
				});
				ownAlert(1,"发送成功!");
				// $("#divSeeHai").modal('hide');

		});

		$("#replySeeSendCancel").click(function() {
			$("#divReplySeeHai").modal('hide');
			Temp.toJid=null;
		});

		//发送打招呼信息
		$("#replySeeSend").click(function() {

				var msg=WEBIM.createMessage(MessageType.Type.FEEDBACK,$("#replyText").val(),Temp.toUserId,null);
				UI.sendMsg(msg,Temp.toJid);
				ownAlert(1,"发送成功!");
				$("#divReplySeeHai").modal('hide');
				Temp.toJid=null;
		});
		

		




		$("#btnSettingOK").click(function() {
				var obj = $("#form4").serializeObject();
				
				obj["friendsVerify"]=0;
				obj["openService"]=0;

				
				if($("#friendsVerify").is(':checked')==true)
						obj["friendsVerify"]=1;
				if($("#infoEncrypt").is(':checked')==true){
					DataUtils.setIsEncrypt(1);
                    WEBIM.setEncrypt(true);
				}else{
					DataUtils.setIsEncrypt(0);
					WEBIM.setEncrypt(false);
				}

				if($("#customerService").is(':checked')==true)
					obj["openService"]=1;


				myFn.invoke({
					url : '/user/settings/update',
					data : obj,
					success : function(result) {
						if (1 == result.resultCode) {
							
							/*$("#edit_setting").modal('hide');*/
							ownAlert(1,"保存成功")
						} else {
							ownAlert(2,result.resultMsg);
						}
					},
					error : function(result) {
						ownAlert(2,"资料更新失败，请稍后再试！");
					}
				});

			
		});

		
		$("#close").click(function(){
			$("#getredpacket").modal("hide");
		});
		$("#btnPwdOK").click(function() {
			//.replace(/^\s+|\s+$/g, '')

			var obj = $("#form5").serializeObject();
			obj["oldPassword"]=$.md5($("#oldPwd").val());
			obj["newPassword"]=$.md5($("#newPassword").val());
			obj["password1"]=$.md5($("#password1").val());

			if(myFn.isNil(obj["oldPassword"])||myFn.isNil(obj["newPassword"])||myFn.isNil(obj["password1"])){
					ownAlert(3,"请输入值!");
					return;
				}else if(obj["newPassword"]!=obj["password1"]){
					ownAlert(3,"两次密码输入不一致!");
					return;
				}else if(obj["newPassword"]==obj["oldPassword"]){
					ownAlert(3,"新密码和旧密码不能一致!");
					return;
			}else if( /\s/.test($("#newPassword").val()) ){
				ownAlert(3,"密码不能包含空格");
				return;
			}else if( $("#newPassword").val().length<6 ){
				ownAlert(3,"密码请设置为6位及以上");
				return;
			}

			myFn.invoke({
				url : '/user/password/update',
				data : obj,
				success : function(result) {
					if (1 == result.resultCode) {
						ownAlert(3,"修改密码成功,请重新登陆！");
						$("#edit_setting").modal('hide');
						window.location.href = "login.html";
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"资料更新失败，请稍后再试！");
				}
			});
		});


		// 确认发送文件
		$("#btnSendFileOK").click(function() {
			var fielUrl=$("#myFileUrl").html();
			if(myFn.isNil(fielUrl)){
				fielUrl=$("#myFileUrl").val();
				if(myFn.isNil(fielUrl)){
					ownAlert(3,"请先上传文件!");
					return;
				}
			}
			
			if("sendImg"==Temp.uploadType)
				UI.sendImg();
			else if("sendFile"==Temp.uploadType)
				UI.sendFile();
			else if("uploadFile"==Temp.uploadType)//群文件上传
				GroupManager.addGroupFile(Temp.file);
				
			$("#uploadFileModal").modal('hide');
			 
			
			//$("#choiceFileModal").modal('hide');
		});
		// 取消发送文件
		$("#btnSendFileCancel").click(function() {
			//$("#choiceFileModal").modal('hide');
			$("#uploadFileModal").modal('hide');
			// 取消发送应删除已上传到服务的图片
			//取消发送 删除已上传的文件
			if(!myFn.isNil(Temp.file)&&!myFn.isNil(Temp.file.url)){
				mySdk.deleteFile(Temp.file.url,function(){
					//删除文件成功
				});
			}
			Temp.file=null;
		});

		
		/*
	      *	这一块先注释掉不要删除
		 $("#avatarUpload").click(function(){
			$("#avatarForm").ajaxSubmit(function(data) {//成功
			        var obj = eval("(" + data + ")");
					var obj = eval("(" + data + ")");
				if (1 == obj.resultCode) {
					ownAlert(1,"头像上传成功！");
					$("#avatar_preview").attr("src", obj.data.oUrl+"?x="+Math.random()*10);
					$("#photo #myAvatar").attr("src", obj.data.oUrl+"?x="+Math.random()*10);
					$("#avatar_preview").show();
				}else 
				 	ownAlert(3,"上传头像失败!");  
			  });
		});*/

		/*$("#uploadStart").click(function(){
			var file= $("#myfile")[0].files[0];
			Temp.file=file;
			var filesize =file.size/1024/1024;
			
	            if(filesize > 3){
	                ownAlert(3,"文件大小超过限制，最多20M");
	                return false;
	            }
	            $("#filePath").val(file.name);
	            $("#filePath").attr("size",file.size);

				$("#uploadFileFrom").ajaxSubmit(function(data) {//成功
			          var obj = eval("(" + data + ")");
					if (!myFn.isNil(obj.url)) {
						Temp.file.url=obj.url;
						$("#myImgPreview").attr("src",obj.url);
						$("#myImgPreview").show();
						$("#myFileUrl").val(obj.url);
						
					}    
			  });
		});*/


		$("#btnQueryAllRoom").click(function() {
			GroupManager.showAllRoom(0);
		});
		


		$("#newGroup").tooltip({ //鼠标移动弹出提示
	         trigger:'hover',
	         html:true,
	         title:'新建群组',
	         placement:'bottom'
	    });

	   $("#myFriend").tooltip({ //鼠标移动弹出提示
	         trigger:'hover',
	         html:true,
	         title:'加好友',
	         placement:'bottom'
	    });


	    //修改群昵称
		$("#btnNickname").click(function(){
			var nickname=$("#newNickname").val();
			
			if(nickname==""){
				ownAlert(3,"请输入新昵称");
			}
			if(nickname.length>20){
				ownAlert(3,"只能输入20个字符！");
				return;
			}
			 var reg=new RegExp("^[\u4e00-\u9fa5A-Za-z0-9-_]*$");
			if(!reg.test(nickname)){
				ownAlert(3,"输入有误 只能输入 中文 英文 数字!")
				return;
			}
			if("groupNickName"==Temp.updateNameType){
				GroupManager.updateMemberNickName(myData.userId,nickname);
			}else if("memberRemarkName"==Temp.updateNameType){
					GroupManager.updateMemberRemarkName(Temp.memberUserId,nickname);
			}else {

			}
			
		});


	}//init初始化结束


	// $(document).ready(function(){   
	// 	$("#chatPanel #messagePanel").mCustomScrollbar();

	// });



	$(document).ready(function(){   

	    //加载表情
	    var emojiHtml = "";  //emoji 的Html

		emojiList.forEach(function(info, index){
			emojiHtml +="<img src='emojl/"+info['filename']+".png' alt='"+info['chinese']+"' title='"+info['chinese']+"' onclick='UI.choiceEmojl(\"" +"["+info['english']+"]"+ "\")' />";
		});
        $("#emojl-panel #emojiList").append(emojiHtml);
        //初始化GIF动画的滚动条
		$("#emojl-panel #emojiList").niceScroll({
			  cursorcolor: "rgb(113, 126, 125)",
	          cursorwidth: "5px", // 滚动条的宽度，单位：便素
	          autohidemode: true, // 隐藏滚动条的方式
	          railoffset: 'top', // 可以使用top/left来修正位置
	          enablemousewheel: true, // nicescroll可以管理鼠标滚轮事件
	          smoothscroll: true, // ease动画滚动  
	          cursorminheight: 32, // 设置滚动条的最小高度 (像素)
	          iframeautoresize: true,//iframeautoresize: true
	          bouncescroll: false,
	          railalign: 'right',
		});
		$("#emojl-panel #emojiList").getNiceScroll().show(); //显示滚动条



	    //加载gif 动画
	    var gifHtml = "";  //gif 的Html
		gifList.forEach(function(info, index){
	          gifHtml +="<img src='gif/"+info['filename']+"' style='width:72px; height:72px;margin-left:15px;' onclick='UI.sendGif(\"" +info['filename']+ "\")' />"
	    });

        $("#gif-panel #gifList").append(gifHtml);
        //初始化GIF动画的滚动条
		$("#gif-panel #gifList").niceScroll({
			  cursorcolor: "rgb(113, 126, 125)",
	          cursorwidth: "5px", // 滚动条的宽度，单位：便素
	          autohidemode: false, // 隐藏滚动条的方式
	          railoffset: 'top',// 可以使用top/left来修正位置
	          enablemousewheel: true, // nicescroll可以管理鼠标滚轮事件
	          smoothscroll: true, // ease动画滚动  
	          cursorminheight: 32, // 设置滚动条的最小高度 (像素)
	          iframeautoresize: true,//iframeautoresize: true
	          bouncescroll: false,
	          railalign: 'right',
		});
		$("#gif-panel #gifList").getNiceScroll().show(); //显示滚动条
	   


		//聊天面板滚动条
		$("#messagePanel").nanoScroller();

	    //初始化滚动条
		$("#messageDisplayArea").niceScroll({
			  cursorcolor: "#c7c4c4",
	          cursorwidth: "8px", // 滚动条的宽度，单位：便素
	          autohidemode: true, // 隐藏滚动条的方式
	          railoffset: false,
	          enablemousewheel: true, // nicescroll可以管理鼠标滚轮事件
	          smoothscroll: true, // ease动画滚动  
	          cursorminheight: 32, // 设置滚动条的最小高度 (像素)
	          iframeautoresize: true //iframeautoresize: true
		});
		

		//初始化滚动条
		$("#myFriendsList").niceScroll({
			  cursorcolor: "#c7c4c4",
	          cursorwidth: "8px", // 滚动条的宽度，单位：便素
	          autohidemode: true, // 隐藏滚动条的方式
	          railoffset: false,
	          enablemousewheel: true, // nicescroll可以管理鼠标滚轮事件
	          smoothscroll: true, // ease动画滚动  
	          cursorminheight: 32, // 设置滚动条的最小高度 (像素)
	          iframeautoresize: true //iframeautoresize: true
		});


		//消息输入区按钮提示
		 $("#btnSipCall").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'音视频',
		         placement:'top'
		    });	
		   $("#btnEmojl").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'表情',
		         placement:'top'
		    });
		   $("#btnGif").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'动图',
		         placement:'top'
		    });
		   $("#btnImg").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'图片',
		         placement:'top'
		    });
		   $("#btnVoice").tooltip({
		   		trigger:'hover',
		   		html:true,
		   		title:'语音留言',
		   		placement:'top'
		   });
		   $("#btncall").tooltip({
		   		trigger:'hover',
		   		html:true,
		   		title:'语音通话',
		   		placement:'top'
		   });
		   $("#btnvideo").tooltip({
		   		trigger:'hover',
		   		html:true,
		   		title:'视频通话',
		   		placement:'top'
		   });

		   $("#btnFile").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'文件',
		         placement:'top'
		    });

		   $("#btnmin").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'名片',
		         placement:'top'
		    });

		   $("#place").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'位置',
		         placement:'top'
		    });
		   
		   $("#redback").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'红包',
		         placement:'top'
		    });

		   $("#userfulTextBtn").tooltip({ //鼠标移动弹出提示
		         trigger:'hover',
		         html:true,
		         title:'常用语',
		         placement:'top'
		    });

		   $("#rightTopMnue #blackListImg").tooltip({ //右上角菜单提示
		         trigger:'hover',
		         html:true,
		         title:'黑名单',
		         placement:'bottom'
		    });

		   $("#rightTopMnue #helpImg").tooltip({ //右上角菜单提示
		         trigger:'hover',
		         html:true,
		         title:'帮助',
		         placement:'bottom'
		    });

		   $("#rightTopMnue #quitImg").tooltip({ //右上角菜单提示
		         trigger:'hover',
		         html:true,
		         title:'退出',
		         placement:'bottom'
		    });

		   $("#rightTopMnue #privacyImg").tooltip({ //右上角菜单提示
		   		trigger:'hover',
		   		html:true,
		   		title:'隐私',
		   		placement:'bottom'
		   });

		   $("#rightTopMnue #passwordImg").tooltip({ //右上角菜单提示
		   		trigger:'hover',
		   		html:true,
		   		title:'密码',
		   		placement:'bottom'
		   });

		   $("#photo #myAvatar").tooltip({ //右上角菜单提示
		   		trigger:'hover',
		   		html:true,
		   		title:'个人资料',
		   		placement:'bottom'
		   });


		   /* $("#avatarForm #avatar_preview").tooltip({ //右上角菜单提示
		   		trigger:'hover',
		   		html:true,
		   		title:'点击更换头像',
		   		placement:'bottom'
		   }); */
		   $(".chat_content_avatar").tooltip({
		   		trigger:'hover',
		   		html:true,
		   		title:'个人资料',
		   		placement:'bottom'
		   })

	});


}); 


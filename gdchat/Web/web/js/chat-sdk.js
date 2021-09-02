var mySdk = {
	
	getConfig:function(callback){
		myFn.invoke({
			type:"GET",
			url : '/config',
			data : {},
			async:false,
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				} 
			},
			error : function(result) {
				if(1030102==result.resultCode){
					window.location.href = "login.html";
				}
			}
		});
	},
	getCurrentTime:function(callback){
		myFn.invoke({
			type:"GET",
			url : '/getCurrentTime',
			data : {},
			async:false,
			success : function(result) {
				if (1 == result.resultCode) {
					if(callback)
						callback(result.data);
				} 
				WEBIM.timeDelay=WEBIM.getMilliSeconds()-result.currentTime;
				console.log("timeDelay   ====> "+WEBIM.timeDelay);
			},
			error : function(result) {
			}
		});
	},
	getAccessToken : function() {
		if (!isNil(myData.access_token))
			return myData.access_token;

		myFn.invoke({
			async : false,
			url : '/user/login',
			data : {
				telephone : myData.telephone,
				password : myData.password
			},
			success : function(result) {
				if (1 == result.resultCode) {
					myData.access_token = result.data.access_token;
				}
			},
			error : function(result) {
				ownAlert(2,result);
			}
		});
		return myData.access_token;
	},
	autoLogin:function(callback){
		myFn.invoke({
			async : false,
			url : '/user/login/auto',
			data:{},
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				}
			},
			error : function(result) {
				ownAlert(2,result);
			}
		});
	},
	getUser : function(userId,callback,isHttp) {
		var value=DataMap.userMap[userId];
		if(!isHttp){
			if (myFn.isNil(value)) {
				value = CustomerService.customerMap[userId];
			}
			if(myFn.notNull(value))
				return callback(value);
		}
		myFn.invoke({
			url : '/user/get',
			data : {
				userId : userId
			},
			async:false,
			success : function(result) {
				if (1 == result.resultCode) {
					DataMap.userMap[userId]=result.data;
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	getLastChatList:function(startTime,callback){
		
		
		var endTime=0;
		var pageSize=20;
		myFn.invoke({
			url : '/tigase/getLastChatList',
			data : {
				startTime:startTime,
				endTime:endTime,
				pageSize:pageSize
			},
			async:false,
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	getUserOnLine : function(userId, callback) {
		myFn.invoke({
			url : '/user/getOnLine',
			data : {
				userId : userId
			},
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	//获取好友设置
	getSetting : function(userId,callback) {
		var value=DataMap.userSetting[userId];
		if(myFn.notNull(value))
			return callback(value);
		myFn.invoke({
			url : '/user/settings',
			data : {
				userId : userId,
			},
			success : function(result) {
				if (1 == result.resultCode) {
					DataMap.userSetting[userId]=result.data;
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	updateUser:function(obj,callback){
		myFn.invoke({
			url : '/user/update',
			data : obj,
			success : function(result) {
				if (1 == result.resultCode) {
					ownAlert(1,"资料更新成功");
					myData.user=result.data;
					myData.nickname=myData.user.nickname;
					callback(result.data);
					
				} else {
					ownAlert(2,result.resultMsg);
				}
			},
			error : function(result) {
				ownAlert(2,"资料更新失败，请稍后再试！");
			}
		});
	},
	/*下载所有好友*/
	downloadAllFriends : function(callback) {
		myFn.invoke({
			url : '/friends/page',
			data : {
				userId : myData.userId,
				pageIndex : 0,
				status:2,
				pageSize : 500
			},
			success : function(result) {
				if (1 == result.resultCode) {
					if(myFn.isNil(result.data)||myFn.isNil(result.data.pageData)){
						callback();
						return;
					}
					var pageData=result.data.pageData;
					for (var i = 0; i <pageData.length; i++) {
						var obj = pageData[i];
						//缓存好友
						DataMap.friends[obj.toUserId]=obj;
					}
					callback();
				}
			},
			error : function(result) {
				shikuLog("获取好友失败");
			}
		});
	},
	getFriendsList : function(userId,keyword,status,pageIndex, callback,transpond) {
		//keyword 关键字搜索
		/*status
			1 单向关注
			2 好友
			0 陌生人
		*/
		var pageSize=15;
		/*if(!transpond){
			if(myFn.isNil(pageIndex)){
				pageIndex=0;
				pageSize=8;
			}else if(pageIndex==0){
				pageSize=8;
			}else {
				pageSize=10;
			}
		
		}*/
		
		myFn.invoke({
			url : '/friends/page',
			data : {
				userId : userId,
				pageIndex : pageIndex,
				status:status,
				keyword:keyword,
				pageSize : pageSize
			},
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				}
			},
			error : function(result) {
				ownAlert("获取好友失败");
			}
		});
	},
	getFriends : function(toUserId,callback,isHttp) {
		var value=DataMap.friends[toUserId];
		if(!isHttp){
			if(myFn.notNull(value))
				return callback(value);
		}
		var reg = /^[0-9]*$/;
		if(!reg.test(toUserId)){
			return null;
		}

		myFn.invoke({
			url : '/friends/get',
			data : {
				toUserId : toUserId
			},
			success : function(result) {
				if (1 == result.resultCode) {
					DataMap.friends[toUserId]=result.data;
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	getNewFriendsList : function(userId,pageIndex, callback) {
		
		if(myFn.isNil(pageIndex))
			pageIndex=0;
		myFn.invoke({
			url : '/friends/newFriendListWeb',
			data : {
				userId : userId,
				pageIndex : pageIndex,
				pageSize : 10
			},
			success : function(result) {
				if (1 == result.resultCode) {
					callback(result.data);
				}
			}
		});
	},
	//加关注  已废弃  直接加好友
	addAttention : function(toUserId,callback) {
		if(toUserId==myData.userId){
			ownAlert(3,"不能加自己为好友!");
			return;
		}
		myFn.invoke({
			url : '/friends/attention/add',
			data : {
				toUserId : toUserId
			},
			success : function(result) {
				/*if (1 == result.resultCode) {
					//发送新关注 信息
					var msg=null;
					var type=508;
					if(1==result.data.type){
						type=MessageType.Type.NEWSEE;
						//单向关注
						UI.showSeeHai(result.data.toUserId);
					}
					else if(2==result.data.type||4==result.data.type){
						type=MessageType.Type.PASS;
						//成为好友
					}
					var msg=WEBIM.createMessage(type,"",toUserId,null);
					UI.sendMsg(msg,toUserId);
					callback(result.data);
					UI.changeDetailsBtn(toUserId,0); //更改UI
					DataMap.friends[toUserId]=null;
					
				} */
                callback(result.data);
			},
			error : function(result) {
				ownAlert(2,"添加失败,请重试");
			}
		});
	},
	addFriends:function(toUserId,callback,toUserName){
		if(toUserId==myData.userId){
			ownAlert(3,"不能加自己为好友!");
			return;
		}
		console.log("=================> sdk > addFriends "+toUserId);
		myFn.invoke({
			url : '/friends/add',
			data : {
				toUserId : toUserId
			},
			success : function(result) {
				if (1 == result.resultCode) {
					//发送新关注 信息
					
					var type=508;
					var msg=WEBIM.createMessage(type,"",toUserId,toUserName);
					UI.sendMsg(msg,toUserId);
								
					UI.changeDetailsBtn(toUserId,0); //更改UI
					DataMap.friends[toUserId]=null;
					callback(result.data);
					
				} 
			},
			error : function(result) {
				ownAlert(2,"添加失败,请重试");
			}
		});
	},
	//删除好友
	deleteFriends: function(toUserId,callback) {

		ownAlert(4,"确定删除该好友？",function(){

				myFn.invoke({
					url : '/friends/delete',
					data : {
						toUserId : toUserId,
					},
					success : function(result) {
						if (1 == result.resultCode) {
							//发送删除好友 信息
							var msg=WEBIM.createMessage(MessageType.Type.DELALL,"",toUserId,null);
							UI.sendMsg(msg,toUserId);
							DataMap.friends[toUserId]=null;
							UI.hideChatBodyAndDetails();
							$("#myMessagesList #friends_"+toUserId).remove();
							console.log($("#myFriendsList #friends_"+toUserId));
                            $("#myFriendsList #friends_"+toUserId).remove();
							UI.changeDetailsBtn(toUserId,0); //更改UI
							//删除好友后将数据从好友和关注UserId map中清除
							delete DataMap.allFriendsUIds[toUserId];
							DataUtils.deleteFriend(toUserId);
                            UI.showFriends(0);
						}
					},
					error : function(result) {
					}
				});
			
		});
		
		
	},
	deleteAttention : function(toUserId,callback) { //取消关注
		myFn.invoke({
			url : '/friends/attention/delete',
			data : {
				toUserId : toUserId,
			},
			success : function(result) {
				if (1 == result.resultCode) {
					//发送取消关注 信息

					var msg=WEBIM.createMessage(MessageType.Type.DELSEE,"",toUserId,null);
					UI.sendMsg(msg,toUserId);
					
					DataMap.friends[toUserId]=null;
					
					UI.showFriends(0);
					UI.hideChatBodyAndDetails();	
					$("#myMessagesList #friends_"+toUserId).remove();	
					UI.changeDetailsBtn(toUserId,0); //更改UI
					//取消关注后将数据从好友和关注UserId map中清除
					delete DataMap.allFriendsUIds[toUserId];

					DataUtils.deleteFriend(toUserId);
					
				}
			},
			error : function(result) {
			}
		});
	},
	//拉黑
	addBlacklist : function(toUserId,callback) {
			ownAlert(4,"确定拉入黑名单？",function(){
					myFn.invoke({
						url : '/friends/blacklist/add',
						data : {
							toUserId : toUserId,
						},
						success : function(result) {
							if (1 == result.resultCode) {
								var msg=WEBIM.createMessage(MessageType.Type.BLACK,"",toUserId,null);
								UI.sendMsg(msg,toUserId);
								DataMap.friends[toUserId]=null;
								UI.showFriends(0);
								UI.hideChatBodyAndDetails();
								$("#myMessagesList #friends_"+toUserId).remove();	
								// UI.changeDetailsBtn(toUserId,-1); //更改UI
								//加入黑名单后将数据添加到黑名单UserId map中
								DataMap.blackListUIds[toUserId] = toUserId;
								
								// setTimeout(function(){
								// 	UI.showNewFriends(0);
								// },2000);
							}
						},
						error : function(result) {
						}
					
				});
		});

			
	},
	//移出黑名单
	deleteBlacklist : function(toUserId,callback) {  
		console.log("移除黑名单");
		myFn.invoke({
			url : '/friends/blacklist/delete',
			data : {
				toUserId : toUserId,
			},
			success : function(result) {
				if (1 == result.resultCode) {
					var msg=WEBIM.createMessage(MessageType.Type.REFUSED,"",toUserId,null);
					UI.sendMsg(msg,toUserId);
					DataMap.friends[toUserId]=null;
					friendRelation[toUserId] = false;
					UI.showFriends(0);
					UI.hideChatBodyAndDetails();
					UI.changeDetailsBtn(toUserId,1); //更改UI
					// DataMap.userMap[toUserId].friends=0;
					//取消加入黑名单后将数据从黑名单UserId map中清除
					delete DataMap.blackListUIds[toUserId];
					//移除黑名单后将该用户从黑名单列表中移除
					$("#blackListManager #blacklist_"+toUserId+"").remove();
					// UI.showBlackList(0);

					// setTimeout(function(){
					// 	UI.showNewFriends(0);
					// },2000);
				}
					
			},
			error : function(result) {
			}

		});
		//UI.addFriends(toUserId);
		UI.showBlackList(0);
	},
	updateUserSetting:function(settingObj,callback){
		// 处理layui重复请求参数不更新的问题
		if(!myFn.isNil(settingObj.secret) && !myFn.isNil(settingObj.access_token)){
			settingObj.secret="";
			settingObj.access_token="";
		}
		myFn.invoke({
				url : '/user/settings/update',
				data : settingObj,
				success : function(result) {
					if (1 == result.resultCode) {
						
						/*$("#edit_setting").modal('hide');*/
						//ownAlert(1,"保存成功")
						if(callback)	
							callback();
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"资料更新失败，请稍后再试！");
				}
			});
	},
	getMyRoom:function(pageIndex,pageSize,callback){
		myFn.invoke({
			url : '/room/list/his',
			data : {
				pageIndex : pageIndex,
				pageSize : pageSize
			},
			success : function(result) {
				if (1 == result.resultCode){
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	getAllRoom:function(pageIndex,keyword,callback){
		//keyword 关键字搜索
		myFn.invoke({
			url : '/room/list',
			data : {
				pageIndex : pageIndex,
				pageSize : 10,
				roomName : keyword
			},
			success : function(result) {
				if (1 == result.resultCode)
					callback(result.data);
			},
			error : function(result) {
			}
		});
	},
	getRoom:function(roomId,callback){
		var value=DataMap.rooms[roomId];
		if(myFn.notNull(value))
			return callback(value);
		myFn.invoke({
			url : '/room/get',
			data : {
				roomId : roomId
			},
			success : function(result) {
				if (1 == result.resultCode){
					DataMap.rooms[roomId]=result.data;
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	//只获取群组属性 不包括 成员列表
	getRoomOnly:function(roomId,callback){
		if(myFn.isNil(roomId)){
			return null;
		}
		var value=DataMap.rooms[roomId];
		if(!myFn.isNil(value))
			return callback(value);
		myFn.invoke({
			url : '/room/getRoom',
			data : {
				roomId : roomId
			},
			success : function(result) {
				if (1 == result.resultCode){
					DataMap.rooms[roomId]=result.data;
					callback(result.data);
				}else{
					DataMap.rooms[roomId]=result.data;
					callback(result.data);
				}
			},
			error : function(result) {
			}
		});
	},
	createRoom:function(params,callback){
		myFn.invoke({
			url : '/room/add',
			data : params,
			success : function(result) {
				if (1 == result.resultCode) {
					ownAlert(1,"群组创建成功！");
					$("#newRoomModal").modal('hide');
					callback(result.data);
				} else {
					ownAlert(2,result.resultMsg);
				}
			},
			error : function(result) {
				ownAlert(2,"创建失败！请稍后再试。");
			}
		});
	},
	joinRoom:function(roomId,callback){
		myFn.invoke({
				url : '/room/join',
				data : {
					type:3,
					roomId : roomId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						callback();

					}
				},
				error : function(result) {
					ownAlert(2,result);
				}
		});
	},
	exitRoom:function(roomId,callback){
		myFn.invoke({
			url:'/room/member/delete',
			data:{
				roomId:roomId,
				userId:myData.userId
			},
			success:function(result){
				callback();
			},
			error : function(result) {
				ownAlert(2,result);
			}
		});
	},
	/*修改群组信息*/
	updateRoom:function(roomId,data,callback){
		data.roomId=roomId;
		myFn.invoke({
			url:'/room/update',
			data:data,
			success:function(result){
				callback();
			},
			error : function(result) {
				ownAlert(2,result);
			}
		});
	},
	getMembersList:function(roomId,keyword,callback){
		//群成员列表
		//keyword 关键字搜索
		myFn.invoke({
			url : '/room/member/list',
			data : {
				roomId : roomId,
				keyword:keyword
			},
			success : function(result) {
				if(1==result.resultCode){
						callback(result.data);
				}
			},
			error:function(result){
				ownAlert(2,result);
			}
		});
	},
	getMember:function(roomId,userId,callback){
		myFn.invoke({
			url:'/room/member/get',
			data:{
				roomId:roomId,
				userId:userId
			},
			success:function(result){
				if(1==result.resultCode)
						callback(result.data);
			}
		});
	},
	updateMember:function(data,callback){
		myFn.invoke({
				url:'/room/member/update',
				data:data,
				success:function(result){
					if(1==result.resultCode)
						callback(result.data);
					else{
						ownAlert(3,result.resultMsg);
					}
				}
			});
	},
	updateOfflineNoPushMsg(roomId,userId,type,offlineNoPushMsg,callback){
        myFn.invoke({
            url:'/room/member/setOfflineNoPushMsg',
            data:{
                roomId:roomId,
                userId:userId,
                type:type,
                offlineNoPushMsg:offlineNoPushMsg
            },
            success:function(result){
                if(1==result.resultCode)
                    callback(result.data);
                else{
                    ownAlert(3,result.resultMsg);
                }
            }
        });
	},
	setGroupAdmin:function(roomId,userId,type,callback){
		myFn.invoke({
			url:'/room/set/admin',
			data:{
				roomId:roomId,
				touserId:userId,
				type:type,
			},
			success:function(result){
				if(1==result.resultCode)
						callback(result.data);
				else{
					ownAlert(3,result.resultMsg);
				}
			}
		});
	},
	groupTransfer:function(roomId,toUserId,callback){
		myFn.invoke({
			url:'/room/transfer',
			data:{
				roomId:roomId,
				toUserId:toUserId
			},
			success:function(result){
				if(1==result.resultCode){
					callback(result.data);
				}else{
					ownAlert(3,result.resultMsg);
				}
			}
		});
	},
	deleteFile:function(url,callback){
		//删除文件服务器文件
		var data=WEBIM.createOpenApiSecret(); 
		data.paths=url;
		$.ajax({
			type:'POST',
			url:AppConfig.deleteFileUrl,
			data:data,
			success:function(result){
				callback(result);
			},
			error : function(result) {
				//ownAlert(2,result);
			}
		});	
		
	},
	/*locate : function(callback) {
		var script = document.createElement('script');
		if (callback)
			script.src = 'https://api.map.baidu.com/location/ip?ak=OuLCe9EHc0v6Ik5BiAE4oxfN&coor=bd09ll&callback=' + callback;
		else
			script.src = 'https://api.map.baidu.com/location/ip?ak=OuLCe9EHc0v6Ik5BiAE4oxfN&coor=bd09ll&callback=mySdk.locateCallback';
		document.body.appendChild(script);
	},*/
	locateCallback : function(result) {
		if (0 == result.status) {
			console.log("百度IP定位成功");
			var provinceName = result.content.address_detail.province;
			var cityName = result.content.address_detail.city;
			var provinceId = TB_AREAS[provinceName];
			var cityId = TB_AREAS[cityName];
			var longitude = result.content.point.x;
			var latitude = result.content.point.y;
			myData.locateParams = {
				provinceId : provinceId,
				cityId : cityId,
				longitude : longitude,
				latitude : latitude
			}
		} else
			console.log("百度IP定位失败，请求错误。");
	},
	getHistoryMessageList : function(pageIndex, cb,endTime) {
		//console.log("历史记录当前页码数:"+pageIndex);
		 endTime =Temp.minTimeSend;
		if(myFn.isNil(endTime)){
			endTime = 0;
		}
		var url = !WEBIM.isGroupChat(ConversationManager.chatType) ? '/tigase/shiku_msgs' : '/tigase/shiku_muc_msgs';
		var params = {
			pageIndex : pageIndex,
			pageSize : 20,
			endTime :Number(endTime),
			maxType:WEBIM.isGroupChat(ConversationManager.chatType)?0:200,
		};
		var receiver=WEBIM.getBareJid(ConversationManager.from);
		if(myData.userId==receiver){
			params["sender"]=myData.userId+"_"+WEBIM.resource;
			receiver=receiver+"_"+WEBIM.getResource(ConversationManager.from);
		}
		params[!WEBIM.isGroupChat(ConversationManager.chatType)? "receiver" : "roomId"]=receiver;
		myFn.invoke({
			url : url,
			data : params,
			success : function(result) {
				if (1 == result.resultCode) {
					cb(0, result.data);
				} else {
					cb(1, result.resultMsg);
				}
			},
			error : function(result) {
				cb(1, null);
			}
		});
	},
	deleteMsg:function(type,del,msgId,callback,roomJid){
		//删除消息记录
		myFn.invoke({
			    url:'/tigase/deleteMsg',
				data:{
					type:type,
					delete:del,
					messageId:msgId,
					roomJid:roomJid
					},
				success:function(result){
					if(1==result.resultCode){
						callback(result.data);
						DataUtils.deleteMessage(msgId);
					}else{
						ownAlert(2,result.resultMsg);
					}
				}			
		});	
	},
	getMessage:function(msgId,type,callback){
		var value=DataUtils.getMessage(msgId);
		if(myFn.notNull(value))
			return callback(value);
		myFn.invoke({
			    url:'/tigase/getMessage',
				data:{
					messageId:msgId,
					type:type
					},
				success:function(result){
					if(1==result.resultCode){
						DataUtils.saveMessage(result.data,msgId);
						callback(result.data);
					}
				}			
		});	
	},
	sendRedPacket:function(type,money,count,greetings,roomJid,password,callback){
		var data={
				type:type,
				money:money,
				count:count,
				password:password,
				greetings:greetings,
				roomJid,roomJid
			};
			data=WEBIM.createRedSecret(data);
			//发送红包
			myFn.invoke({
				url:'/redPacket/sendRedPacket',
					data:data,
					success:function(result){
						if(1==result.resultCode){
							callback(result.data);
						}
					}			
			});	
	},
	getRedPacket:function(packetId,callback){
		
		myFn.invoke({
			url:'/redPacket/getRedPacket',
			data:{
			 id:packetId
			},
			success:function(result){
					callback(result);
			},
			error:function(result){
				ownAlert(2,result);
			}		
		});	

	},
	openRedPacket:function(packetId,callback){
		var data={
				id:packetId
			};
			data=WEBIM.receiveRedSecret(data);
		myFn.invoke({
			url:'/redPacket/openRedPacket',
			data:data,
			success:function(result){
				callback(result);
			},
			error:function(result){
				ownAlert(2,result);
			}			
		});	

		
	},
	getRedReceivesByRedId:function(packetId,callback){//红包领取记录

		myFn.invoke({
			url:'/redPacket/getRedReceivesByRedId',
				data:{
					id:packetId,
				},
				success:function(result){
					if(1==result.resultCode){
						callback(result.data);
					}
				}			
		});	
		
	},
	loadFriendsOrBlackList : function(type){ // type : "friendList" 获取好友列表和单向关注列表的userId    type : "blackList" 黑名单列表的userId
		myFn.invoke({
			url:'/friends/friendsAndAttention',
			data:{
				userId:myData.userId,
				type:type,
			},
			success:function(result){
				if(1==result.resultCode){
					if('friendList'==type){ //获取好友列表和单向关注列表的userId 
						for (var i = 0; i < result.data.length; i++) {
						 	var fUId = result.data[i];
							DataMap.allFriendsUIds[fUId] = fUId; //存储好友列表和单向关注列表的userId 数据
						}
					}else if('blackList'==type){ //黑名单列表的userId
						for (var j = 0; j < result.data.length; j++) {
						 	var bUId = result.data[j];
							DataMap.blackListUIds[bUId] = bUId; //存储黑名单列表的userId 数据
						}
					}else{
						ownAlert(3,"参数错误");
						return;
					}
				}
			},
			error : function(result) {
			}

		});	

	},
	showLoadHistoryIcon : function(type){ // type:1 查看更多消息   type:2 loading  type:3 没有更多消息了
		
		var logHtml ="<div id='loadHistoryIcon' class='loadHistoryIcon' >";
		if (1==type) { //查看更多消息
			logHtml += "<img src='img/msgHistory.png' style='width:25px; height=25px;display:inline;'>"
					+  "<a href='#' style='font-size: 12px;' onclick='ConversationManager.loadMsgHistory();'>查看更多消息</a>";
		}else if (2==type) { //loading
			logHtml += "<img src='img/loading.gif'>";
		}else if(3==type){ //没有更多消息了
			logHtml += "<span style='font-size: 12px;'>没有更多消息了</span>";
		}			
		logHtml+="</div>";
		//清除原有的历史记录Icon显示
		$("#messageContainer #loadHistoryIcon").remove();
		$("#messageContainer").prepend(logHtml);
		// UI.scrollToEnd();

	},
	getLiveRoomList:function(pageIndex,pageSize,callback){
		myFn.invoke({
			url : '/liveRoom/list',
			data : {
				/*name:'',
				nickname:'',*/
				pageIndex : pageIndex,
				pageSize : pageSize
			},
			success : function(result) {
				if (1 == result.resultCode)
						callback(result.data);
			},
			error : function(result) {
			}
		});
	},

	

}

/**
 *  登录加固相关业务处理
 * @type {{}}
 */
var AuthorityLogin = {

    /**
     * 获取登陆随机码
     * 参数mac验签同时验登录密码，内容为apiKey + areaCode+account+ salt，
     * mac key为登录密码密文, HMACMD5算法结果取base64编码成字符串，
     * @type {string}
     */
    getLoginCode:function(obj,callback){
    	obj = ApiAuthUtils.getLoginCodeParam(obj);
		shikuLog("AuthortyLogin objParam : "+JSON.stringify(obj));
		myFn.invoke({
            type:"POST",
            url : '/auth/getLoginCode',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    if(callback)
                        callback(result.data);
                }
            },
            error : function(result) {
            }
        });
    },

    /**
	 * 获取加密私钥
	 * /authkeys/getLoginPrivateKey?userId=10010304&mac=lBKrHBAIPkPHQGxSxN60rA==&language=zh&salt=1567664162180&secret=LYZKo0ARWdNDXQ+GJfR78A==&
     */
    getLoginPrivateKey:function (obj,callback) {
    	obj = ApiAuthUtils.getLoginPrivateKeyParam(obj);
    	let that = this;
        myFn.invoke({
            type:"POST",
            url : '/authkeys/getLoginPrivateKey',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    let baseResult;
                	if(myFn.isNil(result.data)){
                		// 上传公私钥
                        AuthorityLogin.uploadLoginKey(obj,function (uploadResult) {
							if(1 == uploadResult.resultCode){
								console.log("uploadLoginKey uploadResult",JSON.stringify(uploadResult));
                                let privateKey = {};
                                privateKey.userId = obj.userId;
                                privateKey.salt = obj.salt;
                                privateKey.apiKey = AppConfig.apiKey;
                                privateKey.pwd = obj.pwd;
                                privateKey.salt = obj.salt;
                                that.getLoginPrivateKey(privateKey,function (privateKeyResult) {
                                    baseResult = privateKeyResult;
                                	return;
                                })
							}
                        });
					}
                    if(myFn.isNil(result.data)){
                        result = baseResult;
                    }
                	console.log("getLoginPrivateKey result data: "+JSON.stringify(result.data));
                	// 获取私钥
                    if(callback)
                        callback(result);
                }
            },
            error : function(result) {
            }
        });
    },

    /**
	 * 上传RSA公私钥
     */
    uploadLoginKey:function(obj,callback){
    	obj = ApiAuthUtils.uploadLoginKeyParam(obj);
    	// obj = ApiAuthUtils.uploadLoginKeyParam_Forge(obj);
        myFn.invoke({
            type:"POST",
            url : '/authkeys/uploadLoginKey',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    if(callback)
                        callback(result);
                }
            },
            error : function(result) {
            }
        });
	},

    /**
	 * 加固后的登录接口
     * @param obj
     * @param callback
     */
    getUserLoginV1:function (obj,callback) {
    	obj = ApiAuthUtils.getUserLoginV1Param_Forge(obj);
        myFn.invoke({
            type:"POST",
            url : '/user/login/v1',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    if(callback)
                        callback(result.data);
                }
            },
            error : function(result) {
            }
        });
    },

    registerV1:function (obj,callback) {
    	obj = ApiAuthUtils.userRegeditParam(obj);
        myFn.invoke({
            type:"POST",
            url : '/user/register/v1',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    if(callback)
                        callback(result.data);
                }
            },
            error : function(result) {
            }
        });
    },

    userLoginAutoV1:function (obj,callback) {
		obj = ApiAuthUtils.userAutoLoginParam(obj);
        myFn.invoke({
            type:"POST",
            url : '/user/login/auto/v1',
            data : obj,
            async:false,
            success : function(result) {
                if (1 == result.resultCode) {
                    if(callback)
                        callback(result.data);
                }
            },
            error : function(result) {
            }
        });
    }
}
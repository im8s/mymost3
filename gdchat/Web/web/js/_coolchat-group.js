$(function() {
	$("#btnCreateGroup").click(function() {
		GroupManager.createGroup();
	});
	// 删除群组
	$("#btnDelete").click(function() {
		if (GroupManager.roomData.userId = myData.userId) {

			ownAlert(4,"是否确认解散本群组？",function(){

					var roomJid=GroupManager.roomData.jid;
					myFn.invoke({
						url : '/room/delete',
						data : {
							roomId : GroupManager.roomData.id
						},
						success : function(result) {
							if (1 != result.resultCode) {
								ownAlert(2,"群组删除失败，请稍后再试。");
								return;
							}
							ownAlert(1,"群组删除成功！");
							$("#myMessagesList #groups_"+roomJid).remove();
							$("#myRoomList #groups_"+roomJid).remove();
							$("#tabCon_2").hide();
							
							$("#chatPanel").hide();
							$("#tab").hide();
							DataUtils.deleteFriend(roomJid);
							ConversationManager.isOpen = false;
							ConversationManager.from = null;
							GroupManager.showMyRoom(0);
						},
						error : function(result) {
							ownAlert(2,"群组删除失败，请稍后再试");
						}
					});

			});



		} else {
			ownAlert(3,"权限不足！");
			return;
		}
		
	});
	$("#seek").click(function(){
		var name=$("#seekkey").val();
		mySdk.getFriendsList(myData.userId,name,2, 0,function(result) {

					var html = "";
					var tbInviteListHtml = "";
					var friendsList = result.pageData;
					// 获取成员列表
					myFn.invoke({
						url : '/room/member/list',
						data : {
							roomId : GroupManager.roomData.id,

						},
						success : function(result) {
							if (1 == result.resultCode) {
								var memberList = result.data;
								
								var isMember = false;
								var obj;
								for (var i = 0; i < friendsList.length; i++) {
									 obj = friendsList[i];
									 if(10000==obj.toUserId)
									 	continue;
									 isMember = false;
									for (var j = 0; j < memberList.length; j++) {
										if (memberList[j].userId==obj.toUserId) {
											isMember = true;
											break;
										}
									}

									if (!isMember)
										tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"'  class='roundAvatar'  src='" + myFn.getAvatarUrl(obj.toUserId)
												+ "' width=30 height=30 /></td><td width=100%>&nbsp;" +myFn.getText(obj.toNickname) 
												+ "</td><td><input id='false' name='invite_userId' type='checkbox' onclick='Checkbox.checkedAndCancel(this)' value='" + obj.toUserId
												+ "' /></td></tr>";

								}
								if ("" == tbInviteListHtml) {
									ownAlert(3,"没有搜索到好友！");
								} else {
									$("#tbInviteList").empty();
									$("#tbInviteList").append(tbInviteListHtml);
									$("#memberInviteDialog").modal('show');
								}
							}
						},
						error : function(result) {
						}
					},1);

				});
	});
	/*修改群信息设置 按钮事件*/

	// 消息免打扰
	layui.form.on('switch(btnShield)', function(data){
        // TODO 消息免打扰
		var sign = this.checked;
        mySdk.updateOfflineNoPushMsg(GroupManager.roomData.id,myData.userId ,0,sign?1:0,function () {
            DataUtils.setMsgFilters(GroupManager.roomData.jid,sign);
            console.log("=======btnShield========>>>>>>  checked: "+sign +"  isFilter : "+!sign);
        	ownAlert(3,sign?"已开启消息免打扰":"已关闭消息免打扰");
        });
  	});

	// 群置顶
	// 消息免打扰
	/*switchEvent("#tabCon_2 #btnShield",
		function(){
			var isFilter = DataUtils.getMsgFilters(GroupManager.roomData.jid);
			DataUtils.setMsgFilters(GroupManager.roomData.jid,!isFilter);
		},function(){
			var isFilter = DataUtils.getMsgFilters(GroupManager.roomData.jid);
			DataUtils.setMsgFilters(GroupManager.roomData.jid,!isFilter);
		}
	);*/

	/*全体禁言*/
	layui.form.on('switch(btnallBanned)', function(data){

  		var param  = {};
  		
		param.talkTime = (this.checked?getCurrentSeconds()+604800:0);//全体禁言 7天
		var str = (this.checked?"已开启全体禁言!":"已关闭全体禁言!");
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
			GroupManager.roomData.talkTime = param.talkTime;
			//解决 7697bug
			if (myFn.isContains(str,"已开启全体禁言!")){
				$("btnallBanned").attr("readonly","readonly");
			}
			ownAlert(3,str);
		});

  	});


	/*switchEvent("#tabCon_2 #btnallBanned",
		function(){
			var data={};
			data.talkTime=getCurrentSeconds()+604800;//全体禁言 7天
			mySdk.updateRoom(GroupManager.roomData.id,data,function(){
				GroupManager.roomData.talkTime=data.talkTime;
				ownAlert(3,"已开启全体禁言!");
			});
			
		},function(){
			var data={};
			data.talkTime=0;
			mySdk.updateRoom(GroupManager.roomData.id,data,function(){
				GroupManager.roomData.talkTime=data.talkTime;
				ownAlert(3,"已关闭全体禁言!");
			});
		}
	);*/

	//群消息已读人数
	layui.form.on('switch(openRead)', function(data){
  		var param = {};
  		var sign = this.checked;
		param.showRead = sign?1:0;
		
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
			myData.isShowGroupMsgReadNum = sign;
			GroupManager.roomData.showRead = param.showRead;
				ownAlert(3,(sign?"显示消息已读人数功能已开启!":"显示消息已读人数功能已关闭!"));
		});

  	});



	//修改群已读状态
	layui.form.on('switch(isLook)', function(data){
  		var param = {};
  		var sign = this.checked;
		param.isLook = (sign?1:0);
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
			ownAlert(3,(sign?"群组已修改为私密群 !":"群组已修改为公开群 !"));
		});
  	});



	//进群验证
	layui.form.on('switch(isNeedVerify)', function(data){
  		var param = {};
  		var sign = this.checked;
  		console.log("sign:"+sign);
		data.isNeedVerify = (true == sign?1:0);
        param.isNeedVerify = data.isNeedVerify;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.isNeedVerify = param.isNeedVerify;
			ownAlert(3,(sign?"已开启进群验证功能 !":"已关闭进群验证功能 !"));
		});
  	});


	//显示群成员列表
	layui.form.on('switch(showMember)', function(data){
  		var param = {};
  		var sign = this.checked;
		data.showMember = (true == sign?1:0);
		param.showMember = data.showMember;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.showMember = param.showMember;
			ownAlert(3,(sign?"已开启显示群成员列表功能 !":"已关闭显示群成员列表功能 !"));
		});
  	});

	

	//普通群成员私聊
	layui.form.on('switch(allowSendCard)', function(data){
  		var param = {};
  		var sign = this.checked;
		data.allowSendCard = (true == sign?1:0);
		param.allowSendCard = data.allowSendCard;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.allowSendCard = param.allowSendCard;
           		var flag = ConversationManager.checkGroupOwnerRole(GroupManager.roomData.id,myData.userId);
				/*if(sign){
					$("#btnmin").show();
				}else if(sign == false && flag == false){
					$("#btnmin").hide();
				}*/
				ownAlert(3,(sign?"已允许普通群成员私聊 !":"已禁止普通群成员私聊 !"));
		});
  	});


	//允许群成员邀请好友
	layui.form.on('switch(allowInviteFriend)', function(data){
  		var param = {};
  		var sign = this.checked;
		data.allowInviteFriend = (true == sign?1:0);
		param.allowInviteFriend = data.allowInviteFriend;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.allowInviteFriend = param.allowInviteFriend;
				ownAlert(3,(sign?"已允许群成员邀请好友 !":"已禁止群成员邀请好友!"));
		});
  	});


	//允许群成员上传共享文件
	layui.form.on('switch(allowUploadFile)', function(data){
  		var param = {};
  		var sign = this.checked;
		data.allowUploadFile = (true == sign?1:0);
		param.allowUploadFile = data.allowUploadFile;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.allowUploadFile = param.allowUploadFile;
				ownAlert(3,(sign?"已允许群成员上传共享文件 !":"已禁止群成员上传共享文件!"));
		});
  	});

	//允许群成员发起会议
	layui.form.on('switch(allowConference)', function(data){
  		var param = {};
  		var sign = this.checked;
		data.allowConference = (true == sign?1:0);
		param.allowConference = data.allowConference;
		mySdk.updateRoom(GroupManager.roomData.id,param,function(){
				GroupManager.roomData.allowConference = param.allowConference;
				ownAlert(3,(sign?"已允许群成员发起会议 !":"已禁止群成员发起会议!"));
		});
  	});


	//创建群组 的窗口按钮切换事件

	/*--------------------------------------------*/
	
	
	// 群成员管理
	$("#btnKicking").click(function() {
		mySdk.getMembersList(GroupManager.roomData.id,null,function(obj){
			var tbMemberListHtml = "";
			var role;

			for (var i = 0; i < obj.length; i++) {
				if (myData.userId == obj[i].userId) {
					role = obj[i].role;
					break;
				}
			}      
			// 成员角色：1=创建者、2=管理员、3=成员
			for (var i = 0; i < obj.length; i++) {
				if(myData.userId!=obj[i].userId)
					obj[i].nickname=1==role?DataUtils.getGroupMsgFromUserName(obj[i],obj[i].userId,obj[i].nickname):obj[i].nickname;
				tbMemberListHtml += "<tr id='tr_member_" + obj[i].userId + "'><td width=30><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj[i].userId)
						+ "' width=30 height=30  class='roundAvatar'/></td><td width=120 class='text-length'>" + myFn.getText(obj[i].nickname,15) + "</td>";
				if (1 == role) { //判断我的身份 我是创建者
					if(2==obj[i].role){ //管理员

						tbMemberListHtml += "<td id='replace_"+obj[i].userId+"'><a href='javascript:GroupManager.setAdmin(\""+GroupManager.roomData.id+"\","+obj[i].userId+","+3+")'>取消管理员</a></td><td><a href='javascript:GroupManager.removeMember(\"" + GroupManager.roomData.id + "\","
							+ obj[i].userId + ",\"" + obj[i].nickname
							+ "\");'>踢出</a></td>"
							+"<td width=50><a href='javascript:GroupManager.setTalkTime(\"" + GroupManager.roomData.id + "\","
							+ obj[i].userId + ",\"" + obj[i].nickname + "\","+obj[i].talkTime+");'>禁言</a></td>"
							+"<td width=50><a href='javascript:memberRemarkName(\"" + obj[i].userId + "\");'>备注</a></td>";

					}else if(1==obj[i].role){ //创建者自己

						tbMemberListHtml += "<td></td><td id='replace_"+obj[i].userId+"' colspan='3'>"
										 +   "<img src='img/creater.png' class='groupMenberIdent'>"
										 +"</td>";

					}else{ //普通用户
						tbMemberListHtml += "<td id='replace_"+obj[i].userId+"'><a href='javascript:GroupManager.setAdmin(\""+GroupManager.roomData.id+"\","+obj[i].userId+","+2+")'>设为管理员</a></td><td><a href='javascript:GroupManager.removeMember(\"" + GroupManager.roomData.id + "\","
							+ obj[i].userId + ",\"" + obj[i].nickname
							+ "\");'>踢出</a></td><td width=50><a href='javascript:GroupManager.setTalkTime(\"" + GroupManager.roomData.id + "\","
							+ obj[i].userId + ",\"" + obj[i].nickname + "\","+obj[i].talkTime+");'>禁言</a></td>"
							+"<td width=50><a href='javascript:memberRemarkName(\"" + obj[i].userId + "\");'>备注</a></td>";

					}

					
						
				} else if (2 == role) { //我是管理员
						//判断成员身份
						if(2==obj[i].role){ //管理员
							
							tbMemberListHtml += "<td id='replace_"+obj[i].userId+"' colspan='3'>"
										 +   "<img src='img/admin.png' class='groupMenberIdent'>"
										 +"</td>";
						}else if(1==obj[i].role){ //创建者

							tbMemberListHtml += "<td id='replace_"+obj[i].userId+"' colspan='3'>"
										 +   "<img src='img/creater.png' class='groupMenberIdent'>"
										 +"</td>";

						} else {
							tbMemberListHtml += "<td width=50><a href='javascript:GroupManager.removeMember(\"" + GroupManager.roomData.id + "\","
								+ obj[i].userId + ",\"" + obj[i].nickname
								+ "\");'>踢出</a></td><td width=50><a href='javascript:GroupManager.removeMember(\"" + GroupManager.roomData.id + "\","
								+ obj[i].userId + ",\"" + obj[i].nickname + "\","+obj[i].talkTime+");'>禁言</a></td>";
						}
						
				} else if (3 == role) { //我是普通成员
						//判断成员身份
						if(2==obj[i].role){ //管理员
							
							tbMemberListHtml += "<td id='replace_"+obj[i].userId+"' colspan='3'>"
										 +   "<img src='img/admin.png' class='groupMenberIdent'>"
										 +"</td>";
						}else if(1==obj[i].role){ //创建者

							tbMemberListHtml += "<td id='replace_"+obj[i].userId+"' colspan='3'>"
										 +   "<img src='img/creater.png' class='groupMenberIdent'>"
										 +"</td>";

						} 
				}
				
				
				tbMemberListHtml += "</tr>";
			}
			$("#tbMemberList").empty();
			$("#tbMemberList").append(tbMemberListHtml);
			$("#memberManagerDialog").modal('show');
			});

		});
	

	//提交群组新名称
	$("#submit").click(function(){

		var roomName=$("#newgroupname").val();
		 var reg=new RegExp("^[\u4e00-\u9fa5A-Za-z0-9-_]*$");
		
		if(roomName==""){
			ownAlert(3,"请输入群名称");
		}
		if(roomName.length>20){
			ownAlert(3,"只能输入20个字符！");
			return;
		}
		if(!reg.test(roomName)){
			ownAlert(3,"输入有误 只能输入 中文 英文 数字!")
			return;
		}

		if(GroupManager.roomData.userId == myData.userId){
			myFn.invoke({
				url:'/room/update',
				data:{
					roomId:GroupManager.roomData.id,
					roomName:roomName
				},
				success:function(result){
					ownAlert(1,"群组名更新成功");
					$("#groupname").modal('hide');
					$("#gname").empty();
					$("#gname").append(roomName);
					$("#myMessagesList #groups_"+GroupManager.roomData.jid+" .groupName").html(roomName);
					DataMap.rooms[GroupManager.roomData.id].name=roomName;
					GroupManager.showMyRoom(0);
				}
			});
		}else{
			ownAlert(2,"权限不足");
		}
	});
	//修改群组说明
	$("#btndesc").click(function(){
		var desc=$("#newdesc").val();
		
		if(desc==""){
			ownAlert(3,"请输入群组说明");
		}
		if(desc.length>20){
			ownAlert(3,"只能输入20个字符！");
			return;
		}
		myFn.invoke({
			url:'/room/update',
			data:{
				roomId:GroupManager.roomData.id,
				desc:desc
			},
			success:function(result){
				$("#groupdesc").modal("hide");
				$("#gdesc").empty();
				$("#gdesc").append(desc);
				ownAlert(1,"修改群组说明成功");

			}
		})
	});
	//修改公告
	$("#btnNotice").click(function(){
        //禁止点击按钮  ---  解决一秒内多次点击发布公告功能
        $("#btnNotice").attr('disabled',true);

		var notice=$("#newNotice").val();
		if(notice==""){
			ownAlert(3,"请输入新公告");
            //开启点击按钮
            $("#btnNotice").attr('disabled',false);
		}
		if(notice.length>100){
			ownAlert(3,"只能输入100个字符！");
            //开启点击按钮
            $("#btnNotice").attr('disabled',false);
			return;
		}

		myFn.invoke({
			url:'/room/update',
            data:{
				roomId:GroupManager.roomData.id,
				notice:notice,
			},
			isShowAlert:false,
			success:function(result){
               $("#gnotice").empty().text(notice);
				ownAlert(1,"发布公告成功");
				 $("#groupnotice").modal("hide");
			}
		});

		//解决 发布公告问题 bug
        setTimeout(function(){
            //开启点击按钮
            $("#btnNotice").attr('disabled',false);
		}, 1000);

	});
	
	// 邀请好友
	$("#btnInvite").click(function() {
		Checkbox.cheackedFriends = {};  //清空储存的数据
		Checkbox.checkedNames=[];
		Temp.friendListType="InviteFriends";
		InviteFriends(0);
	});

	/*群主转让*/
	$("#groupTransferDiv").click(function(){
		mySdk.getMembersList(GroupManager.roomData.id,null,function(obj){
			var tbMemberListHtml = "";
			$("#tbMemberList").empty();
			// 成员角色：1=创建者、2=管理员、3=成员
			for (var i = 0; i < obj.length; i++) {
				if(1==obj[i].role)
					continue;
				tbMemberListHtml += "<tr class='trTransferMember' id='tr_member_" + obj[i].userId + "' style='border-bottom: 1px solid #eeeeee;'>"
				+"<td width='60px;'>"
					+"<img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj[i].userId)
					+ "' width=30 height=30  class='roundAvatar'/>"
				+"</td>";
				tbMemberListHtml+="<td id='replace_"+obj[i].userId+"' width='120px;' >";
				 
				 if(2==obj[i].role)
				 	tbMemberListHtml+="<img src='img/admin.png' class='groupMenberIdent'> 管理员";
				else
					tbMemberListHtml+=" &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;普通成员";
				
				tbMemberListHtml+="</td>"
					+"<td class='text-length'>&nbsp;" + myFn.getText(obj[i].nickname,10) + "</td>"
					+"<td >&nbsp;"
					+"<a href='javascript:void(0);' "
					+" onclick='GroupManager.transfer(\"" + GroupManager.roomData.id + "\",\""	+ obj[i].userId + "\",\""+obj[i].nickname+"\")' >转让给他</a></td>"
				+"</tr>";
			}
			
			$("#tbMemberList").append(tbMemberListHtml);
			$("#memberManagerDialog").modal('show');
			});
	});


});

function InviteFriends(pageIndex){
	// 获取好友列表
	mySdk.getFriendsList(myData.userId,null,2,pageIndex,function(result) {
		var html = "";
		var tbInviteListHtml = "";
		var friendsList = result.pageData;
		// 获取成员列表
		mySdk.getMembersList(GroupManager.roomData.id,null,function(memberList){
			

			var friendsList = result.pageData;
			var obj=null;
			var isMember=false;
			var inputItem ;
			var choosedUIds = Checkbox.parseData(); //调用方法获取已勾选的好友
			for(var i = 0; i < friendsList.length; i++){
				 obj = friendsList[i];

				 //解决bug  8148  公众号不能添加问题
                if (6==obj.fromAddType){
					continue;
                }
				 if(10000==obj.toUserId)
				 	continue;
				 isMember=false;
				for (var j = 0; j < memberList.length; j++) {
					if (memberList[j].userId==obj.toUserId) {
						isMember = true;
						break;
					}
				}
				if(isMember)
					continue;

				  inputItem = "<input id='false' name='invite_userId' type='checkbox' nickname='"+obj.toNickname+"' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
				 if(0 != choosedUIds.length){
					 for (var j = 0; j < choosedUIds.length; j++) {
					 	 cUId = choosedUIds[j]
					 	 if(obj.toUserId == cUId){
					 	 	inputItem = "<input id='false' name='invite_userId' type='checkbox' checked='checked' nickname='"+obj.toNickname+"' value='" + obj.toUserId + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
					 	 }
				 	}	 
				 }
				tbInviteListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.toUserId)
				+ "' width=30 height=30 class='roundAvatar'/></td><td width=100%>&nbsp;" +myFn.getText(obj.toNickname)
				+ "</td><td>"+inputItem+"</td></tr>";
			}
			var pageHtml = GroupManager.createPager(pageIndex, result.pageCount,'InviteFriends');
			$("#memberInviteDialog #cardPage").empty().append(pageHtml);
			$("#tbInviteList").empty();
			$("#tbInviteList").append(tbInviteListHtml);
			$("#memberInviteDialog").modal('show');

		});
	});
};


//群文件
function groupfile(){


		$("#btnUploadGroupFile").show();
		if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowUploadFile){
	  		 $("#btnUploadGroupFile").hide();
	  	}
		myFn.invoke({
			url:'/room/share/find',
			data:{
				roomId:GroupManager.roomData.id
			},
			success:function(result){

				var fileList=result.data;

				var tbInviteListHtml = "";

				for(var i=0;i<fileList.length;i++){
					var obj=fileList[i];
					var fileName=obj.name.substring(0,obj.name.indexOf("."));

					tbInviteListHtml += '<div class="groupFile">'
									 +	  '<div style="float: left;"><img src="./img/file.png" style="width:35px"></div>'
									 +	  '<div class="info">'
									 +		'<p class="fileName">'+obj.name+'</p>'
									 +		'<p class="fileData"><span>大小:'+myFn.parseFileSize(obj.size)+'</span><span style="margin-left:20px;">上传者:'+obj.nickname+'</span></p>'
									 +	  '</div>'					
									 +	  '<div class="timeStr"><p>'+getTimeText(obj.time,0,1)+'</p></div>'
									 +	  '<div class="option">'
									 +		 '<a target="_blank" href="'+obj.url+'" download="'+fileName+'">'
									 +			'<button title="下载文件" class="btn_download"> <img src="./img/download.png"></button>'
									 +		 '</a>';

					if(myData.userId==obj.userId||3>GroupManager.roomData.member.role){
						tbInviteListHtml +=	'<button title="删除文件" class="btn_delete" onclick="GroupManager.deletefile(\''+obj.shareId+'\')">'
									 	 +		'<img src="./img/delete.png">'
					}				     +  '</button>';

					tbInviteListHtml += '</div>'
									 +'</div>';
				}
				$("#gfile").empty();
				$("#gfile").append(tbInviteListHtml);
				$("#findgroupfile").modal('show');

				
			}
		});

		
}
//群昵称
function groupNickname(){
	Temp.updateNameType="groupNickName";
	$("#myModalLabel").html("修改群昵称");
	$("#newNickname").val($("#gnickname").html());
	$("#updategname").modal("show");
}
function memberRemarkName(userId){
	Temp.updateNameType="memberRemarkName";
	Temp.memberUserId=userId;
	var member=Temp.members[userId];
	$("#myModalLabel").html("修改成员备注");
	if(!myFn.isNil(member.remarkName))
		$("#newNickname").val(member.remarkName);
	else
		$("#newNickname").val("");
	$("#updategname").modal("show");
	$("#memberManagerDialog").modal('hide');


}


//群公告
function noticeInfo(pageIndex){
	$("#groupBulletinInfo").modal("show");
	// 填充公告数据
    getNotices(GroupManager.roomData.id,pageIndex,function(obj){
        var noticesInfoHtml = "";
        $("#noticesInfo").empty();
		console.log("群公告详情："+JSON.stringify(obj.pageData));
		if(0==obj.pageData.length){
			$("#noticesInfo").append("暂无数据");
		}else{
			for (var i = 0; i < obj.pageData.length; i++) {
            var time =new Date(obj.pageData[i].time*1000).format("yyyy-MM-dd hh:mm:ss");
            noticesInfoHtml+="<div id='notice_"+obj.pageData[i].userId+"' style='border-bottom:1px solid #EEF0F5' >" +
               "<table onclick='showNotice(\""+obj.pageData[i].text+"\",\""+$("#gname").html()+"\")'><tr><td width='40px'><img width='30' height='30' class='roundAvatar' onerror='this.src=\"img/ic_avatar.png\"' src='"+myFn.getAvatarUrl(obj.pageData[i].userId)+"'></td>" +
				"<td width='150px'><span>"+obj.pageData[i].nickname+"</span></td>" +
				"<td width='150px'><span>"+time+"</span></td>" +
				"</tr></table>"
				+"<button type='button' class='btn btn-danger' data-target='#exampleModal' data-whatever='@mdo' style='float:right;position:relative ;height: 25px;line-height: 0.912857143px;bottom:20px;right:10px;'" +
				" onclick='deleteNotice(\"" + obj.pageData[i].roomId + "\",\""+obj.pageData[i].id+ "\")'>删除</button>"
				+"<div style='margin-top:5px'><p style='margin-left: 48px'>"+(obj.pageData[i].text.length>22?obj.pageData[i].text.substring(0,22)+"...":obj.pageData[i].text)+"</p></div>" +
				"</div>";
			}
        	$("#noticesInfo").append(noticesInfoHtml);

		}
        
        var pageHtml = GroupManager.createPager(pageIndex, obj.pageCount,'noticeInfo');
        $("#groupBulletinInfo #noticesCardPage").empty().append(pageHtml);

       
        $("#groupBulletinInfo").modal('show');
    });
}

// 展示完整的群公告model
function showNotice(noticeContent,companyName){
    var noticeHtml = "<div id='noticeModal' class='modal fade' tabindex='-1' role='dialog' aria-labelledby='myModalLabel' aria-hidden='true'>"
        +	"<div class='modal-dialog' style='width: 100%;max-width:600px;margin-top:60px'>"
        +		"<div class='modal-content'>"
        +			"<div class='modal-header'>"
        +				"<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>"
        +				"<h4 class='modal-title' id='myModalLabel'>"+companyName+"公告</h4>"
        +			"</div>"
        +			"<div class='modal-body' id='myModalLabelContent'>"
        +				(myFn.isNil(noticeContent) ? "暂无公告" : noticeContent)
        +			"</div>"
        +		"</div>"
        + 	"</div>"
        + "</div>"

    $("#showGroupNotices").empty().append(noticeHtml);
    $("#noticeModal").modal('show');
};


//删除公告
function deleteNotice(roomId,noticeId) {
	

	//权限判断
    var flag=ConversationManager.checkGroupOwnerRole(roomId,myData.userId);
    if(!flag){
        ownAlert(2,"权限不足");
        return;
    }
  
    myFn.invoke({
        url : '/room/notice/delete',
        data : {
            roomId : roomId,
            noticeId :noticeId
        },
        success : function(result) {
            if(1==result.resultCode){
                ownAlert(2,"删除成功");
                $("#noticeModal").modal('hide');
                $("#groupBulletinInfo").modal("hide");

            }
        },
        error:function(result){
            ownAlert(2,result);
        }
    });
}

// 获取公告列表
function getNotices(roomId,pageIndex,callback){
    if(myFn.isNil(pageIndex))
        pageIndex=0;
    console.log("roomId:  "+roomId);
    myFn.invoke({
        url : '/room/noticesPage',
        data : {
            roomId : roomId,
			pageIndex : pageIndex,
            pageSize : 10
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
}


//发布群公告
function notice(){
	console.log("发布公告权限："+Temp.roomRole);
    if(Temp.roomRole>=3){
        ownAlert(3,"权限不足！");
        return;
    }
    // $("#newNotice").val($("#gnotice").html());
    $("#groupnotice").modal("show");
    $("#groupBulletinInfo").modal("hide");
    $("#newNotice").val("");
}
//群组说明
function roomstate(){
	if(Temp.roomRole>=3){
		ownAlert(3,"权限不足！");
		return;
	}
	$("#newdesc").val($("#gdesc").html());
	$("#groupdesc").modal("show");
}
//群名称
function chengRoomname(){
	if(Temp.roomRole>=3){
		ownAlert(3,"权限不足！");
		return;
	}
	$("#newgroupname").val($("#gname").html());
	$("#groupname").modal("show");
}
//退出群聊
function exitgrounp(){
	
	ownAlert(4,"确认退出该群组吗？",function(){
		GroupManager.exitRoom();
	});
	
}
var GroupManager = {
	roomData : null,
	roomCard:null,//群名片
	filters : {},
	//显示所有群组
	showAllRoom : function(pageIndex,keyword) {
		$("#myRoomList").hide();
		$("#btnMyRoom").removeClass("border");
		$("#btnAllRoom").addClass("border");
		//var keyword=$("#allRoomList #keyword").val();
		mySdk.getAllRoom(pageIndex,keyword,function(result){
					var html = "";
					if(myFn.isNil(result.length)||0==result.length){
						
						return;
					}
					for (var i = 0; i < result.length; i++) {
						var obj = result[i];
						DataMap.rooms[obj.id]=obj;
						html += GroupManager.createItem(obj);
					}
				if(myFn.isNil(html)){
					
					return;
				}
				html += GroupManager.createPager(pageIndex, result.length, 'GroupManager.showAllRoom');
					$("#_allRoomList").empty();
					$("#_allRoomList").append(html);
					$("#allRoomList").show();
					$("#btnMyRoom").removeClass("border");
					$("#btnAllRoom").addClass("border");
		});
		//$("#allRoomList #keyword").val('');
	},
	//显示我的群组
	showMyRoom : function(pageIndex) {
		$("#allRoomList").hide();
		$("#o").show();
		$("#privacy").hide();
		//隐藏聊天面板
		//UI.hideChatBodyAndDetails();
		$("#prop").hide();
		$("#companyTab").hide();
		$("#liveRoomTab").hide();
		$("#roomTab").show();
		$("#setPassword").hide();

		$("#search_all_room").val("");

		mySdk.getMyRoom(pageIndex,10,function(result){
			var html = "";
			var roomId=null;
			if(undefined==result||0==result.length){
				return;
			}
			for (var i = 0; i <result.length; i++) {
				var obj = result[i];
				var delRoom=DataUtils.getDeleteFirend(obj.jid);
				if(!myFn.isNil(delRoom))
					continue;
				DataMap.myRooms[obj.jid]=obj;
				DataMap.rooms[obj.id]=obj;
				if(obj.member)
					DataMap.talkTime[obj.jid]=obj.member.talkTime;
				html += GroupManager.createMyItem(obj);
			}
			if(myFn.isNil(html)){
					return;
			}

			html += GroupManager.createPager(pageIndex, result.length, 'GroupManager.showMyRoom');

			$("#myRoomList").empty();
			$("#myRoomList").append(html);
			$("#myRoomList").show();
		});
	},
	//下载我的群组
	downloadMyRoom:function(callback){
		mySdk.getMyRoom(0,100,function(result){
			if(myFn.isNil(result)){
				callback();
				return;
			}
			for (var i = 0; i < result.length; i++) {
				var obj = result[i];
				DataMap.myRooms[obj.jid]=obj;
				DataMap.rooms[obj.id]=obj;
				if(obj.member)
					DataMap.talkTime[obj.jid]=obj.member.talkTime;
			}
			callback();
		});
	},
	//加入我的群组
	joinMyRoom :function(init){
		var rooms=DataMap.myRooms;
		if(0==rooms.length){
			mySdk.getMyRoom(0,100,function(result){
				if(myFn.isNil(result))
					return;
					var obj=null;
					for (var i = 0; i < result.length; i++) {
						obj=result[i];
						DataMap.rooms[obj.id]=obj;
						DataMap.myRooms[obj.jid]=obj;
						//console.log("加入我的群组  "+obj.name);
						setTimeout(function(jid){
							WEBIM.joinGroupChat(jid, myData.userId);
						},2000,obj.jid);
						
					}
					if(1==init)
						DataUtils.setLogoutTime(0);

			});	
		}else {
			for (var i = 0; i < rooms.length; i++) {
						obj=rooms[i];
				console.log("加入我的群组  "+obj.name);
				setTimeout(function(jid){
					GroupManager.joinGroupChat(jid, myData.userId);
				},2000,obj.jid);
			}
			if(1==init)
				DataUtils.setLogoutTime(0);
		}
		

	},
	//下载文件
	downfile:function(){
		alert("down");
	},
	//删除文件
	deletefile:function(shareId){
			myFn.invoke({
				url:'/room/share/delete',
				data:{
					roomId:GroupManager.roomData.id,
					shareId:shareId,
					userId:myData.userId
				},
				success:function(result){
					ownAlert(1,"删除成功");
					groupfile();
				}
			});	
	},
	//上传
	uploadFile:function(){
		
		var groupFileUplaod  =  layui.upload.render({

		        elem: '#btnUploadGroupFile', //文件选择元素
		        accept:'file',
		        url: AppConfig.uploadUrl+'',
		        data:{
		        	fileName:"",
		        	fileSize:0,
		        	url:""
		    	},
		        progress: function(e , percent) {
		          //更新进度条
		          //document.getElementById('fileProgress_'+this.data.id+'').childNodes[0].style.cssText="width: "+percent+"%;";
		        },
		        choose: function(obj) {//选择完成事件
		          
				 obj.preview(function(index, file, result) {
		          	 //开始ui预加载
					 groupFileUplaod.config.data.fileName=file.name;
					 groupFileUplaod.config.data.fileSize=file.size;
		         });
		          
		        },
		        done: function(res) { //上传完成事件
		          
		          //移除进度条
		         /* $("#fileProgress_"+this.data.id+"").remove();*/
				  this.data.url=res.url;
				  //群文件上传
				  GroupManager.addGroupFile(this.data);
		        },
		        error: function(res) {
		          if(res.msg)
		          		layui.layer.msg(res.msg);
		        }
		});


		 
	},
	//添加群文件
	addGroupFile:function(obj){

		var fileUrl=obj.url;
		
		var fileExt=fileUrl.substr(fileUrl.lastIndexOf(".")).toLowerCase();
		var type;
		if(fileExt==".jpg"||fileExt==".png"||fileExt==".jpeg"){//图片
			type=1;
		}else if(fileExt==".mp3"||fileExt==".arm"||fileExt==".wav"){//声音
			type=2;
		}else if(fileExt==".mp4"||fileExt==".avi"||fileExt==".rm"||fileExt==".rmvb"){//视频
			type=3;
		}else if(fileExt==".ppt"){
			type=4;
		}else if(fileExt==".xlsx"||fileExt==".xls"){//excel
			type=5;
		}else if(fileExt==".doc"||fileExt==".docx"){//word
			type=6;
		}else if(fileExt==".zip"){//压缩包
			type=7;
		}else if(fileExt=="txt"){//文本文档
			type=8;
		}else if(fileExt=="pdf"){//pdf
			type=10;
		}else{
			type=9;
		}
		myFn.invoke({
			url:'/room/add/share',
			data:{
				roomId:GroupManager.roomData.id,
				type:type,
				size:obj.fileSize,
				userId:myData.userId,
				url:obj.url,
				name:obj.fileName
			},
			success:function(result){
				ownAlert(1,"上传成功");
				groupfile();
			},
			error:function(result){
				ownAlert(2,"上传失败");
			}
		});
	},
	/*updateNotice:function(){
		var notice=$("#newNotice").val();
		alert(notice);
	}*/
	//设置管理员
	setAdmin:function(roomId,userId,type){
		
		mySdk.setGroupAdmin(roomId,userId,type,function(){
			if(type==2){
				$("#replace_"+userId).empty();
				$("#replace_"+userId).append("<a href='javascript:GroupManager.setAdmin(\""+GroupManager.roomData.id+"\","+userId+","+3+")'>取消管理员</a>");
			}else{
				$("#replace_"+userId).empty();
				$("#replace_"+userId).append("<a href='javascript:GroupManager.setAdmin(\""+GroupManager.roomData.id+"\","+userId+","+2+")'>设置管理员</a>");
			}
		});
	},
	//群主转让
	transfer:function(roomId,toUserId,nickname){
		if(!confirm('确定转让群主给 ' + nickname + '？')){
			return;
		}
		mySdk.groupTransfer(roomId,toUserId,function(){
			ownAlert(3,"群主转让成功！");
			GroupManager.roomData.userId=toUserId;
			$("#groupTransferDiv").hide();
			$("#btnDelete").hide();
			$("#tabCon_2").hide();
			$("#tbMemberList").empty();
			$("#creator").empty().append(nickname);
			$("#memberManagerDialog").modal('hide');

		});
	},
	updateMemberNickName:function(userId,nickname){
		var data={};
		data.roomId=GroupManager.roomData.id;
		data.userId=userId;
		data.nickname=nickname;
		mySdk.updateMember(data,function(result){
			$("#updategname").modal("hide");
			$("#gnickname").empty();
			GroupManager.roomCard=nickname;
			$(".self .chat_nick").html(nickname);
			$("#gnickname").append(nickname);
			ownAlert(1,"修改名片成功");
		});
		
	},
	updateMemberRemarkName:function(userId,nickname){
		var data={};
		data.roomId=GroupManager.roomData.id;
		data.userId=userId;
		data.remarkName=nickname;
		mySdk.updateMember(data,function(result){
			$("#updategname").modal("hide");
			$("#memberManagerDialog").modal('show');
			var member=Temp.members[userId];
			member.remarkName=nickname;
			GroupManager.roomCard=nickname;
			
			ownAlert(1,"修改备注成功");
		});
		
	},
	createMyItem : function(obj,content,timeSend,timeSendStr) {

		
        var itemHtml =  "<div  class='' id='groups_"+obj.jid+"' onclick='GroupManager.isChoose(\"" +obj.jid + "\");'>"
				    +    "<div class='chat_item slide-left  active' onclick='GroupManager.createGroupChat(\""+ (obj.id)+ "\",\"" + obj.userId + "\",\"" + obj.jid + "\");'>"
				    +        "<div class='avatar'>"
				    +            "<img  class='img roundAvatar' src='./img/group_avatar.png' alt=''>"
				    +            "<i id='msgNum_"+obj.jid+"' class='icon web_wechat_reddot_middle'>"+ 1+"</i>"
				    +        "</div>"
				    +        "<div class='info'>"
				    +            "<div class='nickname'>"
				    +                "<span class='nickname_text'>"+ (myFn.isNil(obj.name) ? "&nbsp;&nbsp;" : obj.name)+"</span>"
				    +				 "<span id='timeSend_"+obj.jid+"' class='timeStr' value='"+timeSend+"'>"+(myFn.isNil(timeSendStr)?"":timeSendStr)+"</span>"	
				    +            "</div>"
				    +            "<p class='msg'>"
				    +                "<span id='titgroups_"+obj.jid+"'>"+ (!myFn.isNil(content)?content :myFn.isNil(obj.desc)?"无":obj.desc)+"</span>"
				    +            "</p>"
				    +        "</div>"
				    +    "</div>"
				    +"</div>";


		return itemHtml;
	},

	createItem : function(obj) {
		
		var itemHtml = "<div  id='groups_"+obj.jid+"' onclick='GroupManager.isChoose(\"" + obj.jid + "\");'>";
		
		if(!myFn.isNil(DataMap.myRooms[obj.jid]))
			itemHtml+=    "<div class='grop_item slide-left active' onclick='GroupManager.createGroupChat(\""+ (obj.id)+ "\",\"" + obj.userId + "\");'>";
		else 
			itemHtml+=    "<div class='grop_item slide-left active'>";

		if(myFn.isNil(DataMap.myRooms[obj.jid]))
			itemHtml+=        "<div class='operate' onclick='GroupManager.joinRoom(\"" + obj.id +"\");'> <p class='attr'>加入群组</p> </div>";

			itemHtml+=           "<div class='avatar'>"
				    +              "<img class='img roundAvatar'  src='./img/group_avatar.png' alt=''>"
				    +           "</div>"
				    +           "<div class='info'>"
				    +              "<h3 class='group_name'><span class='group_name_text'>"+(myFn.isNil(obj.name) ? "&nbsp;&nbsp;" : obj.name)+"</span></h3>"
				    +              "<p class='msg'>"
				    +                 "<span>"+ (myFn.isNil(obj.desc) ? "主人很懒,没有群描述~" : obj.desc)+"</span>"
				    +              "</p>"
				    +           "</div>"
				    +      "</div>"
				    +  "</div>";

		return itemHtml;
	},
	createGroupVerifyContent:function(messageId){
		return "<a onclick='GroupManager.showGroupVerify(\""+messageId+"\");' href='javascript:void(0)'>去确认</a>";
	},
	
	//处理 群控制信息的 值变化
	processGroupControlMsg: function (msg){ //用于显示群组日志
		switch(msg.contentType){
			case 901:
			 break;
			case 902:
				if(ConversationManager.isOpen&&msg.roomJid==ConversationManager.fromUserId){
					 $("#myRoomList #groups_"+msg.objectId+" .groupName").html(msg.text);
	 				$("#myMessagesList #groups_"+msg.objectId+" .groupName").html(msg.text);
				    $("#gname").html(msg.text);
				  	$("#chatPanel #chatTitle").html(msg.text);  
				}
			   
			  break;
			case 903:
			  /*GroupManager.showMyRoom(0);
			  $("#myMessagesList #groups_"+msg.objectId).html("");
			  $("#myMessagesList #groups_"+msg.objectId).remove();*/
			  break;
			case 904:
				//  被踢出群后的处理
 			  if(WEBIM.isUserId(msg.toUserId)&&!WEBIM.isGroupType(msg.chatType)){
 			  	if(myData.userId!=msg.fromUserId)
 			  		ownAlert(3,'你已被移出'+msg.text+'群');
 			  	DataMap.deleteRooms[msg.objectId]=DataMap.myRooms[msg.objectId]; //将被踢出的群的数据储存
			  	delete DataMap.myRooms[msg.objectId];
			  	UI.clearMsgNum(msg.objectId);
			  	$("#myMessagesList #groups_"+msg.objectId).remove();
			  	$("#myRoomList #groups_"+msg.objectId).remove();
			  	if(msg.objectId==ConversationManager.fromUserId){
					UI.hideChatBodyAndDetails();
				}
				// GroupManager.showMyRoom(0);
			  }
			  break;
			case 905:
			 	//群公告
			 	 //$("#myRoomList #titgroups_"+msg.objectId).html(msg.text);
			 	 if(ConversationManager.isOpen&&msg.roomJid==ConversationManager.fromUserId)
			 		$("#gnotice").html(msg.text);
			  break;
			case 906:
			  //判断被禁言者是否为用户自己
			 if(!WEBIM.isUserId(msg.toUserId))
			 	break;
			  	DataMap.talkTime[msg.objectId]=msg.talkTime;//储存我在该群组的talkTime
				 if(ConversationManager.fromUserId==msg.objectId){
				 	 ConversationManager.talkTime=Number(msg.talkTime);
				 	 GroupManager.roomData.talkTime=Number(msg.talkTime);

				 }

			  break;
			case 907:
				//被邀请加入群
				if(WEBIM.isUserId(msg.toUserId)&&!WEBIM.isGroupType(msg.chatType)){
					mySdk.getRoomOnly(msg.fileName,function(obj){
				  		DataMap.myRooms[obj.jid]=obj;
						WEBIM.joinGroupChat(msg.objectId);
				  	});
				}
				//检查该群是否存在于被踢出数据中，存在则清除
				if (!myFn.isNil(DataMap.deleteRooms[msg.objectId])) { 
					delete DataMap.deleteRooms[msg.objectId];
					//检查当前打开的是否为目标界面,是则将隐藏的详情按钮显示
					if(msg.objectId==ConversationManager.fromUserId){
						$("#tab #details").show();
					}					
				}
			  	break;
			 case 913:
			 if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
		 		if(WEBIM.isUserId(msg.toUserId)){
		 			if(1==msg.content||"1"==msg.content){
		 				GroupManager.roomData.member.role=2;
		 				$("#chatBannedDiv").hide();
		 			}else{
		 				GroupManager.roomData.member.role=3;
		 				if(getCurrentSeconds()<GroupManager.roomData.talkTime)
		 					$("#chatBannedDiv").show();
		 			}
		 			
		 		}
			 }
			case 915:
			  //群已读消息开关
			  if(msg.objectId==ConversationManager.fromUserId){
			  	if(1==msg.text||"1"==msg.text){
			  		myData.isShowGroupMsgReadNum=true;
			  	}else
			  	 	myData.isShowGroupMsgReadNum=false;
			  	GroupManager.roomData.showRead=parseInt(msg.text);
			  }
			  break;
			 case 916:
			  	if(myFn.isNil(msg.content)){

			  	}else if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  		GroupManager.roomData.isNeedVerify=parseInt(msg.text);
			  	}
			 break;
			 case 917:
			  //群公开状态
			   if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId)
				 GroupManager.roomData.isLook=parseInt(msg.text);
			 break;
			 case 918:
			  if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  	GroupManager.roomData.showMember=parseInt(msg.text);
			  	if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.showMember){
			  		 $("#btnKicking").hide();
			  	}else
			  		$("#btnKicking").show();
			  }
			 	
			 break;
			 case 919:
			  if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  		GroupManager.roomData.allowSendCard=parseInt(msg.text);
			  	if(3==GroupManager.roomData.member.role&&1!=GroupManager.roomData.allowSendCard){
					$("#btnmin").hide();
				}else{
					$("#btnmin").show();
				}
			  }
			  
			 break;

			 case 920:
			 if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			 	GroupManager.roomData.talkTime=parseInt(msg.text);
			  if(getCurrentSeconds()<GroupManager.roomData.talkTime&&
			  	3==GroupManager.roomData.member.role){
			  	$("#chatBannedDiv").show();
			  }else
			  	$("#chatBannedDiv").hide();
			 }
			  break;
			 case 921:
			  if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  	GroupManager.roomData.allowInviteFriend=parseInt(msg.text);
			  	if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowInviteFriend){
			  		 $("#btnInvite").hide();
			  	}else
			  		$("#btnInvite").show();
			  }
			 break;
			 case 922:
			   if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  		GroupManager.roomData.allowUploadFile=parseInt(msg.text);
			  		if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowUploadFile){
				  		 $("#btnUploadGroupFile").hide();
				  	}else
				  		$("#btnUploadGroupFile").show();
			   }
			 break;
			 case 923:
			 if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
		 		GroupManager.roomData.allowConference=parseInt(msg.text);
		 		if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowConference){
		 				$("#btncall").hide();
				  		 $("#btnvideo").hide();
			  	}else{
			  		$("#btncall").show();
				  	$("#btnvideo").show();
			  	}
			 }
			 break;
			  case 924:
			   if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId)
			  		GroupManager.roomData.allowSpeakCourse=parseInt(msg.text);
			 break;
			 case 925:
			 	if(ConversationManager.isOpen&&ConversationManager.fromUserId==msg.objectId){
			  		GroupManager.roomData.userId=parseInt(msg.toUserId);
			  		$("#chatBannedDiv").hide();
			  		$("#groupTransferDiv").show()
			 	}
			 break;
			default:
				break;
		}
		return msg;
	},
	//显示群设置 按钮
	showGroupSetting:function(){
		$("#chatBannedDiv").hide();
		//不允许发送名片
		if(3==GroupManager.roomData.member.role&&1!=GroupManager.roomData.allowSendCard){
			$("#btnmin").hide();
		}else{
			$("#btnmin").show();
		}
		if(1!=GroupManager.roomData.showMember&&3==GroupManager.roomData.member.role){
			//不显示群成员 只有 群主才可以查看
			$("#btnKicking").hide();
		}else{
			$("#btnKicking").show();
		}
		/*普通成员不能邀请*/
		if(3==GroupManager.roomData.member.role&&0==GroupManager.roomData.allowInviteFriend)
		  	$("#btnInvite").hide();
		 else
		  	$("#btnInvite").show();

		if(myData.userId!=GroupManager.roomData.userId)
	 		$("#groupTransferDiv").hide();
	 	else
	 		$("#groupTransferDiv").show();


	 	/* 群组详情设置开关回显*/
		var isFilter = DataUtils.getMsgFilters(GroupManager.roomData.jid);
				
		//消息免打扰
		UI.switchToggle("btnShield",(true==isFilter?1:0));

		if(myData.userId==GroupManager.roomData.userId){
			$(".groupSettingSwitchDiv").show();
			//全员禁言
			UI.switchToggle("btnallBanned",(getCurrentSeconds()<GroupManager.roomData.talkTime?1:0));

			//显示开启群已读选项
			UI.switchToggle("openRead",(1==GroupManager.roomData.showRead?1:0));

			//私密群组
			UI.switchToggle("isLook",(1==GroupManager.roomData.isLook?1:0));

			//开启进群验证
			UI.switchToggle("isNeedVerify",(1==GroupManager.roomData.isNeedVerify?1:0));

			//允许显示群成员列表
			UI.switchToggle("showMember",(1==GroupManager.roomData.showMember?1:0));

			//允许普通群成员私聊
			UI.switchToggle("allowSendCard",(1==GroupManager.roomData.allowSendCard?1:0));

			//允许普通成员邀请好友
			UI.switchToggle("allowInviteFriend",(1==GroupManager.roomData.allowInviteFriend?1:0));

			//允许普通成员上传共享文件
			UI.switchToggle("allowUploadFile",(1==GroupManager.roomData.allowUploadFile?1:0));
			
			//允许普通成员发起会议
			UI.switchToggle("allowConference",(1==GroupManager.roomData.allowConference?1:0));

		}else{
			$(".groupSettingSwitchDiv").hide();
			$("#shieldSettingDiv").show();
			if (getCurrentSeconds()<GroupManager.roomData.talkTime&&3==GroupManager.roomData.member.role) {
				$("#chatBannedDiv").show();
			}else{
				$("#chatBannedDiv").hide();
			}
			//$("#tabCon_2 #openReadDiv").show();
		}
	},
	createPager : function(pageIndex, totalPage, fnName,pageSize) {

		if(!pageSize)
			pageSize=10
		else if(0==pageIndex)
			pageSize=9;
		var pagerHtml = "<div class='pageTurning'>";  //margin-top:80px;
		if (pageIndex == 0) {
			pagerHtml += "<img style='width:21px;' alt='' src='img/on1.png'>";
			         
		} else {
			pagerHtml += "<a href='javascript:" + fnName + "(" + (pageIndex - 1) + ")" + "'>"
			             	   +      "<img style='width:21px;'  src='img/on.png'>"
			             	   +    "</a>";
		}
		pagerHtml += "<div class='pageIndex'>" + (pageIndex + 1) + "</div>";
		if ((pageIndex+1) >= totalPage) {
			pagerHtml += "<img style='width:21px;'  src='img/next1.png'>";
		} else {
			pagerHtml += "<a href='javascript:" + fnName + "(" + (pageIndex + 1) + ")" + "'> <img style='width:21px;'  src='img/next.png'> </a>";
		}
		return pagerHtml;
	},
	/**
	 * 
	 * @param userId
	 * @param groupName
	 * @param groupData
	 */
	createGroupChat : function(groupId,userId,jid) {  //groupId :群组id    userId：创建者的userId
		/*console.log("群聊进入面板........"+"\n"+"groupId:"+groupId+"userId:"+userId);
		// 开启和关闭群成员私聊后  群组和管理员可以发送名片
        var flag=ConversationManager.checkGroupOwnerRole(groupId,myData.userId);
        if(flag){
            $("#sendMsgScopeDiv #btnmin").show();
            console.log(2222);
		}*/
		UI.clearMsgNum(jid);
		DataMap.rooms[groupId]=null;

		mySdk.getRoomOnly(groupId,function(obj){
			if(null==obj){
				UI.removeGroupMessagesList(jid);
				return;
			}
			if(obj.showRead == 1 || obj.showRead == '1'){ //如果开启群已读，则更新缓存中已读状态值
				myData.isShowGroupMsgReadNum = true;
			}
			GroupManager.roomData = obj;
			DataMap.myRooms[obj.jid] = obj;
			// GroupManager.filters[GroupManager.roomData.jid] = false;
			
			ConversationManager.open(obj.jid, obj.name,groupId);
			
			ConversationManager.showAvatar(userId,1);//显示聊天窗口顶部头像(群聊)
			//获取群已读状态进行缓存
			if(0==obj.showRead || '0'==obj.showRead){
				myData.isShowGroupMsgReadNum = false;
			}else if(1==obj.showRead || '1'==obj.showRead){
				myData.isShowGroupMsgReadNum = true;
			}

			// 成员角色：1=创建者、2=管理员、3=成员
			var role =obj.member.role;
			Temp.roomRole=role;
			GroupManager.roomCard=obj.member.nickname;
			

			if (3 == role) {
				$("#btnKicking_1").empty();
				$("#btnKicking_1").append("成员列表");
			} else if (2 == role) {
				$("#btnKicking_1").empty();
				$("#btnKicking_1").append("成员管理");
			} else if (1 == role) {
				$("#btnKicking_1").empty();
				$("#btnKicking_1").append("成员管理");
			}
				
		});
	},
	createGroup : function() {
		var groupName = $("#roomName").val();
		var groupDesc = $("#roomDesc").val();
		 var reg=new RegExp("^[\u4e00-\u9fa5A-Za-z0-9-_]*$");
		if(!reg.test(groupName)){
			/*||!reg.test(groupDesc)*/
			ownAlert(3,"群名称输入有误 只能输入 中文 英文 数字!")
			return;
		}
		var groupId = myFn.randomUUID();
		var membersText = GroupManager.getMembersText();

		var isLook=$("#createGroupSetting #isLook").attr("value");
		/*
		var showRead=$("#createGroupSetting #showRead").attr("value");
		var isNeedVerify=$("#createGroupSetting #isNeedVerify").attr("value");
		var showMember=$("#createGroupSetting #showMember").attr("value");
		var allowSendCard=$("#createGroupSetting #allowSendCard").attr("value");*/

		


		if (myFn.isNil(groupName)) {
			ownAlert(3,"请输入群组名称")
			return;
		} else if (myFn.isNil(groupDesc)) {
			ownAlert(3,"请输入群组描述")
			return;
		}
		var array = eval(membersText);
		$("#btnCreateGroup").hide();
		$("#loading_1").show();
		var params = {
			jid : groupId,
			name : groupName,
			desc : groupDesc,
			isLook:isLook,
			text : membersText
		};
		mySdk.createRoom(params,function(result){
			GroupManager.showMyRoom(0);
			var msg=WEBIM.createMessage(907,groupName,myData.userId);
				msg.objectId=groupId;
				msg.fileName=result.id;
			if(1==myData.multipleDevices){
				DeviceManager.sendMsgToMyDevices(msg);
			}
			WEBIM.converGroupMsg(msg);
			msg.isGroup=1;
			UI.moveFriendToTop(msg,groupId,groupName,1);

			WEBIM.joinGroupChat(groupId);

			$("#loading_1").hide();
			$("#btnCreateGroup").show();
		});
		
	},
	//加入群聊
	joinRoom:function(roomId){
		var room=DataMap.rooms[roomId];
		if(myData.userId!=room.userId&&1==room.isNeedVerify){
		   //群组需要验证
			$('#sendRoomVerifyDiv').modal('show');
			$('#sendRoomVerifyDiv #roomNeedVerifyText').val("");
			Temp.inviteObj={};
			Temp.inviteObj.userIds=""+myData.userId;
			Temp.inviteObj.userNames=myData.nickname;
			Temp.inviteObj.roomJid=room.jid;
			Temp.inviteObj.isInvite=1;//主动加入 1  被邀请 0
			Temp.toUserId=room.userId;
			Temp.toNickname=room.nickname;	
			return;
		}
		
		mySdk.joinRoom(roomId,function(){
			ownAlert(3,"加入群成功！");
			//加入群聊
			WEBIM.joinGroupChat(room.jid);
			GroupManager.createGroupChat(roomId);
			GroupManager.showMyRoom(0);
		});
	},
	//退出群聊
	exitRoom:function(jid){
		mySdk.exitRoom(GroupManager.roomData.id,function(){
				ownAlert(1,"退出成功");
				var jid=GroupManager.roomData.jid;
				$("#myMessagesList #groups_"+jid).remove();
				$("#myRoomList #groups_"+jid).remove();
				$("#tabCon_2").hide();
				ConversationManager.cleanCurrentData();

				DataUtils.deleteFriend(jid);
				GroupManager.showMyRoom(0);
				WEBIM.exitGroupChat(GroupManager.roomData.jid);
				delete DataMap.myRooms[jid];
				// GroupManager.showAllRoom(0);
				// $("#allRoomList").hide();
		});

	},
	//发送群验证消息
	sendNeedVerify:function(){
		var reason=$("#sendRoomVerifyDiv #roomNeedVerifyText").val();
		if(myFn.isNil(reason)){
			ownAlert(3,"请输入内容！");
			return;
		}
		var inviteObj=Temp.inviteObj;
		inviteObj.reason=reason;
		var msg=WEBIM.createMessage(916,"",Temp.toUserId,Temp.toNickname);
		msg.objectId=JSON.stringify(inviteObj);
		msg.roomJid=inviteObj.roomJid;
		UI.sendMsg(msg,Temp.toUserId);
		$("#sendRoomVerifyDiv").modal("hide");
		

	},
	//显示群验证 信息
	showGroupVerify:function(messageId){
		var msg=DataUtils.getMessage(messageId);
		var inviteObj=eval("(" +msg.objectId+ ")");
		var title="邀请详情";
		var desc="";
		var reason="";
		var userHtml="";
		var imgUrl="";
		Temp.msgId=messageId;
		if("0"==inviteObj.isInvite||0==inviteObj.isInvite){
			var userIds=inviteObj.userIds.split(",");
			var userNames=inviteObj.userNames.split(",");
  			desc=msg.fromUserName+" 想邀请 "+userIds.length+" 位朋友加入群聊 ";
  			for (var i = 0; i < userIds.length; i++) {
  				imgUrl=myFn.getAvatarUrl(userIds[i]);
  				userHtml+="<div class='col-md-4' style='display:inline;' >"
					+ "  <img class='roundAvatar' alt='' alt='' onerror='this.src=\"img/ic_avatar.png\"' " 
					+		"src='"+imgUrl+"' style='width:50px;height:50px;' >"
					+ "<p> "+userNames[i]+"</p> </div>";
  			}
  		}else{
  			title="申请加入详情";
  			desc=msg.fromUserName+" 申请加入群聊 ";
  			imgUrl=myFn.getAvatarUrl(inviteObj.userIds);
  			userHtml+="<div class='col-md-4' style='display:inline;' >"
					+ "  <img class='roundAvatar' alt='' onerror='this.src=\"img/ic_avatar.png\"' "
					+		"src='"+imgUrl+"' style='width:50px;height:50px;' >"
					+ "<p> "+inviteObj.userNames+"</p> </div>";
  		}

  		$("#roomVerifyDiv").modal("show");
  		$("#roomVerifyDiv #roomVerifyTitle").html(title);
  		$("#roomVerifyDiv #roomVerifyImg").attr("src",myFn.getAvatarUrl(msg.fromUserId));
  		$("#roomVerifyDiv #roomVerifyName").html(msg.fromUserName);
  		$("#roomVerifyDiv #roomVerifyDesc").html(desc);

  		$("#roomVerifyDiv #roomVerifyReason").html(inviteObj.reason);

  		$("#roomVerifyDiv #verifyUserList").html(userHtml);
  		//接受了验证
  		if(1==msg.isAccept){
  			$("#roomVerifyDiv #roomVerifyBtn").attr("disabled",true);
  			$("#roomVerifyDiv #roomVerifyBtn").html("已确认");
  		}else{
  			$("#roomVerifyDiv #roomVerifyBtn").attr("disabled",false);
  			$("#roomVerifyDiv #roomVerifyBtn").html("确认邀请");
  		}
  		
	},
	//接受群邀请
	acceptRoomVerify:function(){
		var msg=DataUtils.getMessage(Temp.msgId);
		var inviteObj=eval("(" +msg.objectId+ ")");
		var userIds=inviteObj.userIds.split(",");
		var text = JSON.stringify(userIds);
		msg.isAccept=1;
		Temp.msgId=null;
		if (0 == userIds.length) {
			return;
		} 
		myFn.invoke({
			url : '/room/member/update',
			data : {
				roomId : GroupManager.roomData.id,
				text : text
			},
			success : function(result) {
				if (1 == result.resultCode) {
					ownAlert(1,"邀请成功。");
					$("#roomVerifyDiv").modal('hide');
				} else {
					ownAlert(2,"邀请失败，请稍后再试。");
					$("#roomVerifyDiv").modal('hide');
				}
			},
			error : function(result) {
				ownAlert(2,"邀请失败，请稍后再试。");
				$("#roomVerifyDiv").modal('hide');
			}
		});

	},
	doMemberInvite : function() {//确认邀请好友

		var myArray = Checkbox.parseData();//调用方法解析数据
		var text = JSON.stringify(myArray);
		if (0 == myArray.length) {
			ownAlert(3,"请选择要邀请的好友！");
			return;
		} 
		if(3==GroupManager.roomData.member.role&&1==GroupManager.roomData.isNeedVerify){
			//群组需要验证
			$('#sendRoomVerifyDiv').modal('show');
			$('#sendRoomVerifyDiv #roomNeedVerifyText').val("");
			Temp.inviteObj={};
			Temp.inviteObj.userIds="";
			Temp.inviteObj.userNames="";
			Temp.inviteObj.isInvite=0;
			Temp.inviteObj.roomJid=GroupManager.roomData.jid;
			Temp.toUserId=GroupManager.roomData.userId;
			Temp.toNickname=GroupManager.roomData.nickname;
			/*拼接邀请的字符串*/
			for(var i = 0; i <myArray.length; i++){
				Temp.inviteObj.userIds+=myArray[i];
				Temp.inviteObj.userNames+=Checkbox.checkedNames[myArray[i]+"uId"];
				if(i<myArray.length-1){
					Temp.inviteObj.userIds+=","
					Temp.inviteObj.userNames+=","
				}
			}
		}
		myFn.invoke({
			url : '/room/member/update',
			data : {
				roomId : GroupManager.roomData.id,
				text : text
			},
			success : function(result) {
				if (1 == result.resultCode) {
					ownAlert(1,"邀请成功。");
					$("#memberInviteDialog").modal('hide');
				} else {
					ownAlert(2,"邀请失败，请稍后再试。");
					$("#memberInviteDialog").modal('hide');
				}
			},
			error : function(result) {
				ownAlert(2,"邀请失败，请稍后再试。");
				$("#memberInviteDialog").modal('hide');
			}
		});
		

	},
	//移出成员
	removeMember : function(groupId, userId, nickname) {
		if (3!=GroupManager.roomData.member.role) {


			ownAlert(4,'是否确认踢出成员\"' + nickname + '\"？',function(){

				myFn.invoke({
					url : '/room/member/delete',
					data : {
						roomId : groupId,
						userId : userId
					},
					success : function(result) {
						if (1 == result.resultCode) {
							ownAlert(1,"成员踢出成功。");
							$("#memberManagerDialog").modal('hide');
						} else {
							ownAlert(2,"成员踢出失败，请稍后再试。")
						}
					},
					error : function(result) {
					}
				});

			});

		} else {
			ownAlert(3,"权限不足！");
		}
	},
	//禁言
	setTalkTime : function(groupId, userId, nickname,talkTime) {
		if (GroupManager.roomData.userId == myData.userId) {

			layui.layer.open({
		        type: 1
		        ,title: false
		        ,area: ['300px', '250px']
		        ,offset: 'auto' //具体配置参考：http://www.layui.com/doc/modules/layer.html#offset
		        ,id: 'setTalkTime'//防止重复弹出
		        ,content: '<div class="layui-form" style="margin-top:20px; margin-left:70px;width:150px; height:150px;">'+
		        				'<div class="layui-form-item">'+
		        					'<div class="layui-inline">'+
		                   					'<div class="layui-input-inline" style="width: 120px;">'+
				                   				'<select id="talkTime" name="talkTime">'+
				                   					(talkTime!=0?'<option value="0">取消禁言</option>':"")+
				                   			  		'<option value="1800">禁言30分钟</option>'+
				                   			  		'<option value="3600">禁言1小时</option>'+
				                   			  		'<option value="86400">禁言1天</option>'+
				                   				'</select>'+
			                   				'</div>'+
		                   			'</div>'+
		                   		'</div>'+
		                   	'</div>'
		        ,btn: ['确定']
		        ,btnAlign: 'c' //按钮居中
		        ,shade: 0 //不显示遮罩
		        ,success:function(){
		        	
		        	layui.form.render();
		        }
		        ,yes: function(){
		           
		           layui.layer.closeAll();
		           var talkTimeSeconds = parseInt($("#talkTime").val());
		           console.log("talkTime  : " + talkTimeSeconds +" 秒");
		           myFn.invoke({
						url : '/room/member/update',
						data : {
							roomId : groupId,
							userId : userId,
							talkTime : (talkTimeSeconds==0 ? 0 : (Math.round(new Date().getTime() / 1000) + talkTimeSeconds))
						},
						success : function(result) {
						
							layui.layer.msg((talkTimeSeconds==0 ? "该成员已取消禁言":"成员禁言成功"));
						},
						error : function(result) {
						}
					});
		        }
		    });


		} else {
			ownAlert(3,"权限不足！");
		}
	},
	checkKickedOut:function(){ //检查是否被踢出该群
		if (!myFn.isNil(DataMap.deleteRooms[ConversationManager.fromUserId])) { 
			ownAlert(3,"你已被踢出该群，无法查看详情");
			return;
		}
	},
	sendRead : function(messageId){ //群组,发送已读回执的流程处理
		ConversationManager.sendReadReceipt(ConversationManager.from,messageId);
		
		var readList=DataUtils.getMsgReadList(messageId);
		
		//检查是否已发
		if (readList.length!=0) { //没有数据
			for (var i = 0; i < readList.length; i++) {
				if (myData.userId ==  readList[i].userId) { //判断用户自己是否存在已读列表中，存在则不发
					return;
				}
			}
		}
		
		//缓存数据
		//发送已读回执后将自己存入消息已读列表中
		var own = new Object();
		own.userId = myData.userId;
		own.nickname = myData.nickname;
		own.timeSend = new Date().getTime()/1000;
		DataUtils.putMsgReadList(messageId,own);
		//更新已读数量
		GroupManager.changeReadNum(messageId);

	},
	disposeReadReceipt : function(msg){ //处理收到的群组已读回执
		/*if(1!=GroupManager.roomData.showRead)
			return;*/
		var readList=DataUtils.getMsgReadList(msg.content);
		
		for (var i = 0; i < readList.length; i++) {
			if (readList[i].userId==msg.fromUserId) { 
				//判断用户自己是否存在已读列表中，存在则不发
				return;
			}
		}
		

		//改变消息的已读人数
		GroupManager.changeReadNum(msg.content);
		//缓存已读用户数据
		var user = new Object();
		user.userId = msg.fromUserId;
		user.nickname = msg.fromUserName;
		user.timeSend = msg.timeSend;
		DataUtils.putMsgReadList(msg.content,user);

	},
	changeReadNum : function(messageId){ //改变消息已读数量
		/*if (myFn.isNil(groupMsgReadNum[messageId])) {
			groupMsgReadNum[messageId] = 0;
		}else{
			groupMsgReadNum[messageId] += 1;
		}*/
		var num=DataUtils.getMsgReadNum(messageId);
		num+=1;
		DataUtils.setMsgReadNum(messageId,num);
		// var num = $("#groupMsgStu_"+messageId+"").text();
		$("#groupMsgStu_"+messageId+"").text(num+"人");
		return num+"人";
	},
	showReadList:function(messageId){ //群组消息已读列表
		$("#groupReadList #readUserList").empty();
		let num=DataUtils.getMsgReadNum(messageId);
		let readList=DataUtils.getMsgReadList(messageId);
		
		if (num==0) {
			$("#groupReadList #readUserList").append("<table><tr><td><img src='img/noData.png'><span style='margin-left:20px; font-size:20px;'>暂无数据</span></td><tr><table>");
		}else{
			for (let i = 0; i < readList.length; i++) {
				let user = readList[i];
				//将数据加载到页面上
				// var imgUrl = myFn.getAvatarUrl(user.userId);
				let readTime =new Date(user.timeSend*1000).format("MM-dd hh:mm:ss");
				let userHtml = '<table id="" onclick="" style="border-radius:6px;">'
								+	'<tbody>'
								+		'<tr>'
								+			'<td rowspan="2" width="54" height="54">'
								+				'<a href="#" style="margin-left:5px;">'
								+					'<img  alt="" src="'+myFn.getAvatarUrl(user.userId)+'" onerror="this.src=\'img/ic_avatar.png\'" class="roundAvatar" width="40" height="40">'
								+				'</a>'
								+			'</td>'
								+			'<td style="font-size:13px;">'+Temp.members[parseInt(user.userId)].nickname+'</td>'
								+			'<td rowspan="2" style="font-size:12px;" width="50"></td>'
								+		'</tr>'
								+		'<tr><td class="media-desc">阅读时间:'+ readTime +'</td></tr>'
								+	'</tbody>'
								+'</table>';
				$("#groupReadList #readUserList").append(userHtml);   

			}
		

		}
		$("#groupReadList").modal('show');
	},
	destoryGroup : function(groupId) {
		if (GroupManager.roomData.userId == myData.userId) {

		} else {
			ownAlert(3,"权限不足！");
		}
	},
	isChoose : function(groupId){ //群组列表选中状态切换
		$("#myMessagesList div").removeClass("fActive");
		$("#myMessagesList #groups_"+groupId+"").addClass("fActive");
		
		$("#myRoomList").children().removeClass("fActive");
		$("#myRoomList #groups_"+groupId+"").addClass("fActive");
		
		
      $("#allRoomList #groups_"+groupId+"").addClass("fActive");
      $("#allRoomList #groups_"+groupId+"").siblings().removeClass("fActive");
	},
	getMembersList : function() {
		var invitee = new Array();
		$('input[name="userId"]:checked').each(function() {
			invitee.push(parseInt($(this).val()));
		});
		return invitee;
	},
	getMembersText : function() {
		return JSON.stringify(Checkbox.parseData());
	},
	getId : function() {
		return Math.round(new Date().getTime() / 1000) + Math.floor(Math.random() * 1000);
	},
	//检索我的群组，通过比对本地缓存数据查找不调用接口，我的群组均会缓存在本地
	searchFromMyRooms : function (keyword){
		var roomList = new Array();
		for(var num in DataMap.myRooms){
			if(!myFn.isNil(DataMap.myRooms[num])  &&  -1 != (DataMap.myRooms[num].name).search(keyword+''))
		    	roomList.push(DataMap.myRooms[num]);
	    }
	    return roomList;
	},
	//检索用户本地的群组，同时调用接口检索公开群组
	searchAllRooms : function(keyword){
		var roomList = new Array();
		for(var num in DataMap.myRooms){
			if(!myFn.isNil(DataMap.myRooms[num])  &&  -1 != (DataMap.myRooms[num].name).search(keyword+''))
		    	roomList.push(DataMap.myRooms[num]);
	    }


	    mySdk.getAllRoom(0,keyword,function(result){
				if(myFn.isNil(result.length)||0==result.length){
					return;
				}
				for (var i = 0; i < result.length; i++) {
					roomList.push(result[i]);
				}
		});

	    return roomList;
	},
	//将检索到的群组显示到页面
	showSearchRooms : function(){
		var keyword = $("#search_all_room").val();

		if(myFn.isNil(keyword)){
			$("#_allRoomList").empty();
			$("#allRoomList").hide();
			$("#myRoomList").show();
			return;
		}
		//从配置获取服务器是否开启群搜索
		var rooms = (AppConfig.isOpenRoomSearch==0 ? GroupManager.searchAllRooms(keyword) : GroupManager.searchFromMyRooms(keyword));

		if(myFn.isNil(rooms)||0==rooms.length){
			return;
		}
		var html = "";
		for (var i = 0; i < rooms.length; i++) {
			DataMap.rooms[rooms[i].id]=rooms[i];
			html += GroupManager.createItem(rooms[i]);
		}
		if(myFn.isNil(html)){
			return;
		}
		//html += GroupManager.createPager(0, result.length, 'GroupManager.showAllRoom');
		$("#myRoomList").hide();
		$("#_allRoomList").empty();
		$("#_allRoomList").append(html);
		$("#allRoomList").show();

	}
};

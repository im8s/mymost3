$(function(){
	//消息界面 右键菜单
    $.contextMenu({
        selector: '#messageContainer .bubble_cont',
       	//className: '.chat_content',
       	//trigger: 'hover',
        callback: function(key, opt) {
          
        },
        items: {
           /* copy:{
                name:"复制",
                icon:"copy",
                disabled:function(){
                    var msgType=$(this).parents(".chat_content_group").attr("msgType");
                   if(myFn.notNull(msgType)&&1==msgType)
                        return false;
                     else 
                        return true;
                },
                callback:function(key,opt){
                    var msgElem=$(this).parents(".chat_content_group");
                   var msgId=$(msgElem).attr("id").split("msg_")[1];
                    Temp.copyMsg=DataUtils.getMessage(msgId);
                    var copy_target=$(msgElem).find(".chat_content");
                    copy_target.focus();
                    copy_target.select();
                    document.execCommand("Copy","false",null);
                }
            },*/
        	forwarding:{
        		name:"转发",
        		icon:"edit",
                disabled:function(){
                    var msgType=$(this).parents(".msgDiv").attr("msgType");
                   if(myFn.notNull(msgType)&&28!=msgType)
                        return false;
                     else 
                        return true;
                },
        		callback:function(key,opt){
						//var obj =$(this);
						/*var idStr=obj.attr("id");
						var msgId=idStr.split("msg_");*/
						var msgId=$(this).parents(".msgDiv").attr("id").split("msg_")[1];
                        var msg=DataUtils.getMessage(msgId);
                        if(myFn.isReadDelMsg(msg)){
                            ownAlert(3,"阅后即焚消息不支持转发!");
                            return;
                        }
						Temp.msgId=msgId;
                        // Temp.friendListType="forward";
                        Checkbox.cheackedFriends = {};  //清空储存的数据
                        Transpond.showFriendList(0); //加载好友
                        Transpond.showGroupList(0);//加载群组    
                        Transpond.toggleFriendOrGroup("friend");
        		}
        	},
            revoked:{
                name:"撤回",
                icon:"recall",
                disabled:function(){
                    //判断不是自己发送的就隐藏
                    var cla=$(this).parents(".js_message_bubble").attr("class");
                   if(!myFn.isContains(cla,"right"))
                     return true;
                 var msgType=$(this).parents(".msgDiv").attr("msgType");
                   if(myFn.notNull(msgType)&&28!=msgType)
                        return false;
                    else 
                        return true;
                },
                callback:function(key,opt){
                    var msgId=$(this).parents(".msgDiv").attr("id").split("msg_")[1];
                    var msg=DataUtils.getMessage(msgId);
                    /*var time = Math.round(new Date().getTime() / 1000);
                    if((time-msg.timeSend)>300){
                        ownAlert(3,"发送超过五分钟,不能撤回！");
                        return;
                    }*/
                    UI.deleteMsg(WEBIM.isChatType(ConversationManager.chatType)?1:2,2,msgId,ConversationManager.fromUserId,1,function(){
                         //发送撤回消息协议
                        var message=WEBIM.createMessage(202,msgId);
                        UI.sendMsg(message);
                        DataUtils.deleteMessage(msgId);
                    });
                       

                }
            },
        	delete:{
				name:"删除",
        		icon:"delete",
                disabled:function(){
                    return false;
                },
        		callback:function(key,opt){
        			var msgId=$(this).parents(".msgDiv").attr("id").split("msg_")[1];

						UI.deleteMsg(WEBIM.isChatType(ConversationManager.chatType)?1:2,1,msgId,
                            WEBIM.isChatType(ConversationManager.chatType)?null:ConversationManager.fromUserId,1);
        		}
        	}
            /*,
        	"sep1": "---------",
        	quit:{
        		name: "退出",
        		 icon: function($element, key, item)
           			 	  { return 'context-menu-icon context-menu-icon-quit'; }
        	}*/
            
        }
    });
});


var  Transpond = { //转发相关
    showFriendList : function(pageIndex){
        var tbInviteListHtml = "";
        mySdk.getFriendsList(myData.userId,null,2, pageIndex, function(result) {
            var friendsList = result.pageData;
            var obj=null;
            // var choosedUIds = Checkbox.parseData(); //调用方法获取已勾选的好友
            for(var i = 0; i < friendsList.length; i++){
                 obj = friendsList[i];
                 var inputItem = "<input id='false' name='invite_userId' type='checkbox' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
                 if(obj.toUserId==Checkbox.cheackedFriends[obj.toUserId]){
                    inputItem = "<input id='false' name='invite_userId' type='checkbox' checked='checked' value='" + obj.toUserId + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
                 }
                tbInviteListHtml += "<tr style='margin-bottom:10px;'><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.toUserId)
                + "' width=30 height=30 class='roundAvatar'/></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + myFn.getText(obj.toNickname,6)
                + "</td><td>"+inputItem+"</td></tr>";
            }
            var pageHtml = GroupManager.createPager(pageIndex, result.pageData.length,'Transpond.showFriendList');
            $("#msgTranspond #pageFriend").empty().append(pageHtml);
            $("#msgTranspond #friendList").empty();
            $("#msgTranspond #friendList").append(tbInviteListHtml);
            $("#msgTranspond #friendTitle").attr("class","transpond transpondChange");
            $("#msgTranspond").modal('show');
        },1);
    },
    toggleFriendOrGroup : function (name){ //切换

        $("#keywordTranspond").empty(); //清空输入框

        if("friend"==name){ //好友
           
            //切换背景
            $("#msgTranspond #friendTitle").attr("class","transpond transpondChange");
            $("#msgTranspond #groupTitle").attr("class","transpond");

            //隐藏群组相关
            $("#msgTranspond #groupList").hide(); 
            $("#msgTranspond #pageGroup").hide();

            //显示好友相关
            $("#msgTranspond #searchBtn").attr("onclick","Transpond.search('friend')"); 
            $("#msgTranspond #friendList").show();
            $("#msgTranspond #pageFriend").show();

        }else if("group"==name){ //群组
           
            //切换背景
            $("#msgTranspond #groupTitle").attr("class","transpond transpondChange");
            $("#msgTranspond #friendTitle").attr("class","transpond");

            //隐藏好友相关
            $("#msgTranspond #friendList").hide(); 
            $("#msgTranspond #pageFriend").hide(); 
            

            //显示群组相关
            $("#msgTranspond #searchBtn").attr("onclick","Transpond.search('group')");
            $("#msgTranspond #groupList").show();
            $("#msgTranspond #pageGroup").show();
        }
    },
    confirmTranspond : function(){ //确认转发 
        var userIdArr =Checkbox.parseData();//调用方法获取已勾选的数据
        if (0 == userIdArr.length) {
            ownAlert(3,"请选择要发送的好友");
            return;
        } else {
            var type=!WEBIM.isGroupChat(ConversationManager.chatType)?1:2;
            var msg=DataUtils.getMessage(Temp.msgId);
            if(!myFn.isNil(msg)){
                UI.forwardingMsg(msg,userIdArr);
            }else{
                mySdk.getMessage(Temp.msgId,type,function(msg){
                    UI.forwardingMsg(msg,userIdArr);
                }); 
            }
           
            $("#msgTranspond").modal('hide'); //隐藏面板
            
        }



    },
    search : function(name){ //搜索

        if("friend"==name){ //好友

           Transpond.searchFriend(0);

        }else if("group"==name){ //搜索群组

            var keyword=$("#keywordTranspond").val();
            if(myFn.isNil(keyword)){
                ownAlert(3,"请输入搜索关键字");
                return;
            }
            var rooms = GroupManager.searchFromMyRooms(keyword);
            var groupHtml = "";
            for (var i in rooms) {
                var obj = rooms[i];

                var inputItem = "<input id='false' name='invite_groupId' type='checkbox' value='" + obj.jid + "' onclick='Checkbox.checkedAndCancel(this)'/>";
                if(obj.jid==Checkbox.cheackedFriends[obj.jid]){ //判断数据是否存在
                    inputItem = "<input id='false' name='invite_groupId' type='checkbox' checked='checked' value='" + obj.jid + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
                }
                groupHtml += "<tr style='margin-bottom:10px;'><td>"
                                 +      "<img onerror='this.src=\"img/ic_avatar.png\"' src='"+ (myFn.getAvatarUrl(obj.userId)) + "' width=30 height=30 class='roundAvatar'/>"
                                 + "</td><td width=100%>" 
                                 +      "<h5 class='media-heading groupName'>"+ (myFn.isNil(obj.name) ? "&nbsp;" : myFn.getText(obj.name,6))+"</h5>"
                                 + "</td><td>"+inputItem+"</td></tr>";
            }
            
            $("#msgTranspond #groupList").empty();
            $("#msgTranspond #groupList").append(groupHtml);

        }
    },
    searchFriend : function(pageIndex){
        //搜索好友
        var keyword=$("#keywordTranspond").val();
        if(myFn.isNil(keyword)){
            ownAlert(3,"请输入搜索关键字");
            return;
        }
        //转发搜索
        mySdk.getFriendsList(myData.userId,keyword,2,pageIndex,function(result){
             var tbInviteListHtml = "";
                var friendsList = result.pageData;
                var obj=null;
                for(var i = 0; i < friendsList.length; i++){
                     obj = friendsList[i];
                     var inputItem = "<input id='false' name='invite_userId' type='checkbox' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/>";
                     if(obj.toUserId==Checkbox.cheackedFriends[obj.toUserId]){
                        inputItem = "<input id='false' name='invite_userId' type='checkbox' checked='checked' value='" + obj.toUserId + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
                     }
                    tbInviteListHtml += "<tr style='margin-bottom:10px;'><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + myFn.getAvatarUrl(obj.toUserId)
                    + "' width=30 height=30 class='roundAvatar'/></td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + myFn.getText(obj.toNickname,6)
                    + "</td><td>"+inputItem+"</td></tr>";
                }

                var pageHtml = GroupManager.createPager(pageIndex, result.pageData.length,'Transpond.searchFriend');
                $("#msgTranspond #pageFriend").empty().append(pageHtml);
                $("#msgTranspond #friendList").empty();
                $("#msgTranspond #friendList").append(tbInviteListHtml);
        },1);
    },
    showGroupList : function(pageIndex){
        mySdk.getMyRoom(pageIndex,10,function(result){
            var groupHtml = "";   
            if(!result||0==result.length)            
                return null;
            for (var i = 0; i < result.length; i++) {
                var obj = result[i];

                var inputItem = "<input id='false' name='invite_groupId' type='checkbox' value='" + obj.jid + "' onclick='Checkbox.checkedAndCancel(this)'/>";
                if(obj.jid==Checkbox.cheackedFriends[obj.jid]){ //判断数据是否存在
                    inputItem = "<input id='false' name='invite_groupId' type='checkbox' checked='checked' value='" + obj.jid + "'  onclick='Checkbox.checkedAndCancel(this)'/>";
                }
                groupHtml += "<tr style='margin-bottom:10px;'><td>"
                                 +      "<img onerror='this.src=\"img/ic_avatar.png\"' src='"+ (myFn.getAvatarUrl(obj.userId)) + "' width=30 height=30 class='roundAvatar'/>"
                                 + "</td><td width=100%>" 
                                 +      "<h5 class='media-heading groupName'>"+ (myFn.isNil(obj.name) ? "&nbsp;" : myFn.getText(obj.name,6))+"</h5>"
                                 + "</td><td>"+inputItem+"</td></tr>";
            }

            pageHtml = GroupManager.createPager(pageIndex, result.length, 'Transpond.showGroupList');

            $("#msgTranspond #pageGroup").empty().append(pageHtml);
            $("#msgTranspond #groupList").empty();
            $("#msgTranspond #groupList").append(groupHtml);
        });
    },

};












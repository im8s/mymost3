var page=0;
var lock=0;
var messageIds = new Array();
var userIds = new Array();
var roomJid;
var roomId;
var roomName;
var consoleAdmin = localStorage.getItem("account");
var currentPageIndex;// 群聊天记录中的当前页码数
var currentCount;// 群聊天记录中的当前总数
var roomControl = new Object();// 群控制消息
layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

	//群组列表
    var tableInRoom = table.render({
      elem: '#room_table'
      ,url:request("/console/roomList")
      ,id: 'room_table'
      ,page: true
      ,curr: 0
      ,limit:Common.limit
	  ,limits:Common.limits
      ,groups: 7
      ,cols: [[ //表头
            {field: 'id', title: '群组ID',width:200}
            ,{field: 'name', title: '群组名称',width:120}
          ,{field: 'desc', title: '群组说明',width:110}
          ,{field: 'userId', title: '创建者Id', sort: true, width:120}
          ,{field: 'nickname', title: '创建者昵称', width:120}
          ,{field: 'userSize', title: '群人数',sort: true, width:100}
          ,{field: 's', title: '状态',sort: true, width:100,templet:function (d) {
					if(1 == d.s){
						return "正常";
					}else {
						return "被封锁";
					}
                }}
          ,{field: 'isSecretGroup', title: '是否为私密群组',sort: true, width:180,templet:function (d) {
                    if(1 == d.isSecretGroup){
                        return "私密群组";
                    }else {
                        return "普通群组";
                    }
                }}
          ,{field: 'createTime',title:'创建时间',sort: true, width:200,templet: function(d){
          		return UI.getLocalTime(d.createTime);
          }}
          ,{fixed: 'right', width: 710,title:"操作", align:'left', toolbar: '#roomListBar'}
        ]]
		,done:function(res, curr, count){
            checkRequst(res);
            //获取零时保留的值
            var last_value = $("#roomList_limlt").val();
            //获取当前每页大小
            var recodeLimit =  tableInRoom.config.limit;
            //设置零时保留的值
            $("#roomList_limlt").val(recodeLimit);
            //判断是否改变了每页大小数
            if (last_value != recodeLimit){
                // 刷新
                table.reload("room_table",{
                    url:request("/console/roomList"),
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                })
            }


          /*  $(".deleteMonthLogs").hide();
      		  $(".deleteThousandAgoLogs").hide();
            // 查询聊天记录
            $(".keyWord").hide();
            $(".search_keyWord").hide();*/

			$(".group_name").val("");
			$(".leastNumbers").val("");
          $(".keyWord").addClass("keyWord");

			if(count==0&&lock==1){
                layer.msg("暂无数据",{"icon":2});
            	renderTable();
              }
              lock=0;
			if(localStorage.getItem("role")==1 || localStorage.getItem("role")==4){
		    	$(".btn_addRoom").hide();
		    	$(".member").hide();
		    	$(".randUser").hide();
		    	$(".modifyConf").hide();
		    	$(".msgCount").hide();
		    	$(".sendMsg").hide();
		    	$(".del").hide();
		    	$(".deleteMonthLogs").hide();
		    	$(".deleteThousandAgoLogs").hide();
		    	$(".locking").hide();
		    	$(".cancelLocking").hide();
                //$(".chatRecord").hide();
		    }else if(localStorage.getItem("role")==1 || localStorage.getItem("role")==7){
                $(".btn_addRoom").hide();
                $(".member").hide();
                $(".randUser").hide();
                $(".modifyConf").hide();
                $(".msgCount").hide();
                $(".sendMsg").hide();
                $(".del").hide();
                $(".deleteMonthLogs").hide();
                $(".deleteThousandAgoLogs").hide();
                $(".locking").hide();
                $(".cancelLocking").hide();
                $(".chatRecord").hide();
			}
            var pageIndex = tableInRoom.config.page.curr;//获取当前页码
            var resCount = res.count;// 获取table总条数
            currentCount = resCount;
            currentPageIndex = pageIndex;

		}
    });


	$("#room_table_div").show();
	$("#roomMsgList").hide();
	$("#roomUserList").hide();
	$("#pushToRoom").hide();
	$("#addRandomUser").hide();
	$("#updateRoom").hide();
	$("#addRoom").hide();

	/*table.on('rowDouble(room_table)', function(obj){
	  console.log(obj);
	});*/

    //列表操作
    table.on('tool(room_table)', function(obj){
        var layEvent = obj.event,
        data = obj.data;
        if(layEvent === 'chatRecord'){ //聊天记录
            $(".keyWord").css("display","inline");
        	roomJid = data.jid;
            // 查询聊天记录
            Room.baseUIHander();
            $(".keyWord").show();
            $(".search_keyWord").show();
            $(".deleteMonthLogs").show();
            $(".deleteThousandAgoLogs").show();
		    var tableInsRoom = table.render({
			      elem: '#room_msg'
                  ,toolbar: '#toolbarGroupMessageList'
			      ,url:request("/console/groupchat_logs_all")+"&room_jid_id="+data.jid
			      ,id: 'room_msg'
			      ,page: true
			      ,curr: 0
                  ,limit:Common.limit
                  ,limits:Common.limits
			      ,groups: 7
			      ,cols: [[ //表头
                   	   {type:'checkbox',fixed:'left'}// 多选
			          ,{field: 'room_jid', title: '房间JId',sort: true, width:220}
			          ,{field: 'sender', title: '发送者Id',sort: true, width:100}
			          ,{field: 'fromUserName', title: '发送者',sort: true, width:220}
			          ,{field: 'type', title: '消息类型',sort: true, width:220,templet:function (d) {
                            return Common.msgType(d.contentType);
                        }}
			          ,{field: 'content', title: '内容',sort: true, width:400,templet:function (d) {
							if(!Common.isNil(d.content)){
                                if(1 == d.isEncrypt && localStorage.getItem("role")==6){
                                    var desContent = Common.decryptMsg(d.content,d.messageId,d.timeSend);
                                    if(desContent.search("https") != -1||desContent.search("http")!=-1){
                                        var link = "<a target='_blank' href=\""+desContent+"\">"+desContent+"</a>";
                                        return link;
                                    }else{
                                        return desContent;
                                    }
                                }else{
                                    var text = (Object.prototype.toString.call(d.content) === '[object Object]' ? JSON.stringify(d.content) : d.content)
                                    try {
                                        if(text.search("https") != -1 || text.search("http")!=-1){
                                            var link = "<a target='_blank' href=\""+text+"\">"+text+"</a>";
                                            return link;
                                        }else{
                                            return text;
                                        }
                                    }catch (e) {
                                        return text;
                                    }
                                }
							}else{
								return "";
							}

                        }}
			          ,{field: 'timeSend',title:'发送时间',sort: true,width:220,templet: function(d){
			          		return UI.getLocalTime(d.timeSend/1000);
			          }}
			          ,{fixed: 'right', width: 100,title:"操作", align:'left', toolbar: '#roomMessageListBar'}
			        ]]
					,done:function(res, curr, count){
            			checkRequst(res);
						$("#roomMsgList").show();
						$("#room_table_div").hide();
						if(localStorage.getItem("role")==4){
                            $(".deleteMessage").hide();
                            $(".groupChatdelete").hide();
						}
                    var pageIndex = tableInsRoom.config.page.curr;//获取当前页码
                    var resCount = res.count;// 获取table总条数
                    currentCount = resCount;
                    currentPageIndex = pageIndex;
					}
			    });

        } else if(layEvent === 'member'){ //成员管理
        	// console.log(JSON.stringify(data))
            Room.baseUIHander();
            roomId = data.id;
            roomName = data.name;
        	var tableInsMember = table.render({
			      elem: '#room_user'
                  ,toolbar: '#toolbarMembers'
			      ,url:request("/console/roomUserManager")+"&id="+data.id
			      ,id: 'room_user'
			      ,page: true
			      ,curr: 0
                  ,limit:Common.limit
                  ,limits:Common.limits
			      ,groups: 7
			      ,cols: [[ //表头
                       {type:'checkbox',fixed:'left'}// 多选
			          ,{field: 'userId', title: '成员UserId', width:200}
			          ,{field: 'nickname', title: '成员昵称', width:220}
			          ,{field: 'role', title: '成员角色', width:120,templet: function(d){
			          		if(d.role==1){
			          			return "群主";
			          		}else if(d.role==2){
			          			return "管理员";
			          		}else if(d.role==3){
			          			return "成员";
			          		}else if(d.role == 4){
			          			return "隐身人";
							}else if(d.role == 5){
			          			return "监控人";
							}
			          }}
			          ,{field: 'offlineNoPushMsg', title: '是否屏蔽消息', width:200,templet: function(d){
			          		return (d.offlineNoPushMsg==0?"否":"是");
			          }}
			          ,{field: 'createTime',title:'加入时间',width:220,templet: function(d){
			          		return UI.getLocalTime(d.createTime);
			          }}
			          ,{fixed: 'right', width: 300,title:"操作", align:'left', toolbar: '#roomMemberListBar'}
			        ]]
					,done:function(res, curr, count){
            			checkRequst(res);
						$("#roomUserList").show();
						$("#room_table_div").hide();
						$("#save_roomId").val(data.id);
                    	if(localStorage.getItem("role")!=6){
                        	$(".exportFriends").remove();
                    	}
                        var pageIndex = tableInsMember.config.page.curr;//获取当前页码
                        var resCount = res.count;// 获取table总条数
                        currentCount = resCount;
                        currentPageIndex = pageIndex;
			      }
			    });

        }else if(layEvent === 'randUser'){ //添加随机用户
            Room.baseUIHander();
            Room.addRandomUser(data.id);

        } else if(layEvent === 'modifyConf'){ //修改配置
        	Room.updateRoom(data.id);

        } else if(layEvent === 'msgCount'){ //消息统计
        	Count.loadGroupMsgCount(data.jid);

        } else if(layEvent === 'sendMsg'){ //发送消息
            Room.baseUIHander();
        	Room.pushToRoom(data.id,data.jid);
        } else if (layEvent === 'mergeGroup') { //群合并
            var isclick = true;
            layer.prompt({title: '请输入需要合并过来的群ID', formType: 0, value: ''}, function (roomId, index) {
                if (isclick) {
                    isclick = false;
                    Common.invoke({
                        url: request('/console/mergeGroup'),
                        data: {
                            currentGroupId: data.id,
                            inputRoomId: roomId
                        },
                        successMsg: "合并成功",
                        errorMsg: "合并失败，请稍后重试",
                        success: function (result) {
                            var data = result.data;
                            layer.close(index); //关闭弹框
                            // 更新群组列表
                            layui.table.reload("room_table")

                        },
                        error: function (result) {
                            layer.close(index);
                        }
                    });
                    //定时器
                    setTimeout(function () {
                        isclick = true;
                    }, 500);
                }
            });

        } else if (layEvent === 'pubNotice') { //发布群公告
            layer.prompt({title: '请输入群公告', formType: 0, value: ''}, function (notice, index) {
                Room.pubNotice(consoleAdmin,data.id,notice);
                layer.close(index); //关闭弹框
            });

        }else if(layEvent === 'locking'){ // 锁定群组
			Room.lockIng(consoleAdmin,data.id,-1);
        }else if(layEvent === 'cancelLocking'){// 解锁
            Room.lockIng(consoleAdmin,data.id,1);
        }else if(layEvent === 'del'){ //删除
            layer.confirm('确认要删除吗？', {
                btn : [ '确定', '取消' ]//按钮
            }, function(index) {
                layer.close(index);
                Room.deleteRoom(data.id,obj,localStorage.getItem("account"));
                obj.del();
            });
        }


    });


     table.on('tool(room_user)', function(obj){
        var layEvent = obj.event,
            data = obj.data;
        if(layEvent === 'deleteMember'){ // 删除群成员
    		Room.toolbarMembersImpl($("#save_roomId").val(),data.userId,1);
    	} else if(layEvent === 'transferOwner'){ // 转为群主
            Room.toolbarTransferOwner($("#save_roomId").val(),data.userId,1);
        } else if(layEvent === 'cancelSetAdmin'){ // 取消设为管理员
            Room.toolbarSetOrCancelAdmin($("#save_roomId").val(),data.userId, 0,1);
        } else if(layEvent === 'setAdmin'){ // 设为管理员
            Room.toolbarSetOrCancelAdmin($("#save_roomId").val(),data.userId, 1,1);
        }
     })
     // 删除消息
     table.on('tool(room_msg)', function(obj){
        var layEvent = obj.event,
            data = obj.data;

        if(layEvent === 'deleteMessage'){ //聊天记录
        	console.log(data);
            Room.toolbarGroupMessageListImpl(data.room_jid,data._id,1);
        }
     })

    //搜索
    $(".search_group").on("click",function(){
        if($(".group_name").val().indexOf("*")!=-1){
            layer.alert("不支持*号搜索")
            return
        }
        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();
        // 校验群人数
        var numbers = $(".leastNumbers").val();
        if(null != numbers && "" != numbers && undefined != numbers){
            var reg = /^[0-9]\d*$/;
            if(!reg.test(numbers)){
                layer.alert("请输入有效的群人数");
                return;
            }
        }

        table.reload("room_table",{
            url:request("/console/roomList"),
            page: {
                curr: 1 //重新从第 1 页开始
            },
            where: {
                keyWorld : Common.getValueForElement(".group_name"),  //搜索的关键字
                leastNumbers : Common.getValueForElement(".leastNumbers"),
                isSecretGroup : Common.getValueForElement("#status")
            }
        })
        lock=1;
    });

    //关键字聊天记录搜索
    $(".search_keyWord").on("click",function(){
        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();
        table.reload("room_msg",{
            url:request("/console/groupchat_logs_all")+"&room_jid_id="+roomJid,
            page: {
                curr: 1 //重新从第 1 页开始
            },
            where: {
                keyWord : Common.getValueForElement(".keyWord")  //搜索的关键字
            }
        })
        $(".keyWord").val("")
        lock=1;
    });

})

//重新渲染表单
function renderTable(){
  layui.use('table', function(){
   var table = layui.table;//高版本建议把括号去掉，有的低版本，需要加()
   // table.reload("user_list");
    table.reload("room_table",{
        page: {
            curr: 1 //重新从第 1 页开始
        },
        where: {
            keyWorld : Common.getValueForElement(".group_name"),  //搜索的关键字
            leastNumbers : Common.getValueForElement(".leastNumbers")
        }
    })
  });
 }

var button='<button onclick="Room.button_back()" class="layui-btn layui-btn-primary layui-btn-sm" style="margin-top: 35px;margin-left: 50px;"><<返回</button>';


var Room={

		// 新增群组
		addRoom:function(){
			$("#roomList").hide();
			$("#roomMsgList").hide();
			$("#addRoom").show();

		},
		// 提交新增群组
		commit_addRoom:function(){
			if($("#add_roomName").val()==""){
				layer.alert("请输入群名称");
				return ;
			}else if($("#add_desc").val()==""){
				layer.alert("请输入群说明");
				return;
			}
			Common.invoke({
				url:request('/console/addRoom'),
				data:{
					userId: localStorage.getItem("account"),// 让当前登录后台管理系统的系统管理员创建房间
					name: Common.getValueForElement("#add_roomName"),
					desc: Common.getValueForElement("#add_desc")
				},
				success:function(result){
					if(result.resultCode==1){
                        layer.msg("新增成功",{"icon":1});
						$("#roomList").show();
						$("#roomMsgList").hide();
						$("#addRoom").hide();
						$("#add_roomName").val("");
						$("#add_desc").val("");
                        // UI.roomList(0);
                        layui.table.reload("room_table",{
                            page: {
                                curr: 1 //重新从第 1 页开始
                            },
                            where: {

                            }
                        })
					}
				}
			});
		},

     // 删除群组
     deleteRoom:function(id,obj,userId){
             $.ajax({
                 type:'POST',
                 url:request('/console/deleteRoom'),
                 data:{
                     roomId:id,
                     userId:userId
                 },
                 async:false,
                 success : function(result){
                     checkRequst(result);
                     if(result.resultCode==1){
                        layer.alert("删除成功");
                     }
                     if(result.resultCode==0){
                         layer.alert(result.resultMsg);
                     }
                 },

             })
     },

		// 群成员管理
		roomUserList:function(e,roomId){
			html="";
			if(e==1){
				if(page>0){
					page--;
				}
			}else if(e==2){
				if(sum<10){
					layui.layer.alert("已是最后一页");
				}else{
					page++;
				}
			}
			Common.invoke({
				url:request('/console/roomUserManager'),
				data:{
					id:roomId,
					pageIndex:page
				},
				success:function(result){
					if(result.data.pageData!=null){
						sum=result.data.pageData.length;
						for(var i=0;i<result.data.pageData.length;i++){

							html+="<tr><td>"+result.data.pageData[i].userId+"</td><td>"+result.data.pageData[i].nickname+"</td><td>"
							+result.data.pageData[i].role+"</td><td>"+(result.data.pageData[i].offlineNoPushMsg==0?"否":"是")+"</td><td>"
							+UI.getLocalTime(result.data.pageData[i].createTime)+"</td><td><button onclick='Room.deleteMember(\""+roomId+"\",\""+result.data.pageData[i].userId+"\")' class='layui-btn layui-btn-danger layui-btn-xs'>删除</button></td></tr>";
						}
						var tab="<a href='javascript:void(0);' onclick='Room.roomUserList(1,\""+roomId+"\")' class='layui-laypage-prev layui-disabled' data-page='0'>上一页</a>"
						+"<a href='javascript:void(0);' onclick='Room.roomUserList(2,\""+roomId+"\")' class='layui-laypage-next' data-page='2'>下一页</a>";
						$("#roomUser_table").empty();
						$("#roomUser_table").append(html);
						$("#roomUserList_div").empty();
						$("#roomUserList_div").append(tab);
						$("#room_table_div").hide();
						$("#roomMsgList").hide();
						$("#roomUserList").show();
						$("#back").empty();
						$("#back").append(button);

					}
				}
			})
		},
		// 删除群成员
		deleteMember:function(roomId,userId,obj){
			layer.confirm('确定删除该群成员？',{icon:3, title:'提示信息'},function(index){
				Common.invoke({
					url:request('/console/deleteMember'),
					data:{
						userId:userId,
						roomId:roomId
					},
					success:function(result){
						if(result.resultCode==1){

							layer.alert("删除成功");
							obj.del();
							// Room.roomUserList(0,roomId);
						}
					}
				})
			})

		},

	// 批量移出群成员
    toolbarMembers:function(){
        // 多选操作
        var checkStatus = layui.table.checkStatus('room_user'); //idTest 即为基础参数 id 对应的值
        console.log("新版："+checkStatus.data) //获取选中行的数据
        console.log("新版："+checkStatus.data.length) //获取选中行数量，可作为是否有选中行的条件
        console.log("新版："+checkStatus.isAll ) //表格是否全选
		for (var i = 0; i < checkStatus.data.length; i++){
            userIds.push(checkStatus.data[i].userId);
		}
        if(0 == checkStatus.data.length){
            layer.msg("请勾选要移出的行");
            return;
        }
        console.log(userIds);
        Room.toolbarMembersImpl($('#save_roomId').val(),userIds.join(","),checkStatus.data.length);
	},

    toolbarMembersImpl:function(roomId,userId,checkLength){
        layer.confirm('确定移出指定群成员',{icon:3, title:'提示消息',yes:function () {
                Common.invoke({
                    url:request('/console/deleteMember'),
                    data:{
                        roomId :roomId,
                        userId :userId,
                        adminUserId :localStorage.getItem("account")
                    },
                    success:function(result){
                        if(result.resultCode==1){
                            layer.msg("移出成功",{"icon":1});
                            userIds = [];
                            // renderTable();
                            Common.tableReload(currentCount,currentPageIndex,checkLength,"room_user");
                            // layui.table.reload("room_user");
                        }else if(result.resultCode==0){
                            layui.table.reload("room_user");
                            layer.msg(result.resultMsg);
						}
                    },

                })
            },btn2:function () {
                userIds = [];
            },cancel:function () {
                userIds = [];
         }});
	},

    toolbarTransferOwner:function(roomId,userId,checkLength){
        layer.confirm('确定转为群主',{icon:3, title:'提示消息',yes:function () {
                Common.invoke({
                    url:request('/console/room/transfer'),
                    data:{
                        roomId :roomId,
                        toUserId :userId
                    },
                    success:function(result){
                        if(result.resultCode==1){
                            layer.msg("操作成功",{"icon":1});
                            userIds = [];
                            Common.tableReload(currentCount,currentPageIndex,checkLength,"room_user");
                        }else if(result.resultCode==0){
                            layui.table.reload("room_user");
                            layer.msg(result.resultMsg);
                        }
                    },

                })
            },btn2:function () {
                userIds = [];
            },cancel:function () {
                userIds = [];
            }});
    },

    toolbarSetOrCancelAdmin:function(roomId,userId,operate,checkLength){
        let confirmMsg = '确定设为管理员';
        let type = 2;
        if (1 != operate) {
            confirmMsg = '确定取消管理员';
            type = 3;
        }
        layer.confirm(confirmMsg, {icon:3, title:'提示消息',yes:function () {
                Common.invoke({
                    url:request('/console/room/set/admin'),
                    data:{
                        roomId :roomId,
                        touserId :userId,
                        type :type
                    },
                    success:function(result){
                        if(result.resultCode==1){
                            layer.msg("操作成功",{"icon":1});
                            userIds = [];
                            Common.tableReload(currentCount,currentPageIndex,checkLength,"room_user");
                        }else if(result.resultCode==0){
                            layui.table.reload("room_user");
                            layer.msg(result.resultMsg);
                        }
                    },

                })
            },btn2:function () {
                userIds = [];
            },cancel:function () {
                userIds = [];
            }});
    },


    // 批量删除群成员（等同于批量删除用户）
    toolbarDeleteMembers:function(){
        // 多选操作
        var checkStatus = layui.table.checkStatus('room_user'); //idTest 即为基础参数 id 对应的值
        console.log("新版："+checkStatus.data) //获取选中行的数据
        console.log("新版："+checkStatus.data.length) //获取选中行数量，可作为是否有选中行的条件
        console.log("新版："+checkStatus.isAll ) //表格是否全选
        for (var i = 0; i < checkStatus.data.length; i++){
            userIds.push(checkStatus.data[i].userId);
        }
        if(0 == checkStatus.data.length){
            layer.msg("请勾选要删除的行");
            return;
        }
        console.log(userIds);
        Room.toolbarDeleteMembersImpl(userIds.join(","));
    },

    toolbarDeleteMembersImpl:function(userId){
        layer.confirm('确定删除指定群成员用户,<br>删除后该系统会注销此用户',{icon:3, title:'提示消息',yes:function () {
                Common.invoke({
                    url:request('/console/deleteUser'),
                    data:{
                        userId :userId
                    },
                    success:function(result){
                        if(result.resultCode==1){
                            layer.msg("删除成功",{"icon":1});
                            userIds = [];
                            // renderTable();
                            layui.table.reload("room_user");
                        }else if(result.resultCode==0){
                            layer.msg(result.resultMsg);
                        }
                    },

                })
            },btn2:function () {
                userIds = [];
            },cancel:function () {
                userIds = [];
            }});
    },

	// 导出群成员
	exprotExcelByMember:function(){
            var requestUrl = request('/console/exportExcelByGroupMember');
		    layui.layer.open({
            title: '数据导出'
            ,type : 1
            ,offset: 'auto'
            ,area: ['300px','180px']
            ,btn: ['导出', '取消']
            ,content:  '<form class="layui-form" method="post" action="'+requestUrl+'">'
            + '<div class="layui-form-item">'
            + 	'<div class="layui-inline">'
            +	'<input type="hidden" name="roomId" value='+roomId+'>'
            + 		'<label class="layui-form-label" style="width: 90%;margin-top: 20px" >导出群组 "'+roomName+'" 的群成员列表</label>'
            +	     '</div>'
            + '</div>'
            +  '<button id="exportGroupMember_submit"  class="layui-btn" type="submit" lay-submit="" style="display:none">导出</button>'
            +'</from>'
            ,success: function(index, layero){
                layui.form.render();
            }
            ,yes: function(index, layero){
                $("#exportGroupMember_submit").click();
                layui.layer.close(index); //关闭弹框
            }
            ,btn2: function(index, layero){
                //按钮【取消】的回调

                //return false 开启该代码可禁止点击该按钮关闭
            }

        });
	},

	// 刷新table
    reloadTable:function(){
		// 刷新父级页面
        parent.layui.table.reload("room_user")
    },

	// 邀请用户加入群组 inviteJoinRoom
    inviteJoinRoom:function(){
		console.log("joinRoom :       "+roomId);
        localStorage.setItem("roomId", roomId);
        layer.open({
            title : "",
            type: 2,
            skin: 'layui-layer-rim', //加上边框
            area: ['1050px', '700px'], //宽高
            content: 'inviteJoinRoom.html'
            ,success: function(index, layero){

            }
        });
	},

	// 群发消息
	pushToRoom:function(id,jid){
		// $("#roomList").hide();
		// $("#roomMsgList").hide();
		html="";
		$("#room_table_div").hide();
		$("#pushToRoom").show();
		$("#push_roomJid").val(jid);
		Common.invoke({
			url:request('/console/getRoomMember'),
			data:{
				roomId:id
			},
			success:function(result){
				if(result.data!=null){
					for(var i=0;i<result.data.members.length;i++){
						if(result.data.members[i].role<3){
							html+="<option value='"+Common.filterHtmlData(result.data.members[i].userId)+"'>"+Common.filterHtmlData(result.data.members[i].nickname)+"</option>";
						}
					}
					$("#push_sender").empty();
					$("#push_sender").append(html);
					$("#back").empty();
					$("#back").append(button);
				}
			}
		})
	},

    // 群组锁定解锁
    lockIng:function(userId,roomId,status){
        var confMsg,successMsg="";
        (status == -1 ? confMsg = '确定封锁该群组？':confMsg = '确定解封该群组？');
        (status == -1 ? successMsg = "封群成功":successMsg ="解封群组成功");
        layer.confirm(confMsg,{icon:3, title:'提示信息'},function(index){

            Common.invoke({
                url : request('/console/updateRoom'),
                data : {
                    userId:userId,
					roomId:roomId,
                    s:status
                },
                successMsg : successMsg,
                errorMsg :  "加载数据失败，请稍后重试",
                success : function(result) {
                    layui.table.reload("room_table")
                },
                error : function(result) {
                }
            });
        })
    },
    // 发布群公告
    pubNotice:function(userId,roomId,notice){
        layer.confirm("确定发布公告？",{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url : request('/console/updateRoom'),
                data : {
                    userId:userId,
                    roomId:roomId,
                    notice:notice
                },
                successMsg : "发布成功",
                errorMsg :  "加载数据失败，请稍后重试",
                success : function(result) {
                },
                error : function(result) {
                }
            });
        })
    },
   	// 发送
		commit_push:function(){
		    if(null == $("#push_context").val() || "" == $("#push_context").val()){
                layer.alert("请输入要发送内容");
                return;
            }

			Common.invoke({
				url:request('/console/sendMsg'),
				data:{
					jidArr: Common.getValueForElement("#push_roomJid"),
					userId: Common.getValueForElement("#push_sender"),
					type:1,
					content: Common.getValueForElement("#push_context")
				},
				success:function(result){
					layer.alert("发送成功");
                    $("#push_context").val("")
				}
			})
		},
		// 添加随机用户
		addRandomUser:function(roomId){
			$("#room_table_div").hide();
			$("#addRandomUser").show();
			$("#roomId").html( Common.filterHtmlData(roomId));
			$("#back").empty();
			$("#back").append(button);
		},
		commit_addRandomUser:function(){
			Common.invoke({
				url:request('/console/autoCreateUser'),
				data:{
					userNum: Common.getValueForElement("#addRandomUserSum"),
					roomId:$("#roomId").html()
				},
				success:function(result){
					if(result.resultCode==1){
						layer.alert("添加成功");
						// Room.roomList(0);
						$("#room_table_div").show();
						$("#addRandomUser").hide();
					}
				}
			})
		},
		// 修改群配置
		updateRoom:function(roomId){
		    $(".room_btn_div").hide();
			Common.invoke({
				url:request('/console/getRoomMember'),
				data:{
					roomId:roomId
				},
				success:function(result){
					if(result.data!=null){
					    roomControl = result.data;// 群控制参数
						$("#updateRoom_id").val(result.data.id);
						$("#update_roomId").html(result.data.id);
						$("#update_roomJid").html(result.data.jid);
						$("#name").val(result.data.name);
						$("#desc").val(result.data.desc);
						$("#maxUserSize").val(result.data.maxUserSize);
						$("#isLook").val(result.data.isLook);
						$("#showRead").val(result.data.showRead);
						$("#isNeedVerify").val(result.data.isNeedVerify);
						$("#showMember").val(result.data.showMember);
						$("#allowSendCard").val(result.data.allowSendCard);
						// $("#allowHostUpdate").val(result.data.allowHostUpdate);
						$("#allowInviteFriend").val(result.data.allowInviteFriend);
						$("#allowUploadFile").val(result.data.allowUploadFile);
						$("#allowConference").val(result.data.allowConference);
						$("#allowSpeakCourse").val(result.data.allowSpeakCourse);
                        $("#forbidQuit").val(result.data.forbidQuit);
						$("#isAttritionNotice").val(result.data.isAttritionNotice);
						// 渲染复选框
                        layui.form.render();

						$("#room_table_div").hide();
						$("#updateRoom").show();
						$("#updateRoom1").show();

						$("#back").empty();
						$("#back").append(button);
					}

				}
			})
		},

	// 多选删除群组聊天记录
    toolbarGroupMessageList:function(){
        // 多选操作
        var checkStatus = layui.table.checkStatus('room_msg'); //idTest 即为基础参数 id 对应的值
        console.log("新版："+checkStatus.data) //获取选中行的数据
        console.log("新版："+checkStatus.data.length) //获取选中行数量，可作为是否有选中行的条件
        console.log("新版："+checkStatus.isAll ) //表格是否全选
        var userId;
        for (var i = 0; i < checkStatus.data.length; i++){
            messageIds.push(checkStatus.data[i]._id);
            roomJid = checkStatus.data[i].room_jid
        }
        console.log("roomJid"+roomJid+"------"+messageIds);
        if(0 == checkStatus.data.length){
            layer.msg("请勾选要删除的行");
            return;
        }
        Room.toolbarGroupMessageListImpl(roomJid,messageIds.join(","),checkStatus.data.length);
	},

    toolbarGroupMessageListImpl:function(room_jid_id,messageId,checkLength){
        layer.confirm('确定删除指定群聊聊天记录',{icon:3, title:'提示消息',yes:function () {
			Common.invoke({
				url:request('/console/groupchat_logs_all/del'),
				data:{
					msgId :messageId,
                    room_jid_id:room_jid_id
				},
				success:function(result){
					if(result.resultCode==1)
					{
						layer.msg("删除成功",{"icon":1});
						messageIds = [];
						// Common.tableReload(currentCount,currentPageIndex,"room_msg")
                        Common.tableReload(currentCount,currentPageIndex,checkLength,"room_msg");
					}
				}
			})
		},btn2:function () {
			messageIds = [];
		},cancel:function () {
			messageIds = [];
        }});
	},

	// 返回
	button_back:function(){
        $(".room_btn_div").show();
        $(".selectGroupType").show();
        $(".group_name").show();
        $(".leastNumbers").show();
        $(".search_group").show();
        $(".btn_addRoom").show();
		$(".deleteMonthLogs").hide();
		$(".deleteThousandAgoLogs").hide();
		$(".keyWord").hide();
		$("#room_table_div").show();
		$("#roomList").show();
        $(".search_keyWord").hide();
		$("#roomMsgList").hide();
		$("#roomUserList").hide();

		$("#addRoom").hide();
		$("#pushToRoom").hide();
		$("#addRandomUser").hide();
		$("#updateRoom").hide();
		$("#updateRoom1").hide();
		$("#back").empty();
		$("#back").append("&nbsp;");
		layui.table.reload("room_table");
	},

    /**
     * 首界面菜单栏
     */
    baseUIHander: function () {
        $(".selectGroupType").hide();
        $(".group_name").hide();
        $(".leastNumbers").hide();
        $(".search_group").hide();
        $(".btn_addRoom").hide();
        $("#room_table_div").hide();
        $("#chatGroupType").hide();
    }

}
	// 删除一个月前的日志
	$(".deleteMonthLogs").on("click",function(){
		layer.confirm('确定删除一个月前的群聊聊天记录？',{icon:3, title:'提示信息'},function(index){
			Common.invoke({
				url : request('/console/groupchatMsgDel'),
				data : {
					'roomJid':roomJid,
					'type' : 0
				},
				successMsg : "删除成功",
				errorMsg : "删除失败,请稍后重试",
				success : function(result) {
					if (1 == result.resultCode){
						layui.table.reload("room_msg");
					}
				},
				error : function(result) {
				}
			});

		});

	});
	// 删除最近十万条之前的日志
	$(".deleteThousandAgoLogs").on("click",function(){
		layer.confirm('确定删除十万条之前的群聊聊天记录？',{icon:3, title:'提示信息'},function(index){
			Common.invoke({
				url : request('/console/groupchatMsgDel'),
				data : {
					'roomJid':roomJid,
					'type' : 1
				},
				successMsg : "删除成功",
				errorMsg : "删除失败,请稍后重试",
				success : function(result) {
					if (1 == result.resultCode){
						layui.table.reload("room_msg");
					}
				},
				error : function(result) {
                    layui.layer.alert("数量小于等于100000")
				}
			});

		});

	});

	// 修改群属性
	function updateGroupConfig(userId,roomId,roomName,desc,maxUserSize,callback){
		console.log("userId："+userId+"---"+"roomId："+roomId+"---"+"roomName："+roomName+"---"+"desc："+desc+"---"+"maxUserSize："+maxUserSize);
		Common.invoke({
			url : request('/console/updateRoom'),
			data : {
				"userId" : userId,
				"roomId": roomId,
				"roomName": (null == roomName ? null : roomName),
				"desc": (null == desc ? null : desc),
				"maxUserSize": (null == maxUserSize ? null : maxUserSize)
			},
			successMsg : "修改成功",
			errorMsg :  "修改失败，请稍后重试",
			success : function(result) {
				callback();
			},
			error : function(result) {

			}
		});
	}

	// 修改群控制
	function updateConfig(userId,roomId,paramName,paramVal,callback){
		console.log("userId："+userId+"---"+"roomId："+roomId+"---"+"paramName："+paramName+"---"+"paramVal："+paramVal);
		var newParamName = paramName;
		console.log("参数名称："+newParamName);
		obj={
            "userId" : userId,
            "roomId": roomId
		}
		obj[newParamName]=paramVal;
		Common.invoke({
			url : request('/console/updateRoom'),
			data :obj,
			successMsg : "修改成功",
			errorMsg :  "修改失败，请稍后重试",
			success : function(result) {
				callback();
			},
			error : function(result) {

			}
		});
	}

	// 最新的群配置

	// 修改群名称
	$("#name").mousedown(function(){
        var oldName =  Common.getValueForElement("#name");
        $("#name").attr("disabled","disabled");
        layui.layer.open({
            title:"群组名称修改",
            type: 1,
            btn:["确定","取消"],
            area: ['310px'],
            content: '<div id="changePassword" class="layui-form" style="margin:20px 40px 10px 40px;;">'
            +   '<div class="layui-form-item">'
            +      '<div class="layui-input-block" style="margin: 0 auto;">'
            +        '<input type="text" value="'+oldName+'" required  lay-verify="required" placeholder="新的群组名称" autocomplete="off" class="layui-input changeRoomName">'
            +      '</div>'
            +    '</div>'
            +'</div>'
            ,yes: function(index, layero){ //确定按钮的回调
                $('#name').attr("disabled",false);
               	var roomId = Common.filterHtmlData($("#update_roomId").html());
				var roomName = Common.getValueForElement(".changeRoomName");
                updateGroupConfig(localStorage.getItem("account"),roomId,roomName,null,null,function () {
                    layui.layer.close(index); //关闭弹框
					$("#name").val(roomName);
                })
            }
            ,btn2:function () {
                $('#name').attr("disabled",false);
            },
            cancel: function(index, layero){
                $('#name').attr("disabled",false);
                layer.close(index)
            }
        });

        $(".changePassword").focus();
	});
	// 修改群描述
	$("#desc").mousedown(function(){
        $("#desc").attr("disabled","disabled");
        var oldDesc =  Common.getValueForElement("#desc");
		layui.layer.open({
			title:"群组描述修改",
			type: 1,
			btn:["确定","取消"],
			area: ['310px'],
			content: '<div id="changePassword" class="layui-form" style="margin:20px 40px 10px 40px;;">'
			+   '<div class="layui-form-item">'
			+      '<div class="layui-input-block" style="margin: 0 auto;">'
			+        '<input type="text" value="'+Common.filterHtmlData(oldDesc)+'" required  lay-verify="required" placeholder="新的群组描述" autocomplete="off" class="layui-input changeDesc">'
			+      '</div>'
			+    '</div>'
			+'</div>'
			,yes: function(index, layero){ //确定按钮的回调
                $('#desc').attr("disabled",false);
                var roomId = $("#update_roomId").html();
                var desc = $(".changeDesc").val();
                updateGroupConfig(localStorage.getItem("account"),roomId,null,desc,null,function () {
                    layui.layer.close(index); //关闭弹框
                    $("#desc").val(desc);
                })
			}
            ,btn2:function () {
                $('#desc').attr("disabled",false);
            },
            cancel: function(index, layero){
                $('#desc').attr("disabled",false);
                layer.close(index)
            }
		});
		$(".changeDesc").focus();
	});

	// 修改群最大人数
    $("#maxUserSize").mousedown(function(){
        $("#maxUserSize").attr("disabled","disabled");
		var oldMaxUserSize = $("#maxUserSize").val();
		layui.layer.open({
			title:"群组最大人数修改",
			type: 1,
			btn:["确定","取消"],
			area: ['310px'],
			content: '<div id="changePassword" class="layui-form" style="margin:20px 40px 10px 40px;;">'
			+   '<div class="layui-form-item">'
			+      '<div class="layui-input-block" style="margin: 0 auto;">'
			+        '<input type="text" value="'+oldMaxUserSize+'" required lay-verify="required" placeholder="请输入群最大人数" autocomplete="off" class="layui-input changeMaxnum">'
			+      '</div>'
			+    '</div>'
			+'</div>'
			,yes: function(index, layero){ //确定按钮的回调
                $('#maxUserSize').attr("disabled",false);
                var roomId = $("#update_roomId").html();
                var changeMaxnum = $(".changeMaxnum").val();
                if(changeMaxnum > 10000){
                	layui.layer.alert("最高上限10000人")
					return;
                }
            updateGroupConfig(localStorage.getItem("account"),roomId,null,null,changeMaxnum,function () {
                layui.layer.close(index); //关闭弹框
                $("#maxUserSize").val(changeMaxnum);
            })
		    },
            btn2:function () {
                $('#maxUserSize').attr("disabled",false);
             },
            cancel: function(index, layero){
            $('#maxUserSize').attr("disabled",false);
            layer.close(index)
        }
		});
        $("#changeMaxnum").focus();
});

// 群控制消息 lay-filter ： test
layui.form.on('select(test)', function(data){
    console.log(data);
    console.log(data.elem.id);
    console.log(data.value);
    var elemId = data.elem.id;
    var elemVal = data.elem.value;
    // console.log("roomControl: "+JSON.stringify(roomControl));
    var paramValue = roomControl[data.elem.id];
    // console.log("paramValue : "+paramValue);
    // 避免重复提交
    if(paramValue == data.elem.value)
        return;
    else{
        // 更新内存中的值
        roomControl[data.elem.id] = data.elem.value;
        // console.log("new roomControl: "+JSON.stringify(roomControl));
    }
    var roomId = $("#update_roomId").html();
    updateConfig(localStorage.getItem("account"),roomId,elemId,elemVal,function () {
        // $("#"+elemId).val(elemVal);
    });
	});
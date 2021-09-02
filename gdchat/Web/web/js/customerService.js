$(function() {
	
	startFunction();
	CustomerService.customerMap[10000] = "";//初始化
	
});

function startFunction(){

	$("#addUsefulTextBtn").click(function(){
		$('#modify_usefulText').modal('show');
	});
	
	 
	$("#modify_usefulText #confirmAdd").click(function(){ //添加常用语按钮点击事件
		
		var content = $("#modify_usefulText  #usefulContent").val();
		if (myFn.isNil(content)) {
			ownAlert(2,"请输入常用语内容");
			return;
		}
		CustomerService.addChatText(content);
		$("#modify_usefulText  #usefulContent").val("").focus(); //清空输入框内容
	});

	
}


var CustomerService = {
	helloMessageIds : {}, //存放打招呼语 key：messageId  value:接收者userId
	customerMap : {},

	//结束会话
	endChat:function(){
		/*var type = 'chat';
		var to = ConversationManager.from;
		var from = WEBIM.userIdStr;*/

		ownAlert(4,"此操作将会结束与该客户的对话,是否继续？",function(){

			myFn.invoke({
					url : '/org/employee/updateEmployee',
					data : {
						userId : myData.userId,
						operationType : 2,
						companyId : AppConfig.companyId,
						departmentId : AppConfig.departmentId,
					},
					success : function(result) {
						if (1 == result.resultCode) {

							//发送结束会话的xmpp 消息
							var msg = WEBIM.createMessage(321,"结束会话");
							WEBIM.sendMessage(msg);
							shikuLog("发送结束会话xmpp："+msg.messageId);
							delete CustomerService.customerMap[ConversationManager.fromUserId]; //结束会话后删除缓存的该客户信息
						}
					},
					error : function(result) {
					}
			});

		});
		

	},
	//发送打招呼语
	sendSayHello:function(customerId){
		//储存客户信息
		var user = new Object();
		user.sex = 0;
		user.countryId=1;
		user.birthday = new Date().getTime();
		CustomerService.customerMap[customerId] = user;
		//发送打招呼语
		var helloText = "您好,我是客服"+myData.nickname+",很高兴为您服务,请问有什么可以帮您的？";
		var msg=WEBIM.createMessage(1, helloText,customerId);
		
		CustomerService.helloMessageIds[msg.messageId] = customerId; //储存
		UI.sendMsg(msg,customerId);
	},
	//检查是否收到打招呼语的回执，及相关逻辑处理
	checkHelloTextReceipt : function(messageId){
		if(myFn.isNil(CustomerService.helloMessageIds[messageId])){
			return;
		}else{
			console.log("建立会话成功");
			//收到已读回执说明建立会话成功，调用接口，将客服的会话人数加1
			myFn.invoke({
				url : '/org/employee/updateEmployee',
				data : {
					userId : myData.userId,
					operationType:1, // 1:建立会话成功  2.结束会话
					companyId:AppConfig.companyId,
					departmentId:AppConfig.departmentId,
				},
				success : function(result) {
					
				},
				error : function(result) {
				}
			});

		}
	},
	openService:function(isOpen,setting,failCallbak){ //开启客服模式
		var openService = 0; //0：关闭 1：开启
		var cb = ""; //回调函数
		if (isOpen) {//判断是否为选中状态
			openService = 1;
			cb = function(){
				myData.openService = 1;
				ownAlert(3,"客服模式开启");
				CustomerService.modelSwitch(1);
			};
	    } else {
	        
	        cb = function(){
	        	myData.openService = 1;
	        	ownAlert(3,"客服模式关闭");
	        	CustomerService.modelSwitch(0);
			};
	    }
	    //var isSwitch = false;
	    myFn.invoke({
				url : '/org/employee/findEmployee',
				data : {
					companyId : AppConfig.companyId,
					departmentId : AppConfig.departmentId,
					openService : openService,
					userId: myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						cb();

					   // isSwitch = true;

					    //将分配状态置为开始
					    myFn.invoke({
							url : '/org/employee/updateEmployee',
							data : {
								companyId : AppConfig.companyId,
								departmentId : AppConfig.departmentId,
								isPause : openService,
								userId: myData.userId
							},
							success : function(result) {
								mySdk.updateUserSetting(setting); //更新用户设置信息

							},
							error : function(result) {
							}
						});
					}
				},
				fail : function(result) {
					failCallbak();
				}
		});
		/*if (!isSwitch) {
			console.log("执行失败的回调函数");
			errorCallBack();
		}*/

	},
	//客服人员开始服务或停止服务
	/*startOrStopService : function(that){
		
		var isPause = 0; //0：暂停  1：开始
		var cb = ""; //回调函数

		if (that.checked) {//判断是否为选中状态
			isPause = 1;
			cb = function(){
				ownAlert(3,"当前分配状态为开始");
			};

	    } else {
	        cb = function(){
	        	ownAlert(3,"当前分配状态为暂停");
			};

	    }
	    myFn.invoke({
				url : '/org/employee/updateEmployee',
				data : {
					companyId : AppConfig.companyId,
					departmentId : AppConfig.departmentId,
					isPause : isPause,
					userId: myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						cb();
					}
				},
				error : function(result) {
				}
		});

	},*/
	//加载聊天常用语
	loadChatText : function(pageIndex){
		
		var chatTextHtml = "";
		var modifyUsefulTextHtml = "";
		myFn.invoke({
			url : '/CustomerService/commonText/get',
			data : {
				companyId : AppConfig.companyId,
				pageIndex : pageIndex,
				pageSize : 15
			},
			success : function(result) {
				
				if(myFn.isNil(result.data))
					return;
				if (1 == result.resultCode) {

					for (var i = 0; i < result.data.length; i++) {
						var	content = result.data[i].content;
						var id = result.data[i].id;
						chatTextHtml +="<li id="+id+" onclick = 'CustomerService.choiceChatText(this)'>"+content+"</li>";

						modifyUsefulTextHtml += '<li class="userfulTextEdi_li" id="'+id+'">'
                          					 	+ '<a onclick="CustomerService.deleteChatText(this)" href="#"  class="link-remove">移除</a>'
                           						+ '<p>'+content+'</p>'
                        					+'</li>';
					}

					$("#userfulText-panel #userfulTextList").empty().append(chatTextHtml);
					$("#modify_usefulText #userfulTextList").empty().append(modifyUsefulTextHtml);
					// $("#userfulText-panel").show();
				}
			},
			error : function(result) {
			}
		});
	},
	addChatText : function(content){
		if (myFn.isNil(content)) {
			ownAlert(2,"常用语内容不能为空");
			return;
		}
		myFn.invoke({
			url : '/CustomerService/commonText/add',
			data : {
				companyId : AppConfig.companyId,
				content : content,
				userId : myData.userId
			},
			success : function(result) {
				if (1 == result.resultCode) {

					var chatTextHtml = "<li id="+result.data.id+" onclick = 'CustomerService.choiceChatText(this)'>"+result.data.content+"</li>";


					var modifyUsefulTextHtml = '<li class="userfulTextEdi_li" id="'+result.data.id+'">'
                          					 	+ '<a onclick="CustomerService.deleteChatText(this)" href="#"  class="link-remove">移除</a>'
                           						+ '<p>'+result.data.content+'</p>'
                        					+'</li>';


					// $("#userfulText-panel #userfulTextList").insertBefore(chatTextHtml);
					$("#userfulText-panel #userfulTextList").prepend(chatTextHtml);
					$("#modify_usefulText #userfulTextList").append(modifyUsefulTextHtml);
					// $("#userfulText-panel").show();
					ownAlert(1,"添加成功");
				}
			},
			error : function(result) {
				ownAlert(2,"添加常用语失败请重试");
			}
		});
	},
	deleteChatText:function(that){

		var chatTextId = $(that).parent().attr("id");
		if (myFn.isNil(chatTextId)) {
			ownAlert(2,"移除常用语失败,请刷新后重试！");
			return;
		};

		myFn.invoke({
			url : '/CustomerService/commonText/delete',
			data : {
				companyId : AppConfig.companyId,
				commonTextId : chatTextId,
				userId : myData.userId
			},
			success : function(result) {
				if (1 == result.resultCode) {
					$("#userfulText-panel #userfulTextList #"+chatTextId+"").remove();
					$("#modify_usefulText #userfulTextList #"+chatTextId+"").remove();
				}
			},
			error : function(result) {
			}
		});
	},
	//模式切换，打开/关闭 客服模式
	modelSwitch : function(openService){
		if (openService==1 || openService=='1' ) { //开启客服模式
			// $("#startServiceBtn").show(); //开始分配按钮
			$("#redback").hide();  //隐藏红包按钮
			$("#userfulTextBtn").show(); //常用语
			$("#btnEndChat").show();//结束会话按钮
		}else{
			// $("#startServiceBtn").hide(); 
			$("#redback").show();  //隐藏红包按钮
			$("#userfulTextBtn").hide(); //常用语
			$("#btnEndChat").hide();//结束会话按钮
		}
		
	},
	choiceChatText : function(that) {
		var content = that.textContent;
		// var emojiHtml = "<img data-alias='hehe' src='" + _emojl[key] + "' width='25' height='25' title='"+key+"'/>";
		$("#messageBody").val($("#messageBody").val() + content);
		$("#userfulText-panel").hide();
	},





}






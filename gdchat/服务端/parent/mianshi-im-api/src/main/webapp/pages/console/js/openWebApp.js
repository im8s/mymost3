layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

        //app列表
	    var tableIns = table.render({

	      elem: '#openWebApp_table'
	      ,url:request("/console/openAppList")+"&type=2"
	      ,id: 'openWebApp_table'
	      ,page: true
	      ,curr: 0
          ,limit:Common.limit
          ,limits:Common.limits
	      ,groups: 7
	      ,cols: [[ //表头
	           {field: 'accountId', title: '申请用户Id',width:120}
	          ,{field: 'appName', title: '应用名称',width:150}
	          ,{field: 'appIntroduction', title: '应用简介', sort: true, width:150}
	          ,{field: 'appUrl', title: '应用官网', width:150} 
	          ,{field: 'createTime',title:'申请时间',sort: true, width:200,templet: function(d){
	          		return UI.getLocalTime(d.createTime);
	          }}
	          ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#openWebAppListBar'}
	        ]]
			,done:function(res, curr, count){
				checkRequst(res);
				//获取零时保留的值
				var last_value = $("#openWebApp_limlt").val();
				//获取当前每页大小
				var recodeLimit =  tableIns.config.limit;
				//设置零时保留的值
				$("#openWebApp_limlt").val(recodeLimit);
				//判断是否改变了每页大小数
				if (last_value != recodeLimit){
					// 刷新
					table.reload("openWebApp_table",{
						url:request("/console/openAppList")+"&type=2",
						page: {
							curr: 1 //重新从第 1 页开始
						}
					})
				}

                if(localStorage.getItem("role")==1){
                    $(".detail").hide();
                    $(".del").hide();
                }
			}
	    });

	    // 表格操作
	    table.on('tool(openWebApp_table)', function(obj){
	        var layEvent = obj.event,
	            data = obj.data;
	        if(layEvent === 'detail'){ //app详情
	        	WebApp.appDetail(data.id);
	        }else if(layEvent === 'del'){// 删除
	        	WebApp.deleteWebApp(data.id,data.accountId,obj);

	        }
        });

	    // 搜索
        $(".search_openWebApp").on("click",function(){
			if($(".openApp_keyword").val().indexOf("*")!=-1){
				layer.alert("不支持*号搜索")
				return;
			}
			$("#openWebAppList").show();
			$("#openApp_ApplicationList").hide();
			$(".applicationList").show();
			$(".btn_openApp").hide();
	        table.reload("openWebApp_table",{
	        	url:request("/console/openAppList")+"&type=2",
	            page: {
	                curr: 1 //重新从第 1 页开始
	            },
	            where: {
	                keyWorld : Common.getValueForElement(".openApp_keyword")  //搜索的关键字
	            }
	        })

		    $(".openApp_keyword").val('');
    	});
});

var WebApp={
	// 应用详情
	appDetail:function(id){
		Common.invoke({
			url:request('/console/openAppDetail'),
			data:{
				id:id
			},
			success:function(result){
				$("#app_Id").empty();
				$("#app_Id").append(Common.filterHtmlData(result.data.id));
				$("#status").empty();
				$("#status").append(result.data.status==0?"申请中":result.data.status==1?"已通过":result.data.status==2?"审核失败":"已禁用");
				if(result.data.status==1){
					$("#approvedAPP").hide();
					$("#reasonFailure").hide();
					$("#undisable").hide();
					$("#disable").show();
				}else if(result.data.status==-1){
					$("#approvedAPP").hide();
					$("#reasonFailure").hide();
					$("#disable").hide();
					$("#undisable").show();
				}
				$("#accountId").empty();
				$("#accountId").append( Common.filterHtmlData(result.data.accountId) );
				$("#appName").empty();
				$("#appName").append(Common.filterHtmlData(result.data.appName));
				$("#appIntroduction").empty();
				$("#appIntroduction").append(Common.filterHtmlData(result.data.appIntroduction));
				$("#appUrl").empty();
				$("#appUrl").append(Common.filterHtmlData(result.data.appUrl));
				$("#webInfoImg").empty();
				$("#webInfoImg").append(Common.filterHtmlData(result.data.webInfoImg));
				$("#appsmallImg").empty();
				$("#appsmallImg").append(Common.filterHtmlData(result.data.appsmallImg));
				$("#appImg").empty();
				$("#appImg").append(Common.filterHtmlData(result.data.appImg));
				$("#appId").empty();
				$("#appId").append(Common.filterHtmlData(result.data.appId));
				$("#appSecret").empty();
				$("#appSecret").append(Common.filterHtmlData(result.data.appSecret));
				$("#callbackUrl").empty();
				$("#callbackUrl").append(Common.filterHtmlData(result.data.callbackUrl));
				$("#payCallBackUrl").empty();
				$("#payCallBackUrl").append(Common.filterHtmlData(result.data.payCallBackUrl));
				$("#createTime").empty();
				$("#createTime").append(UI.getLocalTime(result.data.createTime));
				$("#isAuthShare").empty();
				$("#isAuthShare").append(result.data.isAuthShare==2?"申请中":result.data.isAuthShare==1?"已授权":result.data.isAuthShare==-1?"审核失败":"未获得");
				$("#isAuthLogin").empty();
				$("#isAuthLogin").append(result.data.isAuthLogin==2?"申请中":result.data.isAuthLogin==1?"已授权":result.data.isAuthLogin==-1?"审核失败":"未获得");
				$("#isAuthPay").empty();
				$("#isAuthPay").append(result.data.isAuthPay==2?"申请中":result.data.isAuthPay==1?"已授权":result.data.isAuthPay==-1?"审核失败":"未获得");
				if(result.data.isAuthShare==2){
					$("#shareOperate").empty();
					let html = "<button onclick='WebApp.checkShare(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='WebApp.checkShare(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#shareOperate").append(html);
				}else {
					$("#shareOperate").empty();
				}
				if(result.data.isAuthLogin==2){
					$("#loginOperate").empty();
					let html = "<button onclick='WebApp.checkLogin(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='WebApp.checkLogin(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#loginOperate").append(html);
				}else {
					$("#loginOperate").empty();
				}
				if(result.data.isAuthPay==2){
					$("#payOperate").empty();
					let html = "<button onclick='WebApp.checkPay(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='WebApp.checkPay(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#payOperate").append(html);
				}else {
					$("#payOperate").empty();
				}

				$("#isGroupHelper").empty();
				$("#isGroupHelper").append(result.data.isGroupHelper==2?"申请中":result.data.isGroupHelper==1?"已授权":result.data.isGroupHelper==-1?"审核失败":"未获得");
				if(result.data.isGroupHelper==2){
					$("#HelperOperate").empty();
					let html = "<button onclick='WebApp.checkHelper(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='WebApp.checkHelper(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#HelperOperate").append(html)
				}else{
					$("#HelperOperate").empty();
				}

				$("#openWebAppList").hide();
	        	$(".applicationList").hide();
	        	$("#openApp_ApplicationList").hide();
	        	$("#appDetail").show();
	        	$(".btn_openApp").show();
			}
		})
	},
	// 删除应用
	deleteWebApp:function(id,accountId,obj){
		layer.confirm('确定删除该应用？',{icon:3, title:'提示信息'},function(index){
			Common.invoke({
				url:request('/console/deleteOpenApp'),
				data:{
					id:id,
					accountId:accountId
				},
				success:function(result){
					if(result.resultCode==1){
						layui.layer.alert("删除成功");
						obj.del();
					}
				}
			})
		})
	},
	// 申请列表
	applicationList:function(index){
		var html="";
		$("#openWebAppList").hide();
		$("#openApp_ApplicationList").show();
		$(".applicationList").hide();
		$(".btn_openApp").show();
		Common.invoke({
			url:request('/console/openAppList'),
			data:{
				pageIndex:index,
				pageSize:10,
				type:2,
				status:0
			},
			success:function(result){
				console.log(result);
				if(result.resultCode==1){
					// $("#pageCount").val(result.data.length);
					for(var i=0;i<result.data.length;i++){
						html+="<tr><td>"+Common.filterHtmlData(result.data[i].accountId)+"</td><td>"+Common.filterHtmlData(result.data[i].appName)+"</td><td>"
						+Common.filterHtmlData(result.data[i].appIntroduction)+"</td><td>"+Common.filterHtmlData(result.data[i].appUrl)+"</td><td>"
						+UI.getLocalTime(result.data[i].createTime)+"</td><td><a class='layui-btn layui-btn-primary layui-btn-xs' onclick='WebApp.appDetail(\""
						+result.data[i].id+"\")'>详情</a><a class='layui-btn layui-btn-danger layui-btn-xs' onclick='WebApp.deleteWebApp(\""
						+result.data[i].id+"\",\""+result.data[i].accountId+"\")'>删除</a></td></tr>";
					}
					$("#openWebApp_Applicationtbody").empty();
					$("#openWebApp_Applicationtbody").append(html);
				}
			}
		})
	},
	back:function(){

		$("#openWebAppList").show();
		$("#appDetail").hide();
		$(".btn_openApp").hide();
		$(".applicationList").show();
		$("#openApp_ApplicationList").hide();
	},
	// 审核
	approvedAPP:function(status){
		Common.invoke({
			url:request('/console/approvedAPP'),
			data:{
				id: Common.filterHtmlData($("#app_Id").html()),
				userId:localStorage.getItem("account"),
				status:status
			},
			success:function(result){
				if(result.resultCode==1){
					if(status==1){
						layui.layer.alert("审核通过");
						WebApp.appDetail($("#app_Id").html());
					}else if(status==2){
						layui.layer.alert("审核失败");
						WebApp.appDetail($("#app_Id").html());
					}else if(status==-1){

						layui.layer.alert("禁用成功");
						WebApp.appDetail($("#app_Id").html());
					}else{
						layui.layer.alert("状态错误");
					}
				}
				
			}
		})
	},
	// 审核通过分享权限
	checkShare:function(id,type){
		Common.invoke({
			url:request('/console/checkPermission'),
			data:{
				id:id,
				accountId:localStorage.getItem("userId"),
				isAuthShare:type
			},
			success:function(result){
				if(result.resultCode==1){
					WebApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	},
	// 审核登录权限
	checkLogin:function(id,type){
		Common.invoke({
			url:request('/console/checkPermission'),
			data:{
				id:id,
				accountId:localStorage.getItem("userId"),
				isAuthLogin:type
			},
			success:function(result){
				if(result.resultCode==1){
					WebApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	},
	// 审核支付权限
	checkPay:function(id,type){
		Common.invoke({
			url:request('/console/checkPermission'),
			data:{
				id:id,
				accountId:localStorage.getItem("userId"),
				isAuthPay:type
			},
			success:function(result){
				if(result.resultCode==1){
					WebApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	},
	// 审核群助手权限
	checkHelper:function (id,type) {
		Common.invoke({
			url:request('/console/checkPermission'),
			data:{
				id:id,
				accountId:localStorage.getItem("userId"),
				isGroupHelper:type
			},
			success:function(result){
				if(result.resultCode==1){
					WebApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	}
}
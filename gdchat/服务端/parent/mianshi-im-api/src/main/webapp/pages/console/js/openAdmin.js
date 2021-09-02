layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

        //app列表
	    var tableIns = table.render({

	      elem: '#openApp_table'
	      ,url:request("/console/openAppList")+"&type=1"
	      ,id: 'openApp_table'
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
	          ,{field: 'iosAppId', title: 'Bundle ID',sort: true, width:150}
	          ,{field: 'iosBataAppId', title: '测试版本Bundle ID',sort: true, width:200} 
	          ,{field: 'createTime',title:'申请时间',sort: true, width:200,templet: function(d){
	          		return UI.getLocalTime(d.createTime);
	          }}
	          ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#openAppListBar'}
	        ]]
			,done:function(res, curr, count){
				checkRequst(res);
				//获取零时保留的值
				var last_value = $("#openAdmin_limlt").val();
				//获取当前每页大小
				var recodeLimit =  tableIns.config.limit;
				//设置零时保留的值
				$("#openAdmin_limlt").val(recodeLimit);
				//判断是否改变了每页大小数
				if (last_value != recodeLimit){
					// 刷新
					table.reload("openApp_table",{
						url:request("/console/openAppList")+"&type=1",
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
	    table.on('tool(openApp_table)', function(obj){
	        var layEvent = obj.event,
	            data = obj.data;
	        if(layEvent === 'detail'){ //app详情
	        	OpenApp.appDetail(data.id);
	        }else if(layEvent === 'del'){// 删除
	        	OpenApp.deleteOpenApp(data.id,data.accountId,obj);
	        	
	        }
        });

		// 表格操作
		table.on('tool(openApp_Applicationtbody)', function(obj){
			var layEvent = obj.event,
				data = obj.data;
			if(layEvent === 'Application_detail'){ //app详情
				OpenApp.appDetail(data.id);
			}else if(layEvent === 'Application_del'){// 删除
				OpenApp.deleteOpenApp(data.id,data.accountId,obj);
			}
		});

	    // 搜索
	    $(".search_openApp").on("click",function(){
	    	if($(".openApp_keyword").val().indexOf("*")!=-1){
	    		layer.alert("不支持*号搜索")
	    		return;
			}
			$("#openAppList").show();
			$("#openApp_ApplicationList").hide();
			$(".applicationList").show();
			$(".btn_openApp").hide();
	        table.reload("openApp_table",{
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

// $(function(){
// 	OpenApp.limit();
// })
var OpenApp={
	// app详情
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
				$("#accountId").append(Common.filterHtmlData(result.data.accountId));
				$("#appName").empty();
				$("#appName").append(Common.filterHtmlData(result.data.appName));
				$("#appIntroduction").empty();
				$("#appIntroduction").append(Common.filterHtmlData(result.data.appIntroduction));
				$("#appUrl").empty();
				$("#appUrl").append(Common.filterHtmlData(result.data.appUrl));
				$("#appsmallImg").empty();
				$("#appsmallImg").append(Common.filterHtmlData(result.data.appsmallImg));
				$("#appImg").empty();
				$("#appImg").append(Common.filterHtmlData(result.data.appImg));
				$("#appId").empty();
				$("#appId").append(Common.filterHtmlData(result.data.appId));
				$("#appSecret").empty();
				$("#appSecret").append(Common.filterHtmlData(result.data.appSecret));
				$("#iosAppId").empty();
				$("#iosAppId").append(Common.filterHtmlData(result.data.iosAppId));
				$("#iosBataAppId").empty();
				$("#iosBataAppId").append(Common.filterHtmlData(result.data.iosBataAppId));
				$("#iosDownloadUrl").empty();
				$("#iosDownloadUrl").append(Common.filterHtmlData(result.data.iosDownloadUrl));
				$("#androidAppId").empty();
				$("#androidAppId").append(Common.filterHtmlData(result.data.androidAppId));
				$("#androidDownloadUrl").empty();
				$("#androidDownloadUrl").append(Common.filterHtmlData(result.data.androidDownloadUrl));
				$("#androidSign").empty();
				$("#androidSign").append(Common.filterHtmlData(result.data.androidSign));
				$("#payCallBackUrl").empty();
				$("#payCallBackUrl").append(Common.filterHtmlData(result.data.payCallBackUrl));
				if(result.data.isAuthShare==2){
					$("#shareOperate").empty();
					let html = "<button onclick='OpenApp.checkShare(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='OpenApp.checkShare(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#shareOperate").append(html);
				}else {
					$("#shareOperate").empty();
				}

				$("#isAuthShare").empty();
				$("#isAuthShare").append(result.data.isAuthShare==2?"申请中":result.data.isAuthShare==1?"已授权":result.data.isAuthShare==-1?"审核失败":"未获得");
				$("#isAuthLogin").empty();
				$("#isAuthLogin").append(result.data.isAuthLogin==2?"申请中":result.data.isAuthLogin==1?"已授权":result.data.isAuthLogin==-1?"审核失败":"未获得");
				if(result.data.isAuthLogin==2){
					$("#loginOperate").empty();
					let html = "<button onclick='OpenApp.checkLogin(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='OpenApp.checkLogin(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#loginOperate").append(html);
				}else {
					$("#loginOperate").empty();
				}
				$("#isAuthPay").empty();
				$("#isAuthPay").append(result.data.isAuthPay==2?"申请中":result.data.isAuthPay==1?"已授权":result.data.isAuthPay==-1?"审核失败":"未获得");
				if(result.data.isAuthPay==2){
					$("#payOperate").empty();
					let html="<button onclick='OpenApp.checkPay(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='OpenApp.checkPay(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#payOperate").append(html);
				}else {
					$("#payOperate").empty();
				}
				$("#isGroupHelper").empty();
				$("#isGroupHelper").append(result.data.isGroupHelper==2?"申请中":result.data.isGroupHelper==1?"已授权":result.data.isGroupHelper==-1?"审核失败":"未获得");
				if(result.data.isGroupHelper==2){
					$("#HelperOperate").empty();
					let html = "<button onclick='OpenApp.checkHelper(\""+result.data.id+"\",1)' class='layui-btn layui-btn-xs'>通过审核</button>"
						+"<button onclick='OpenApp.checkHelper(\""+result.data.id+"\",-1)' class='layui-btn layui-btn-danger layui-btn-xs'>审核失败</button>";
					$("#HelperOperate").append(html)
				}else{
					$("#HelperOperate").empty();
				}

				$("#createTime").empty();
				$("#createTime").append(UI.getLocalTime(result.data.createTime));

				$("#openAppList").hide();
	        	$(".applicationList").hide();
	        	$("#openApp_ApplicationList").hide();
	        	$("#appDetail").show();
	        	$(".btn_openApp").show();
			}
		})
	},
	// 通过审核
	approvedAPP:function(){
		// console.log($("#app_Id").val());
		Common.invoke({
			url:request('/console/approvedAPP'),
			data:{
				id: Common.filterHtmlData($("#app_Id").html()),
				userId: Common.filterHtmlData(localStorage.getItem("account")),
				status:1
			},
			success:function(result){

				layui.layer.alert("审核通过");
				OpenApp.appDetail($("#app_Id").html());
			}
		})
	},
	// 失败原因
	reasonFailure:function(){
		layui.layer.open({
			title:'失败原因',
			type:1,
			area: ['300px', '200px'],
			content:'<textarea id="get_reason" class="layui-input" type="password" placeholder="" style="margin-top:10%;width:250px;margin-left:25px;resize: none;"></textarea><button class="layui-btn" style="margin-left:40%;margin-top:10%" onclick="OpenApp.auditFailure()">确定</button>'
		})
	},
	// 审核失败
	auditFailure:function(){
		Common.invoke({
			url:request('/console/approvedAPP'),
			data:{
				id: Common.filterHtmlData($("#app_Id").html()),
				userId: Common.filterHtmlData(localStorage.getItem("userId")),
				status:2,
				reason: Common.getValueForElement("#get_reason")
			},
			success:function(result){
				layui.layer.closeAll();
				layui.layer.alert("提交成功");
			}
		})
	},
	// 禁用应用
	disableApp:function(){
		Common.invoke({
			url:request('/console/approvedAPP'),
			data:{
				id: Common.filterHtmlData($("#app_Id").html()),
				userId: Common.filterHtmlData(localStorage.getItem("account")),
				status:-1
			},
			success:function(result){
				layui.layer.alert("禁用成功");
				OpenApp.appDetail($("#app_Id").html());
			}
		})
	},
	// 申请列表
	applicationList:function(index){
		var html="";
		$("#openAppList").hide();
		$("#openApp_ApplicationList").show();
		$(".applicationList").hide();
		$(".btn_openApp").show();

		var tableIns = layui.table.render({
			elem: '#openApp_Applicationtbody'
			,url:request("/console/openAppList")+"&type=1&status=0"
			,id: 'openApp_Applicationtbody'
			,page: true
			,curr: 0
			,limit:Common.limit
			,limits:Common.limits
			,groups: 7
			,cols: [[ //表头
				{field: 'accountId', title: '申请用户Id',sort:'true', width:120}
				,{field: 'appName', title: '应用名称',sort:'true', width:150}
				,{field: 'appIntroduction', title: '应用简介',sort: true, width:150}
				,{field: 'appUrl', title: '应用官网',sort: true, width:150}
				,{field: 'iosAppId', title: 'Bundle ID',sort: true, width:150}
				,{field: 'iosBataAppId', title: '测试版本Bundle ID',sort: true, width:150}
				,{field: 'createTime', title: '申请时间',sort: true, width:200,templet: function(d){
						return UI.getLocalTime(d.createTime);
				}}
				,{fixed: 'right', width: 250,title:"操作", align:'left', toolbar: '#openApp'}
			]]
			,done:function(res, curr, count){

			}
		})

	},
	back:function(){

		$("#openAppList").show();
		$("#appDetail").hide();
		$(".btn_openApp").hide();
		$(".applicationList").show();
		$("#openApp_ApplicationList").hide();
	},
	deleteOpenApp:function(id,accountId,obj){
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
	// 分页
	limit:function(index){
		layui.use('laypage', function(){
        var laypage = layui.laypage;
        console.log($("#pageCount").val());
        var count=$("#pageCount").val();
        //执行一个laypage实例
        laypage.render({
            elem: 'laypage'
            ,count: count
            ,layout: ['count', 'prev', 'page', 'next', 'limit', 'refresh', 'skip']
            ,jump: function(obj){
            	console.log(obj)
            	if(index==1){
            		OpenApp.applicationList(1)
            		index=0;
            	}else{
            		OpenApp.applicationList(obj.curr)
            	}
            	
            }
   		 })
 	   })
	},
	// 审核分享权限
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
					OpenApp.appDetail(id);
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
					OpenApp.appDetail(id);
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
					OpenApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	},
	// 通过群助手权限
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
					OpenApp.appDetail(id);
					layui.layer.alert("操作成功");
				}
			}
		})
	}
}
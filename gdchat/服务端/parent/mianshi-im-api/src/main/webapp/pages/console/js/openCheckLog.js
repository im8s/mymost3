layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;
		
		//日志列表
	    var tableIns = table.render({

	      elem: '#openCheckLog_table'
	      ,url:request("/console/checkLogList")
	      ,id: 'openCheckLog_table'
	      ,page: true
	      ,curr: 0
          ,limit:Common.limit
          ,limits:Common.limits
	      ,groups: 7
	      ,cols: [[ //表头
	           {field: 'accountId', title: '申请用户Id',width:120}
	          ,{field: 'appId', title: 'appId',width:150}
	          ,{field: 'operateUser', title: '操作用户Id', width:150}
	          ,{field: 'status', title: '审核结果',sort: true, width:150,templet:function(d){
	          		return (d.status==1?"审核通过":d.status==2?"审核失败":d.status==0?"审核中":"禁用");
	          }}
	          ,{field: 'reason', title: '审核回馈',sort: true, width:200} 
	          ,{field: 'createTime',title:'操作时间',sort: true, width:200,templet: function(d){
	          		return UI.getLocalTime(d.createTime);
	          }}
	          ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#openCheckLogListBar'}
	        ]]
			,done:function(res, curr, count){
				checkRequst(res);
                if(localStorage.getItem("role")==1){
                    $(".del").hide();
				}
			}
	    });
	    // 表格操作
	    table.on('tool(openCheckLog_table)', function(obj){

			//获取零时保留的值
			var last_value = $("#openChexkLog_limlt").val();
			//获取当前每页大小
			var recodeLimit =  tableIns.config.limit;
			//设置零时保留的值
			$("#openChexkLog_limlt").val(recodeLimit);
			//判断是否改变了每页大小数
			if (last_value != recodeLimit){
				// 刷新
				table.reload("openCheckLog_table",{
					url:request("/console/checkLogList"),
					page: {
						curr: 1 //重新从第 1 页开始
					}
				})
			}

	        var layEvent = obj.event,
	            data = obj.data;
	        if(layEvent === 'del'){ //删除日志
	        	// layer.confirm('确定删除该日志？',{icon:3, title:'提示信息'},function(index){
                layer.confirm('确定删除日志',{icon:3, title:'提示消息',yes:function (index) {
	        		CheckLog.deleteLog(data.id);
	        		layer.close(index); //关闭弹框
                    obj.del();
                }})
	        }
        })

	// 搜索
	$(".search_openApp").on("click",function(){
		table.reload("openCheckLog_table",{
			url:request("/console/checkLogList"),
			page: {
				curr: 1 //重新从第 1 页开始
			},
			where: {
				keyWorld : Common.getValueForElement(".openCheckLog_keyword")  //搜索的关键字
			}
		})

		$(".openCheckLog_keyword").val('');
	});
});

var CheckLog={
	// 删除日志
	deleteLog:function(id){
		Common.invoke({
			url:request('/console/delOpenCheckLog'),
			data:{
				id:id
			},
			success:function(result){
                layer.msg("删除成功",{"icon":1});
			}
		})
	}
}
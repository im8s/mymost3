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
	      ,url:request("/console/checkOfficialInfo")
	      ,id: 'openCheckLog_table'
	      ,page: true
	      ,curr: 0
          ,limit:Common.limit
          ,limits:Common.limits
	      ,groups: 9
	      ,cols: [[ //表头
	           {field: 'id', title: '编号',width:120}
	          ,{field: 'telephone', title: '电话',width:150}
	          ,{field: 'companyType', title: '公司类型',sort: true, width:120,templet:function(d){return (d.companyType==1?"企业":d.companyType==0?"个体工商户":"");}}
	          ,{field: 'createTime',title:'操作时间',sort: true, width:180,templet: function(d){return UI.getLocalTime(d.createTime);}}
	          ,{field: 'companyName', title: '公司名称',width:160}
	          ,{field: 'verify', title: '审核结果',sort: true, width:100,templet:function(d){return (d.verify==1?"审核通过":d.verify==2?"审核不通过":d.verify==0?"审核中":"");}}
	          ,{field: 'feedback', title: '审核回馈', width:200}
	          ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#openCheckLogListBar'}
	          ]]
			,done:function(res, curr, count){
				checkRequst(res);
				//获取零时保留的值
				var last_value = $("#check_limlt").val();
				//获取当前每页大小
				var recodeLimit = tableIns.config.limit;
				$("#check_limlt").val(recodeLimit);
				//判断是否改变了每页大小数
				if (last_value != recodeLimit){
					// 刷新
					table.reload("openCheckLog_table",{
						url:request("/console/checkOfficialInfo"),
						page: {
							curr: 1 //重新从第 1 页开始
						}
					})
				}

                if(localStorage.getItem("role")==1){
                    $(".del").hide();
				}
			}
	    });
	    // 表格操作
	    table.on('tool(openCheckLog_table)', function(obj){
	        var layEvent = obj.event,
	            data = obj.data;
            if (layEvent === 'detail'){
                sessionStorage.setItem("descId",data.id);
                window.location.href="/pages/console/officialDesc.html";
            }

	        if(layEvent === 'del'){ //删除日志
	        	layer.confirm('确定删除该日志？',{icon:3, title:'提示信息'},function(index){
                    layer.close(index);
	        		CheckLog.deleteLog(data.id);
	        		obj.del();
	        	})	
	        }


        })
});

var CheckLog={
	// 删除日志
	deleteLog:function(id){
		Common.invoke({
			url:request('/console/delOfficialInfo'),
			data:{
				id:id
			},
			success:function(result){
				layui.layer.alert("删除成功");
			}
		})
	}
}
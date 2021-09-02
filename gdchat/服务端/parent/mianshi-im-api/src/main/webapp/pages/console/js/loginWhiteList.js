var page=0;
var sum=0;
var updateId="";
layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //pc登录白名单列表
    var tableIns = table.render({

      elem: '#loginWhiteList_table'
      ,url:request("/console/loginWhiteList")
      ,id: 'loginWhiteList_table'
      ,page: false
      ,curr: 0
      ,limit: 1000
      ,limits:Common.limits
      ,groups: 7
      ,cols: [[ //表头
           {field: 'ip', title: 'IP',sort: true, width:250},
			{field: 'typeDesc', title: '端口类型',sort: true, width:250}
          ,{fixed: 'right', title:"操作", align:'left', toolbar: '#loginWhiteListListBar'}
        ]]
		,done:function(res, curr, count){
			checkRequst(res);
		}
    });


    //列表操作
    table.on('tool(loginWhiteList_table)', function(obj){
         var layEvent = obj.event,
            data = obj.data;
            console.log(data);
         if(layEvent === 'delete'){
         	LoginWhiteList.deleteLoginWhiteList(data.ip, data.type);
         }
     });
});
//重新渲染表单
function renderTable() {
    layui.use('table', function () {
        var table = layui.table;//高版本建议把括号去掉，有的低版本，需要加()
        table.reload("loginWhiteList_table", {
            where: {
                keyword: $("#loginWhiteListName").val()  //搜索的关键字
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
    });
}

var LoginWhiteList={
    addLoginWhiteList:function(){
        $("#loginWhiteList_div").hide();
        $("#addLoginWhiteList").show();
        $("#ip").val("");
    },
	commit_addLoginWhiteList:function(){
		Common.invoke({
			url:request('/console/addLoginWhiteList'),
			data:{
                ip:$("#ip").val(),
				type:$("#type").val()
            },
			success:function(result){
				if(result.resultCode==1){
			        $("#ip").val("");
        			$("#loginWhiteList_div").show();
					$("#addLoginWhiteList").hide();
					layui.layer.alert("新增成功");
					layui.table.reload("loginWhiteList_table");
				}
			}

		})
	},
	// 删除
	deleteLoginWhiteList:function(ip, type){
		layer.confirm('确定删除该条记录？',{icon:3, title:'提示信息'},function(index){
			Common.invoke({
				url:request('/console/deleteLoginWhiteList'),
				data:{
					ip: ip,
					type: type
				},
				success:function(result){
					if(result.resultCode==1){
						layui.layer.alert("删除成功");
						layui.table.reload("loginWhiteList_table");
					}
				}
			})
		})
		
	},
	btn_back:function(){
		$("#loginWhiteList_div").show();
		$("#loginWhiteListList").show();
		$("#addLoginWhiteList").hide();
		$("#updateLoginWhiteList").hide();
	}
}
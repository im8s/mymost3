var eum=0;
var page=0;

$(function(){
    var data = localStorage.getItem("company_componyName");
    $("#shiku-card-header").html(data);
	Pro.promptList(0);
	Pro.limit();
})
var Pro={
	//提示消息管理
	promptList:function(e,pageSize){
		html="";
		if(e==undefined){
			e=0;
		}else if(pageSize==undefined){
			pageSize=Common.limit;
		}
		$.ajax({
			type:"POST",
			url:request("/console/department/list1"),
			data:{
                companyId:localStorage.getItem("company_Id")
			},
			dataType:'json',
			async:false,
			success:function(result){
				console.log(result)
				if(result.data!=null){
					for(var i=1;i<result.data.length;i++){
						html += "<div class='layui-colla-item'>" +
                                    "<h2 class='layui-colla-title'>" + result.data[i].departName + "</h2>";
						//result.data[i].employees
						$.each(result.data[i].employees,function (j,data) {

                            html +=	   "<div class='layui-colla-content layui-show' id='" + JSON.stringify(data.id).substring(1,JSON.stringify(data.id).length-1) +  "'>" +
											"<div class='shiku-span'><span><i class='layui-icon' style='height: 20px;color: red;'>&#xe66f;</i>昵称：" + Common.filterHtmlData( JSON.stringify(data.nickname).substring(1,JSON.stringify(data.nickname).length-1) ) + "</span></div>" +
											"<div class='shiku-span'><span>角色：" + (JSON.stringify(data.role)==0?"员工":JSON.stringify(data.role)==1?"部门管理者":JSON.stringify(data.role)==2?"公司管理员":"公司创建者") + "</span></div>" +
                            				"<div class='shiku-span'><span>头衔：" + Common.filterHtmlData( JSON.stringify(data.position).substring(1,JSON.stringify(data.position).length-1) )+ "</span></div>" +
                            				"<div class='shiku-span'><span>是否客服：" + (JSON.stringify(data.isCustomer)==0?"否":"是") + "</span></div>" +
                            				"<div class='shiku-span-btn updateDep' onclick='Pro.updateDep(\""+ JSON.stringify(data.id).substring(1,JSON.stringify(data.id).length-1) +"\")'><span class='layui-btn layui-btn-sm layui-btn-normal'>修改</span></div>" +
                                			"<div class='shiku-span-btn deleteDep'  onclick='Pro.deleteDep(\"" + JSON.stringify(data.departmentId).substring(1,JSON.stringify(data.departmentId).length-1) + "\",\"" + JSON.stringify(data.userId) + "\"," + JSON.stringify(data.id) + "\)'><span class='layui-btn layui-btn-sm layui-btn-normal'>删除</span></div>" +
										"</div>";
						})
                        html +=  "</div>";
					}
                    $("#messageList_table").empty();
                    $("#messageList_table").append(html);

                    layui.element.init();
				}else{
					layer.msg("暂无数据",{"icon":2});
				}
			}
		})
	},


	//查看详情
    querStaffMessage:function(id){
		localStorage.setItem("department_Id",id)
		window.location.href="/pages/console/staffMsg.html";
	},
	//查询单条提示消息
	updateErrorMessage:function(code){
	},
	limit:function(index){
            layui.use('laypage', function(){
                var laypage = layui.laypage;

                //执行一个laypage实例
                laypage.render({
                    elem: 'laypage'
                    ,count: Common.getValueForElement("#pageCount")
					,limit:Common.limit
                    ,limits:Common.limits
                    ,layout: ['count', 'prev', 'page', 'next', 'limit', 'refresh', 'skip']
                    ,jump: function(obj){
                        console.log(obj)
                        page=obj.curr;
                        if(index == 1){
                            Pro.promptList(index,obj.limit);
                            index = 0;
						}else
                        	Pro.promptList(page,obj.limit)
                    }
                })
            })
	},
    /*删除员工*/
    deleteDep:function(depId,userId,id){
        $.ajax({
            type:"POST",
            url:request("/console/web/employee/delete"),
            data:{
                userIds:userId,
                departmentId:depId
            },
            dataType:'json',
            async:true,
            success:function(result){
                location.reload();
            }
        })
    },
    /*修改员工信息*/
    updateDep:function (id) {
        localStorage.setItem("dep_Id",id);
        window.location.href="/pages/console/staffMsg.html";
    }
}
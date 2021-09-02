layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;


    //非管理员登录屏蔽操作按钮
    if(localStorage.getItem("IS_ADMIN")==0){
         $(".appRecharge_div").empty();
    }

    //公司列表
    var tableInCompany = table.render({
      elem: '#companyList_table'
      ,toolbar: '#toolbarUsers'
      ,url:request("/console/web/company/list")
      ,id: 'companyList_table'
      ,page: true
      ,curr: 0
      ,limit:Common.limit
      ,limits:Common.limits
      ,groups: 7
      ,cols: [[ //表头
           //{type:'checkbox',fixed:'left'}// 多选
          {field: 'companyName', title: '公司名称',sort:'true', width:200}
          ,{field: 'createUserId', title: '创建者Id',sort:'true', width:100}
          ,{field: 'empNum', title: '员工数',sort:'true', width:100}
          ,{field: 'createTime', title: '创建时间',sort:'true', width:170,templet: function(d){
          		return UI.getLocalTime(d.createTime);
          }}
          ,{field: 'noticeContent', title: '公司公告',sort:'true', width:300}
          ,{fixed: 'right',title:"操作", align:'left', toolbar: '#toolbarCompanys'}
      ]]
	  ,done:function(res, curr, count){
            //checkRequst(res);
           // if(count==0){
           //   layer.msg("暂无数据",{"icon":2});
           //   //renderTable();
           // }
	  }

    });



     //列表操作
     table.on('tool(companyList_table)', function(obj){
           var layEvent = obj.event,
               data = obj.data;

           if(layEvent === 'companyDetails'){ //删除
             Pro.queryCompanyMessage(data.id , data.companyName);
           }
     });


     //搜索公司
    $("#searchCompany_btn").on("click",function(){

        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();

        table.reload("companyList_table",{
            url:request('/console/web/company/list'),
            page: {
                curr: 1 //重新从第 1 页开始
            },
            where: {
                keyWord : Common.getValueForElement("#searchCompany_keyword")  //搜索的关键字
            }
        })

    });

});



var Pro={

	//查看详情
    queryCompanyMessage:function(id,name){
        localStorage.setItem("company_componyName",name);
        localStorage.setItem("company_Id",id)
		window.location.href="/pages/console/deparMsg.html";
	}
}
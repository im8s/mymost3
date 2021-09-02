layui.use(['form','layer','laydate','table','laytpl'],function(){
 var form = layui.form,
     layer = parent.layer === undefined ? layui.layer : top.layer,
     $ = layui.jquery,
     laydate = layui.laydate,
     laytpl = layui.laytpl,
     table = layui.table;

 //消息拦截列表
 var tableInsLiveRoom = table.render({

  elem: '#keywordIntercept_table'
  ,url:request("/console/msgInterceptList")
  ,id: 'keywordIntercept_table'
  ,page: true
  ,curr: 0
  ,limit:Common.limit
  ,limits:Common.limits
  ,groups: 7
  ,cols: [[ //表头
   {field: 'id', title: 'id',sort: true,width:120}
   ,{field: 'sender', title: '发送人Id',sort: true,width:120}
   ,{field: 'senderName', title: '发送人',sort: true,width:120}
   ,{field: 'receiver', title: '接收人Id',sort: true, width:120}
   ,{field: 'receiverName', title: '接收人',sort: true, width:120}
   ,{field: 'content', title: '消息内容',sort: true, width:120}
   ,{field: 'createTime', title: '时间',sort: true, width:300,templet: function(d){
     return UI.getLocalTime(d.createTime/1000);
    }}
   ,{fixed: 'right', width: 150,title:"操作", align:'left', toolbar: '#keywordInterceptListBar'}
  ]]
  ,done:function(res, curr, count){
   checkRequst(res);
   console.log("shuju" , res)
   //获取零时保留的值
   var last_value = $("#keywordInt_limlt").val();
   //获取当前每页大小
   var recodeLimit =  tableInsLiveRoom.config.limit;
   //设置零时保留的值
   $("#keywordInt_limlt").val(recodeLimit);
   //判断是否改变了每页大小数
   if (last_value != recodeLimit){
    // 刷新
    table.reload("keywordIntercept_table",{
     url:request("/console/msgInterceptList"),
     page: {
      curr: 1 //重新从第 1 页开始
     }
    })
   }

   if(localStorage.getItem("role")==1 || localStorage.getItem("role")==7){
    $(".delete").hide();
   }
   var pageIndex = tableInsLiveRoom.config.page.curr;//获取当前页码
   var resCount = res.count;// 获取table总条数
   currentCount = resCount;
   currentPageIndex = pageIndex;
  }
 });


 //列表操作
 table.on('tool(keywordIntercept_table)', function(obj){
  var layEvent = obj.event,
      data = obj.data;
  if(layEvent === 'delete'){ //删除
   Intercept.deleteKeywordIntercept(data.id);
  }
 });

 //搜索
 $(".search_live").on("click",function(){
  // 关闭超出宽度的弹窗
  $(".layui-layer-content").remove();
  table.reload("keywordIntercept_table",{
   where: {
    userId : Common.getValueForElement("#sender"),  //搜索的关键字
    toUserId: Common.getValueForElement("#receiver"),
    content: Common.getValueForElement("#content"),
    type: Common.getValueForElement("#complaint_select")
   },
   page: {
    curr: 1 //重新从第 1 页开始
   }
  })
  $("#sender").val("");
  $("#receiver").val("");
  $("#content").val("");
 });
});


var Intercept = {
 getKeywordInterceptList:function(){
  if($("#complaint_select").val()==0){
   $("#receiver").attr("placeholder","接收人Id")
   var tableInsLiveRoom = layui.table.render({

    elem: '#keywordIntercept_table'
    ,url:request("/console/msgInterceptList")
    ,id: 'keywordIntercept_table'
    ,page: true
    ,curr: 0
    ,limit:Common.limit
    ,limits:Common.limits
    ,groups: 7
    ,cols: [[ //表头
     {field: 'id', title: 'id',sort: true,width:120}
     ,{field: 'sender', title: '发送人Id',sort: true,width:120}
     ,{field: 'senderName', title: '发送人',sort: true,width:120}
     ,{field: 'receiver', title: '接收人Id',sort: true, width:120}
     ,{field: 'receiverName', title: '接收人',sort: true, width:120}
     ,{field: 'content', title: '消息内容',sort: true, width:120}
     ,{field: 'createTime', title: '时间',sort: true, width:300,templet: function(d){
       return UI.getLocalTime(d.createTime);
      }}
     ,{fixed: 'right', width: 250,title:"操作", align:'left', toolbar: '#keywordInterceptListBar'}
    ]]
    ,done:function(res, curr, count){
     checkRequst(res);
     if(localStorage.getItem("role")==1 || localStorage.getItem("role")==7){
      $(".delete").hide();
     }
     var pageIndex = tableInsLiveRoom.config.page.curr;//获取当前页码
     var resCount = res.count;// 获取table总条数
     currentCount = resCount;
     currentPageIndex = pageIndex;
    }
   });
  }else if($("#complaint_select").val()==1){
   $("#receiver").attr("placeholder","群组Jid")
   var tableInsLiveRoom = layui.table.render({
    elem: '#keywordIntercept_table'
    ,url:request("/console/msgInterceptList")+"&type=1"
    ,id: 'keywordIntercept_table'
    ,page: true
    ,curr: 0
    ,limit:Common.limit
    ,limits:Common.limits
    ,groups: 7
    ,cols: [[ //表头
     {field: 'id', title: 'id',sort: true,width:120}
     ,{field: 'sender', title: '发送人Id',sort: true,width:120}
     ,{field: 'senderName', title: '发送人',sort: true,width:120}
     ,{field: 'roomJid', title: '群组Jid',sort: true, width:120}
     ,{field: 'roomName', title: '群组名称',sort: true, width:120}
     ,{field: 'content', title: '消息内容',sort: true, width:120}
     ,{field: 'createTime', title: '时间',sort: true, width:300,templet: function(d){
       return UI.getLocalTime(d.createTime);
      }}
     ,{fixed: 'right', width: 250,title:"操作", align:'left', toolbar: '#keywordInterceptListBar'}
    ]]
    ,done:function(res, curr, count){
     checkRequst(res);
     if(localStorage.getItem("role")==1 || localStorage.getItem("role")==7){
      $(".delete").hide();
     }
     var pageIndex = tableInsLiveRoom.config.page.curr;//获取当前页码
     var resCount = res.count;// 获取table总条数
     currentCount = resCount;
     currentPageIndex = pageIndex;
    }
   });
  }
 },
 deleteKeywordIntercept:function(id){
  layer.confirm('确定删除？',{icon:3, title:'提示信息'},function(index){

   Common.invoke({
    url:request('/console/deleteMsgIntercept'),
    data:{
     id:id
    },
    success:function(result){
     layer.msg("删除成功",{"icon":1});
     layui.table.reload("keywordIntercept_table");
    }
   })
  });

 }
}

var currentPageIndex;// 当前页码数
var currentCount;// 当前总数

layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        table = layui.table;


    //提示信息列表
    var hintInfoTableIns = table.render({

      elem: '#hitiInfoList_table'
      ,url: request("/console/hitiInfoList")
      ,id: 'hitiInfoList_table'
      ,page: true
      ,curr: 0
      ,limit: Common.limit
      ,limits: Common.limits
      ,groups: 7
      ,cols: [[ //表头
           {field: 'code', title: 'Code', width:150}
          ,{field: 'type', title: 'Type', width:150}
          ,{field: 'zh', title: '中文', width:250}
          ,{field: 'en', title: '英文',sort:'true', width:250}
          ,{field: 'big5', title: '繁体',sort:'true', width:250}
          ,{fixed: 'right',title:"操作", align:'left', toolbar: '#hitiInfoListBar'}
        ]]
        ,done:function(res){

            currentPageIndex = hintInfoTableIns.config.page.curr;//获取当前页码
            currentCount = res.count;// 获取table总条数

        }


    });


    //列表操作
    table.on('tool(hitiInfoList_table)', function(obj){
        var layEvent = obj.event, data = obj.data;
        console.log("delete:"+JSON.stringify(data));

        if(layEvent === 'delete'){ //删除


            layer.confirm('确定删除该提示消息？',{icon:3, title:'提示信息'},function(index){
                Common.invoke({
                    type:"POST",
                    url:request("/console/deleteErrorMessage"),
                    data:{
                        code : data.code
                    },
                    success:function(result){
                        checkRequst(result);
                        if(result.resultCode==1)
                            layer.alert("删除成功");

                        //重载数据
                        Common.tableReload(currentCount,currentPageIndex,1,"hitiInfoList_table");
                    }
                })
            });



        }else if(layEvent === 'modify'){// 修改


            $("#_id").val(data.id);
            $("#codeNum").val(data.code);
            $("#type").val(data.type);
            $("#zh").val(data.zh);
            $("#en").val(data.en);
            $("#big5").val(data.big5);

            $("#errorMessageList").hide();
            $("#addErrorMessage").show();
            $("#code").val("");

        }

    });

})



var Pro={

    // 头部搜索
    findPromptList:function(){
        if($("#code").val().indexOf("*")!=-1){
            layer.alert("不支持*号搜索")
            return;
        }
        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();

        layui.table.reload("hitiInfoList_table",{
            url:request("/console/hitiInfoList"),
            page:{
                curr:1 //重新从第 1 页开始
            },
            where: {
                keyword : Common.getValueForElement("#code")  //搜索的关键字
            }
        })
        $("#code").val("");
    },
    //修改提示消息
    update_errorMessage:function(){

        if($("#codeNum").val()==""){
            layer.alert("请输入必填参数");
            return;
        }else if(!/^[0-9]{4,10}$/.test($("#codeNum").val())){
            layer.alert("Code请输入4-10位数字");
            return ;
        }else if($("#type").val()==""){
            layer.alert("请输入必填参数");
            return;
        }else if($("#zh").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }else if($("#en").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }else if($("#big5").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }

        Common.invoke({
            type:"POST",
            url:request("/console/hitiInfoUpdate"),
            data:{
                id : $("#_id").val(),
                code : Common.getValueForElement("#codeNum"),
                type : Common.getValueForElement("#type"),
                zh : Common.getValueForElement("#zh"),
                en : Common.getValueForElement("#en"),
                big5 : Common.getValueForElement("#big5")
            },
            success:function(result){
                checkRequst(result);
                if(result.data!=null){
                    layer.alert("修改提示消息成功");

                    //重载数据
                    Common.tableReload(currentCount,currentPageIndex,1,"hitiInfoList_table");

                    $("#addErrorMessage").hide();
                    $("#errorMessageList").show();
                    $(".info").val("");
                    $(".insertBtn").show();
                }
            }
        });

    },
    update_bak:function(){
        $("#addErrorMessage").hide();
        $("#errorMessageList").show();
        $(".info").val("");
        $(".insertBtn").show();
    },
    //新增提示消息
    addErrorMessage:function(){

        $(".updateBtn").hide();
        $("#codeNum").val("");

        $("#zh").val("");
        $("#en").val("");
        $("#big5").val("");

        $("#errorMessageList").hide();
        $("#addErrorMessage").show();
        // $("#bacl").empty();
        // $("#back").append(button);

    },
    commit_errorMessage:function(){
        if($("#codeNum").val()==""){
            layer.alert("请输入必填参数");
            return;
        }else if(!/^[0-9]{4,10}$/.test($("#codeNum").val())){
            layer.alert("Code请输入4-10位数字");
            return ;
        }else if($("#type").val()==""){
            layer.alert("请输入必填参数");
            return;
        }else if($("#zh").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }else if($("#en").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }else if($("#big5").val()==""){
            layer.alert("请输入必填参数");
            return ;
        }

        Common.invoke({
            type:"POST",
            url:request("/console/saveErrorMessage"),
            data:{
                code: Common.getValueForElement("#codeNum"),
                type: Common.getValueForElement("#type"),
                zh: Common.getValueForElement("#zh"),
                en: Common.getValueForElement("#en"),
                big5: Common.getValueForElement("#big5")
            },
            success:function(result){
                checkRequst(result);
                if(result.resultCode == 1){

                    layer.msg("新增成功",{"icon":1});
                    $("#addErrorMessage").hide();
                    $("#errorMessageList").show();
                    $(".info").val("");
                    $(".updateBtn").show();

                    //重载数据
                    Common.tableReload(currentCount,currentPageIndex,1,"hitiInfoList_table");

                }else if(result.resultCode == 0){
                    layer.alert(result.resultMsg);
                }
            }
        })
    },



}
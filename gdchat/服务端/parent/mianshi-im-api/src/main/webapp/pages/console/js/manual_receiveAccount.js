layui.use(['form','layer','laydate','table','laytpl'],function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //非管理员登录屏蔽操作按钮
    if(localStorage.getItem("IS_ADMIN")==0){
        $(".bindingSDK_div").empty();
    }
    $("#receiveAccount_select").val("0")
    // 接收者账户列表
    var tableIns = table.render({
        elem: '#receiveAccount_table'
        ,url:request("/manualAdmin/receiveAccountList")+"&type="+$("#receiveAccount_select").val()
        ,page: true
        ,curr: 0
        ,limit:Common.limit
        ,limits:Common.limits
        ,groups: 7
        ,cols: [[ //表头
            {field: 'id', title: '收款账户Id',sort: true,width:250}
            ,{field: 'type', title: '类型',sort: true,width:120,templet : function (d) {
                    return d.type==1?"微信账户":d.type==2?"支付宝账户":"银行卡账户"
                }}
            ,{field: 'url', title: '二维码地址',sort: true, width:250}
            ,{field: 'name', title: '账户名称',sort: true, width:120}
            ,{field: 'payNo', title: '微信或支付宝账号',sort: true, width:200}
            ,{field: 'bankCard', title: '银行卡号',sort: true, width:200}
            ,{field: 'bankName', title: '开户银行名称',sort: true, width:200}
            ,{fixed: 'right', width: 150,title:"操作", align:'left', toolbar: '#receiveAccountBar'}
        ]]
        ,done:function(res, curr, count){
            checkRequst(res);

        }
    });

    // 表格操作
    table.on('tool(receiveAccount_table)', function(obj) {
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        if (layEvent === 'delete') {
            ManualPay.deleteReceiveAccount(data.id);
        }else if(layEvent === 'updateAccountInfo'){
            ManualPay.updateReceiveAccount(data);
        }
    })

    //搜索
    $(".search_receiveAccount").on("click",function(){
        table.reload("receiveAccount_table",{
            url:request("/manualAdmin/receiveAccountList"),
            where: {
                type : Common.getValueForElement("#receiveAccount_select"),
                keyword : Common.getValueForElement(".receiveAccount_keyword")
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
        $(".receiveAccount_keyword").val("");
    })

        // 添加收款人
        $(".add_receiveAccount_btn").on("click",function () {
        $("#updateReceiveAccountId").val("");
        $("#receiveAccountList").hide();
        $("#AddreceiveAccount").show();
        $("#name").val("");
        $("#payNo").val("");
        $("#bankCard").val("");
        $("#bankName").val("");
        $("#receiveCodeImg_update").html("");
        $("#uploadreceiveCodeImg").attr("action",Config.getConfig().uploadUrl+"/upload/UploadServlet");
        if($("#add_Account_type").val()==1||$("#add_Account_type").val()==2){
            $("#bankCard_tr").hide();
            $("#bankName_tr").hide();
            $("#payNo_tr").show();
            $("#url_tr").show();
        }else{
            $("#bankCard_tr").show();
            $("#bankName_tr").show();
            $("#payNo_tr").hide();
            $("#url_tr").hide();
        }
    })

})

var ManualPay = {
    changeSelect:function(){
        if($("#add_Account_type").val()==1||$("#add_Account_type").val()==2){
            $("#bankCard_tr").hide();
            $("#bankName_tr").hide();
            $("#payNo_tr").show();
            $("#url_tr").show();
        }else{
            $("#bankCard_tr").show();
            $("#bankName_tr").show();
            $("#payNo_tr").hide();
            $("#url_tr").hide();
        }
    },
    selectUpdateCodeMsg:function () {
        $("#uploadCodeImg").click();
    },
    uploadCodeMsg:function () {
        var uploadCoverFile=$("#uploadCodeImg")[0].files[0];
        $("#uploadreceiveCodeImg").ajaxSubmit(function(data){
            var obj = eval("(" + data + ")");
            $("#receiveCodeImg_update").html(Common.filterHtmlData(obj.data.images[0].oUrl));
            $("#receiveCodeImg_update").show();
        });
    },
    commit_addReceiveAccount:function(){
        if(!Common.isNil($("#updateReceiveAccountId").val())){
            Common.invoke({
                url:request('/manualAdmin/updateReceiveAccount'),
                data:{
                    id : Common.getValueForElement("#updateReceiveAccountId"),
                    url : Common.filterHtmlData($("#receiveCodeImg_update").html()),
                    type : Common.getValueForElement("#add_Account_type"),
                    name : Common.getValueForElement("#name"),
                    payNo : Common.getValueForElement("#payNo"),
                    bankCard : Common.getValueForElement("#bankCard"),
                    bankName : Common.getValueForElement("#bankName")
                },
                success:function (result) {
                    if(result.resultCode==1){
                        layui.layer.alert("修改成功");
                        ManualPay.btn_back();
                        layui.table.reload("receiveAccount_table");
                    }

                }
            })
            return;
        }
        if(Common.isNil($("#name").val())){
            layui.layer.alert("请输入账户名称")
            return ;
        }
        if($("#add_Account_type").val()==3){
            if(Common.isNil($("#bankCard").val())){
                layui.layer.alert("请输入银行卡号")
                return;
            }
            if(Common.isNil($("#bankName").val())){
                layui.layer.alert("请输入银行名称");
                return;
            }
            Common.invoke({
                url:request("/manualAdmin/addReceiveAccount"),
                data:{
                    url:"",
                    payNo: Common.getValueForElement("#payNo"),
                    type: Common.getValueForElement("#add_Account_type"),
                    name: Common.getValueForElement("#name"),
                    bankCard: Common.getValueForElement("#bankCard"),
                    bankName: Common.getValueForElement("#bankName")
                },
                success:function (result) {
                    if(result.resultCode==1){
                        layui.layer.alert("添加成功");
                        ManualPay.btn_back();
                        layui.table.reload("receiveAccount_table");
                    }
                }
            })
        }else{
            if(Common.isNil($("#payNo").val())){
                layui.layer.alert("请输入微信或支付宝账号");
                return ;
            }
            if(Common.isNil($("#receiveCodeImg_update").html())){
                layui.layer.alert("请上传收款码");
                return;
            }
            Common.invoke({
                url:request("/manualAdmin/addReceiveAccount"),
                data:{
                    url: Common.filterHtmlData($("#receiveCodeImg_update").html()),
                    type: Common.getValueForElement("#add_Account_type"),
                    name: Common.getValueForElement("#name"),
                    payNo: Common.getValueForElement("#payNo"),
                    bankCard: Common.getValueForElement("#bankCard"),
                    bankName: Common.getValueForElement("#bankName")
                },
                success:function (result) {
                    if(result.resultCode==1){
                        layui.layer.alert("添加成功");
                        ManualPay.btn_back();
                        layui.table.reload("receiveAccount_table");
                    }
                }
            })
        }

    },
    deleteReceiveAccount:function(id){
        layer.confirm('确定删除该收款账户？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/manualAdmin/deleteReceiveAccount"),
                data:{
                    id:id
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("删除成功")
                        layui.table.reload("receiveAccount_table");
                    }
                }
            })
        })

    },
    updateReceiveAccount:function(data){
        $("#receiveAccountList").hide();
        $("#AddreceiveAccount").show();
        if(data.type==1||data.type==2){
            $("#bankCard_tr").hide();
            $("#bankName_tr").hide();
            $("#payNo_tr").show();
            $("#url_tr").show();
        }else{
            $("#bankCard_tr").show();
            $("#bankName_tr").show();
            $("#payNo_tr").hide();
            $("#url_tr").hide();
        }
        $("#updateReceiveAccountId").val(Common.filterHtmlData(data.id));
        $("#name").val(Common.filterHtmlData(data.name));
        $("#payNo").val(Common.filterHtmlData(data.payNo));
        $("#bankCard").val(Common.filterHtmlData(data.bankCard));
        $("#bankName").val(Common.filterHtmlData(data.bankName));
        $("#add_Account_type").val(Common.filterHtmlData(data.type));
    },
    btn_back:function () {
        $("#receiveAccountList").show();
        $("#AddreceiveAccount").hide();
    }
}
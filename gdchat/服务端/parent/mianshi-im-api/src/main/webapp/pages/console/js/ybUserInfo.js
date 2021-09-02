layui.use(['form','layer','laydate','table','laytpl'],function() {
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

    // 云钱包用户信息列表
    var tableIns = table.render({

        elem: '#YopUserInfo_table'
        , url: request("/console/yopUserInfo/list")
        , page: true
        , curr: 0
        , limit: Common.limit
        , limits: Common.limits
        , groups: 7
        , cols: [[ //表头
            // {field: 'id', title: '账户信息Id', sort: true, width: 180}
            {field: 'userId', title: 'userId', sort: true, width: 120}
            , {field: 'openAccountName', title: '开户真实姓名', sort: true, width: 150}
            , {field: 'openAccountCardNo', title: '开户身份证号', sort: true, width: 180}
            , {field: 'openAccountTelephone', title: '开户填写手机号', sort: true, width: 160}
            , {field: 'walletUserNo', title: '用户钱包账户ID', sort: true, width: 150}
            , {field: 'walletCategory', title: '账户钱包等级', sort: true, width: 150}
            , {field: 'status', title: '账户状态', sort: true, width: 120,templet:function (d) {
                    return d.status == 1?"正常":"已冻结"
                }}
            , {
                field: 'createTime', title: '创建时间', width: 180, templet: function (d) {
                    return UI.getLocalTime(d.createTime);
                }
            }
            ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#YopUserInfoBar'}
        ]]
        , done: function (res, curr, count) {
            checkRequst(res);

            layui.laydate.render({
                elem: '#YopUserInfoDate'
                ,range: "~"
                ,done: function(value, date, endDate){  // choose end
                    var startDate = value.split("~")[0];
                    var endDate = value.split("~")[1];
                    table.reload("YopUserInfo_table",{
                        page: {
                            curr: 1 //重新从第 1 页开始
                        },
                        where: {
                            startDate : startDate,
                            endDate : endDate
                        }
                    })
                }
                ,max: 0
            });
        }
    });
    // 列表操作
    table.on('tool(YopUserInfo_table)', function(obj){
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        if(layEvent === 'delete'){// 删除
            YopUser.deleteYopUserInfo(data.id);
        }else if(layEvent === "freeze"){// 冻结
            YopUser.freezeYopUser(data.id,-1);
        }else if(layEvent === "unfreeze"){// 解冻
            YopUser.unfreezeYopUser(data.id,1);
        }else if(layEvent === "bill"){// 账单
            $("#YopUserInfo_div").hide();
            $("#YopUserBill_div").show();
            YopUser.goYopUserBill(data.userId);
        }
    });

    //首页搜索
    $(".search_YopUserInfo").on("click",function(){

        // 关闭超出宽度的弹窗
        table.reload("YopUserInfo_table",{
            url:request("/console/yopUserInfo/list"),
            where: {
                keyword : $("#userId").val(), //搜索的关键字
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
        $("#userId").val("");
    });

    //账单搜索
    $(".search_YopUserBill").on("click",function(){

        // 关闭超出宽度的弹窗
        table.reload("YopUserBill_table",{
            url: request("/console/yopBill/bill")+ "&userId="+localStorage.getItem("yopUserBillUserId"),
            where: {
                type : $("#BillType").val(), //搜索的关键字
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
        $("#BillType").val("");
    });
});

var YopUser = {
    deleteYopUserInfo:function (id) {
        layer.confirm('确定删除该钱包账户信息？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/console/yopUserInfo/delete"),
                data:{
                    id:id
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("删除成功");
                        layui.table.reload("YopUserInfo_table");
                    }
                }
            })
        })

    },
    freezeYopUser:function (id,status) {
        layer.confirm('确定冻结该账户？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/console/yopUserInfo/freeze"),
                data:{
                    id:id,
                    status:status
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("操作成功");
                        layui.table.reload("YopUserInfo_table");
                    }
                }
            })
        })

    },
    unfreezeYopUser:function (id,status) {
        layer.confirm('确定解冻账户？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/console/yopUserInfo/freeze"),
                data:{
                    id:id,
                    status:status
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("操作成功");
                        layui.table.reload("YopUserInfo_table");
                    }
                }
            })
        })
    },
    goYopUserBill:function (userId) {
        localStorage.setItem("yopUserBillUserId", userId);
        var tableIns = layui.table.render({

            elem: '#YopUserBill_table'
            , url: request("/console/yopBill/bill")+ "&userId="+userId
            , page: true
            , curr: 0
            , limit: Common.limit
            , limits: Common.limits
            , groups: 7
            , cols: [[ //表头
                {field: 'id', title: '记录Id',sort: true,width:150}
                ,{field: 'businessNo', title: '云钱包交易单号',sort: true,width:180}
                ,{field: 'requestNo', title: '商户请求号',sort: true,width:180}
                ,{field: 'userId', title: '用户Id',sort: true, width:120}
                ,{field: 'userName', title: '用户昵称',sort: true, width:120,templet : function (d) {
                        var userName;
                        (d.userName == "" ? userName = "测试用户" : userName = d.userName);
                        return userName;
                    }}
                ,{field: 'operationAmount', title: '交易金额',sort: true, width:120}
                ,{field: 'payType', title: '支付方式',sort: true, width:120,templet : function (d) {return "云钱包支付";}}
                ,{field: 'orderStatus', title: '交易状态',sort: true, width:120}
                ,{field: 'type', title: '类型',sort: true, width:150, templet : function (d) {
                        var statusMsg;
                        (d.type == 1 ? statusMsg = "充值" : (d.type == 2) ? statusMsg = "提现" : (d.type == 3) ? statusMsg = "转账": (d.type == 4) ? statusMsg = "接收转账": (d.type == 5) ? statusMsg = "一对一红包" : (d.type == 6) ? statusMsg = "群普通红包": (d.type == 7) ? statusMsg = "拼手气红包": statusMsg = "收红包")
                        return statusMsg;
                    }}
                ,{field: 'time',title:'订单时间',width:195,templet : function (d) {
                        console.log('时间',d.time);
                        return UI.getLocalTime(d.time);
                    }}
                // ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#YopUserInfoBar'}
            ]]
            , done: function (res, curr, count) {
                checkRequst(res);

                layui.laydate.render({
                    elem: '#YopUserBillDate'
                    ,range: "~"
                    ,done: function(value, date, endDate){  // choose end
                        var startDate = value.split("~")[0];
                        var endDate = value.split("~")[1];
                        layui.table.reload("YopUserBill_table",{
                            page: {
                                curr: 1 //重新从第 1 页开始
                            },
                            where: {
                                startDate : startDate,
                                endDate : endDate
                            }
                        })
                    }
                    ,max: 0
                });
            }
        });
    },
    button_back:function () {
        $("#YopUserInfo_div").show();
        $("#YopUserBill_div").hide();
    },
    copy:function () {
        // Common.invoke({
        //     url:request("/console/yopUserInfo/dataCopy"),
        //     data:{
        //     },
        //     success:function (result) {
        //         if(result.resultCode == 1){
        //             layui.layer.alert("操作成功");
        //             layui.table.reload("YopUserInfo_table");
        //         }
        //     }
        // })
    }
}
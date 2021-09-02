layui.use(['form','layer','laydate','table','laytpl'],function() {
    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

    //非管理员登录屏蔽操作按钮
    if (localStorage.getItem("IS_ADMIN") == 0) {
        $(".bindingSDK_div").empty();
    }

    // 充值申请账户列表
    var tableIns = table.render({
        elem: '#checkRecharge_table'
        ,url:request("/manualAdmin/getRechargeList")
        ,page: true
        ,curr: 0
        ,limit:Common.limit
        ,limits:Common.limits
        ,groups: 7
        ,cols: [[ //表头
            {field: 'userId', title: '充值用户Id',sort: true,width:100}
            ,{field: 'nickName', title: '用户昵称',sort: true,width:120}
            ,{field: 'money', title: '充值金额',sort: true, width:120}
            ,{field: 'currentMoney', title: '当前余额',sort: true, width:120}
            ,{field: 'type', title: '充值方式',sort: true, width:120,templet : function (d) {
                    return d.type==1?"微信充值":d.type==2?"支付宝充值":"银行卡充值"
                }}
            ,{field: 'orderNo', title: '订单号',sort: true, width:200}
            // ,{field: 'serviceCharge', title: '手续费',sort: true, width:120}
            // ,{field: 'actualMoney', title: '实际金额',sort: true, width:120}
            ,{field: 'status', title: '状态',sort: true, width:120,templet:function (d) {
                    return d.status == 1?"申请中":d.status == 2?"已完成":"已忽略";
                }}
            ,{field: 'createTime', title: '时间',sort: true, width:190,templet:function (d) {
                    return UI.getLocalTime(d.createTime);
                }}
            ,{fixed: 'right', width: 200,title:"操作", align:'left', toolbar: '#checkRechargeBar'}
        ]]
        ,done:function(res, curr, count){
            checkRequst(res);

            var totalInfo = JSON.parse(res.totalVo);
            $(".totalRecharge").empty().text(Common.filterHtmlData(totalInfo.totalRecharge));
            $(".successRecharge").empty().text(Common.filterHtmlData(totalInfo.successRecharge));
            $(".failureRecharge").empty().text(Common.filterHtmlData(totalInfo.failureRecharge));
            $(".applyRecharge").empty().text((Common.filterHtmlData(totalInfo.applyRecharge)));

            layui.laydate.render({
                elem: '#checkRechargeDate'
                ,range: "~"
                ,done: function(value, date, endDate){  // choose end
                    var startDate = value.split("~")[0];
                    var endDate = value.split("~")[1];

                    table.reload("checkRecharge_table",{
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

    // 表格操作
    table.on('tool(checkRecharge_table)', function(obj) {
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        if (layEvent === 'delete') {
            Manual_Rech.deleteRecharge(data.id);
        }else if(layEvent === "approve"){
            Manual_Rech.approveRecharge(data.id);
        }else if(layEvent === "ignore"){
            Manual_Rech.ignoreRecharge(data.id);
        }
    })

    // 搜索
    $(".search_checkRecharge").on("click",function(){
        table.reload("checkRecharge_table",{
            url:request("/manualAdmin/getRechargeList"),
            where: {
                keyword : Common.getValueForElement(".checkRecharge_keyword")
            },
            page: {
                curr: 1 //重新从第 1 页开始
            },
            done:function(res, curr, count){
                checkRequst(res);

                var totalInfo = JSON.parse(res.totalVo);
                $(".totalRecharge").empty().text(Common.filterHtmlData(totalInfo.totalRecharge));
                $(".successRecharge").empty().text(Common.filterHtmlData(totalInfo.successRecharge));
                $(".failureRecharge").empty().text(Common.filterHtmlData(totalInfo.failureRecharge));
                $(".applyRecharge").empty().text((Common.filterHtmlData(totalInfo.applyRecharge)));


            }
        })
    })
})

var Manual_Rech={
    // 通过
    approveRecharge:function (id) {
        layer.confirm('确定通过审核条充值申请？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/manualAdmin/checkRecharge"),
                data:{
                    id:id,
                    status:2
                },
                success:function (result) {
                    if(result.resultCode == 1) {
                        layui.layer.alert("审核成功");
                        layui.table.reload("checkRecharge_table");
                    }
                }
            })
        })
    },
    // 忽略
    ignoreRecharge:function (id) {
        layer.confirm('确定忽略该条充值申请？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/manualAdmin/checkRecharge"),
                data:{
                    id:id,
                    status:-1
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("忽略成功");
                        layui.table.reload("checkRecharge_table");
                    }
                }
            })
        })
    },
    deleteRecharge:function (id) {
        layer.confirm('确定删除该条充值申请？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request("/manualAdmin/deleteRecharge"),
                data:{
                    id:id
                },
                success:function (result) {
                    if(result.resultCode == 1){
                        layui.layer.alert("删除成功");
                        layui.table.reload("checkRecharge_table");
                    }
                }
            })
        })
    }
}
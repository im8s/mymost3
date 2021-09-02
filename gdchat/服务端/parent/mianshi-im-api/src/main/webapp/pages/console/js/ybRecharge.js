/*云钱包充值*/
var page=0;
var sum=0;
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
    // APP充值列表列表
    var tableIns = table.render({

        elem: '#appRecharge_table'
        ,url:request("/console/yopBill/bill") + "&type=1"
        ,page: true
        ,curr: 0
        ,limit:Common.limit
        ,limits:Common.limits
        ,groups: 7
        ,cols: [[ //表头
            {field: 'id', title: '充值记录Id',sort: true,width:150}
            ,{field: 'businessNo', title: '云钱包交易单号',sort: true,width:180}
            ,{field: 'requestNo', title: '商户请求号',sort: true,width:180}
            ,{field: 'userId', title: '用户Id',sort: true, width:120}
            ,{field: 'userName', title: '用户昵称',sort: true, width:120,templet : function (d) {
                    var userName;
                    (d.userName == "" ? userName = "测试用户" : userName = d.userName);
                    return userName;
                }}
            ,{field: 'operationAmount', title: '充值金额',sort: true, width:120}
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
            /*,{field: 'completeTime',title:'完成订单时间',width:195,templet : function (d) {
                    return UI.getLocalTime(d.completeTime);
                }}*/
        ]]
        ,done:function(res, curr, count){
            checkRequst(res);
            //获取零时保留的值
            var last_value = $("#ybRechanrge_limlt").val();
            //获取当前每页大小
            var recodeLimit =  tableIns.config.limit;
            //设置零时保留的值
            $("#ybRechanrge_limlt").val(recodeLimit);
            //判断是否改变了每页大小数
            if (last_value != recodeLimit){
                // 刷新
                table.reload("appRecharge_table",{
                    url:request("/console/yopBill/bill") + "&type=1",
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                })
            }


            // 初始化时间控件
            ///layui.form.render('select');
            //日期范围
            layui.laydate.render({
                elem: '#appRechargeMsgDate'
                ,range: "~"
                ,done: function(value, date, endDate){  // choose end
                    //console.log("date callBack====>>>"+value); //得到日期生成的值，如：2017-08-18
                    var startDate = value.split("~")[0];
                    var endDate = value.split("~")[1];


                    // Count.loadGroupMsgCount(roomJId,startDate,endDate,timeUnit);
                    table.reload("appRecharge_table",{
                        page: {
                            curr: 1 //重新从第 1 页开始
                        },
                        where: {
                            // userId : data.userId,  //搜索的关键字
                            startDate : startDate,
                            endDate : endDate
                        }
                    })
                }
                ,max: 0
            });

            var total = 0;
            for (var i = 0; i < res.data.length; i++) {
                total = total + res.data[i].operationAmount;
            }

            $(".current_total").empty().text(total);
            if(localStorage.getItem("IS_ADMIN")==0){
                $(".btn_addLive").hide();
                $(".delete").hide();
                $(".chatMsg").hide();
                $(".member").hide();
            }
        }
    });

    // 列表操作
    table.on('tool(redEnvelope_table)', function(obj){
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        if(layEvent === 'delete'){// 红包领取详情

        }
    });

    //首页搜索
    $(".search_live").on("click",function(){
        var d = Common.getValueForElement("#userId");
        if (isNaN(d)){
            layer.msg("请输入正确的用户编号！",{"icon":2});
            return;
        }
        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();
        table.reload("appRecharge_table",{
            url:request("/console/yopBill/getYobill")+"&type=1",
            where: {
                userId : Common.getValueForElement("#userId"), //搜索的关键字
                //type :$("#complaint_select").val(),
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
        $("#userId").val("");
        $("#complaint_select").val(0);
    });


});
var appRecharge={
    // 删除账单记录
    btn_back:function(){
        $("#redEnvelope").show();
        $("#receiveWater").hide();

    }

}
layui.use(['form','layer','laydate','table','laytpl'],function(){
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
    $("#complaint_select").val("0");
    // 举报列表
    var tableIns = table.render({

        elem: '#report_table'
        ,url:request("/console/beReport")+"&type="+Common.getValueForElement("#complaint_select")
        ,page: true
        ,curr: 0
        ,limit:Common.limit
        ,limits:Common.limits
        ,groups: 7
        ,cols: [[ //表头
            {field: 'userId', title: '举报人Id',sort: true,width:120}
            ,{field: 'userName', title: '举报人昵称',sort: true,width:150}
            ,{field: 'toUserId', title: '被举报人Id',sort: true, width:150}
            ,{field: 'toUserName', title: '被举报人昵称',sort: true, width:150}
            ,{field: 'info', title: '举报原因',sort: true, width:200}
            ,{field: 'time', title: '举报时间',sort: true, width:200,templet : function (d) {
                    return UI.getLocalTime(d.time);
                }}
            ,{fixed: 'right', width: 150,title:"操作", align:'left', toolbar: '#reportUserListBar'}
        ]]
        ,done:function(res, curr, count){
            checkRequst(res);
            //获取零时保留的值
            var last_value = $("#report_limlt").val();
            //获取当前每页大小
            var recodeLimit =  tableIns.config.limit;
            //设置零时保留的值
            $("#report_limlt").val(recodeLimit);
            //判断是否改变了每页大小数
            if (last_value != recodeLimit){
                // 刷新
                table.reload("report_table",{
                    url:request("/console/beReport")+"&type="+Common.getValueForElement("#complaint_select"),
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                })
            }

            if(localStorage.getItem("role")==1){
                $(".delete").hide();
            }
        }
    });

    // 列表操作
    table.on('tool(report_table)', function(obj){
        var layEvent = obj.event,
            data = obj.data;
        console.log(data);
        if(layEvent === 'delete'){// 删除举报用户记录
            Rep.deleteReport(data.id);
        }else if(layEvent === 'lockingUser'){// 封号
            Rep.lockIngUser(data.toUserId,-1);
        }else if(layEvent === 'cancelLockingUser'){// 解封
            Rep.lockIngUser(data.toUserId,1);
        }else if(layEvent === 'lockingRoom'){// 封群
            Rep.lockIngRoom(localStorage.getItem("account"),data.roomId,-1);
        }else if(layEvent === 'cancelLockingRoom'){// 解封
            Rep.lockIngRoom(localStorage.getItem("account"),data.roomId,1);
        }else if(layEvent === 'lockingWeb'){// 禁用网页
            Rep.lockIngWeb(data.id,-1);
        }else if(layEvent === 'cancelLockingWeb'){// 解禁网页
            Rep.lockIngWeb(data.id,1);
        }
    });

    // 搜索
    $(".search_report").on("click",function(){
        table.reload("report_table",{
            url:request("/console/beReport"),
            where: {
                sender : Common.getValueForElement("#sender"), //搜索的关键字
                receiver: Common.getValueForElement("#receiver"),
                type : Common.getValueForElement("#complaint_select")
            },
            page: {
                curr: 1 //重新从第 1 页开始
            }
        })
        $("#sender").val("")
        $("#receiver").val("")

    })

    // 切换选择
    form.on('select',function (data) {
        console.log("ssssss")
        console.log(data.value)
        if(data.value==0){
            Rep.reportUser();
            $('#receiver').attr('placeholder','被举报人Id');
        }else if(data.value == 1){
            Rep.reportRoom();
            $('#receiver').attr('placeholder','被举报群组roomId');
        }else {
            Rep.reportWeb();
            $('#receiver').attr('placeholder','被举报的网页地址');
        }
    })
});

function renderTable(){
    layui.use('table', function(){
        var table = layui.table;//高版本建议把括号去掉，有的低版本，需要加()
        table.reload("report_table",{
            page: {
                curr: 1 //重新从第 1 页开始
            },
            where: {

            }
        })
    });
}

var Rep = {
    reportUser:function(){
        // 举报列表
        var tableIns = layui.table.render({

            elem: '#report_table'
            ,url:request("/console/beReport")+"&type="+Common.getValueForElement("#complaint_select")
            ,page: true
            ,curr: 0
            ,limit:Common.limit
            ,limits:Common.limits
            ,groups: 7
            ,cols: [[ //表头
                {field: 'userId', title: '举报人Id',sort: true,width:120}
                ,{field: 'userName', title: '举报人昵称',sort: true,width:150}
                ,{field: 'toUserId', title: '被举报人Id',sort: true, width:150}
                ,{field: 'toUserName', title: '被举报人昵称',sort: true, width:150}
                ,{field: 'info', title: '举报原因',sort: true, width:200}
                ,{field: 'time', title: '举报时间',sort: true, width:200,templet : function (d) {
                        return UI.getLocalTime(d.time);
                    }}
                ,{fixed: 'right', width: 150,title:"操作", align:'left', toolbar: '#reportUserListBar'}

            ]]
            ,done:function(res, curr, count){
                checkRequst(res);

                if(localStorage.getItem("role")==1){
                    $(".delete").hide();
                }
            }
        });
        // renderTable();
    },
    reportRoom:function () {
        var tableIns = layui.table.render({
            elem: '#report_table'
            ,url:request("/console/beReport")+"&type="+Common.getValueForElement("#complaint_select")
            ,page: true
            ,curr: 0
            ,limit:Common.limit
            ,limits:Common.limits
            ,groups: 7
            ,cols: [[ //表头
                {field: 'userId', title: '举报人Id',sort: true,width:120}
                ,{field: 'userName', title: '举报人昵称',sort: true,width:150}
                ,{field: 'roomId', title: '被举报群组roomId',sort: true, width:150}
                ,{field: 'roomName', title: '被举报群组昵称',sort: true, width:150}
                ,{field: 'info', title: '举报原因',sort: true, width:200}
                ,{field: 'time', title: '举报时间',sort: true, width:200,templet : function (d) {
                        return UI.getLocalTime(d.time);
                    }}
                ,{fixed: 'right', width: 150,title:"操作", align:'left', toolbar: '#reportRoomListBar'}

            ]]
            ,done:function(res, curr, count){
                checkRequst(res);

                if(localStorage.getItem("role")==1){
                    $(".delete").hide();
                }
            }
        });
    },
    reportWeb:function () {
        // 举报列表
        var tableIns = layui.table.render({
            elem: '#report_table'
            ,url:request("/console/beReport")+"&type="+Common.getValueForElement("#complaint_select")
            ,page: true
            ,curr: 0
            ,limit:Common.limit
            ,limits:Common.limits
            ,groups: 7
            ,cols: [[ //表头
                {field: 'userId', title: '举报人Id',sort: true,width:120}
                ,{field: 'userName', title: '举报人昵称',sort: true,width:150}
                ,{field: 'webUrl', title: '被举报的网页地址',sort: true, width:200}
                ,{field: 'info', title: '举报原因',sort: true, width:200}
                ,{field: 'time', title: '举报时间',sort: true, width:200,templet : function (d) {
                        return UI.getLocalTime(d.time);
                    }}
                ,{fixed: 'right', width: 180,title:"操作", align:'left', toolbar: '#reportWebListBar'}

            ]]
            ,done:function(res, curr, count){
                checkRequst(res);

                if(localStorage.getItem("role")==1){
                    $(".delete").hide();
                }
            }
        });
    },
    deleteReport:function (id) {
        layer.confirm('确定删除该举报内容？',{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url:request('/console/deleteReport'),
                data:{
                    id:id
                },
                success:function(result){
                    if(result.resultCode==1){
                        layer.msg("删除成功",{"icon":1});
                        renderTable()
                    }
                }
            })
        })
    },
    // 用户锁定/解锁
    lockIngUser:function(userId,status){
        var confMsg,successMsg="";
        (status == -1 ? confMsg = '确定对该用户做封号处理？':confMsg = '确定解封该用户的账号？');
        (status == -1 ? successMsg = "封号成功":successMsg ="解封成功");
        layer.confirm(confMsg,{icon:3, title:'提示信息'},function(index){
            Common.invoke({
                url : request('/console/changeStatus'),
                data : {
                    userId:userId,
                    status:status
                },
                successMsg : successMsg,
                errorMsg :  "加载数据失败，请稍后重试",
                success : function(result) {
                    renderTable()
                },
                error : function(result) {
                }
            });
        })
    },
    // 群组锁定/解锁
    lockIngRoom:function(userId,roomId,status){
        console.log(" ======》 "+userId+"   =====  "+roomId+"  ====="+status)
        var confMsg,successMsg="";
        (status == -1 ? confMsg = '确定封锁该群组？':confMsg = '确定解封该群组？');
        (status == -1 ? successMsg = "封群成功":successMsg ="解封成功");
        layer.confirm(confMsg,{icon:3, title:'提示信息'},function(index){

            Common.invoke({
                url : request('/console/updateRoom'),
                data : {
                    userId:userId,
                    roomId:roomId,
                    s:status
                },
                successMsg : successMsg,
                errorMsg :  "加载数据失败，请稍后重试",
                success : function(result) {
                    renderTable()
                },
                error : function(result) {
                }
            });
        })
    },
    // 网页锁定/解锁
    lockIngWeb:function(webUrlId,webUrlStatus){
        console.log(" ===== webUrlId ==== : "+webUrlId +" ==== webUrlStatus ==== : "+webUrlStatus);
        var confMsg,successMsg="";
        (webUrlStatus == -1 ? confMsg = '确定禁用该网页地址？':confMsg = '确定解禁该网页地址？');
        (webUrlStatus == -1 ? successMsg = "禁用成功":successMsg ="解禁成功");
        layer.confirm(confMsg,{icon:3, title:'提示信息'},function(index){

            Common.invoke({
                url : request('/console/isLockWebUrl'),
                data : {
                    webUrlId:webUrlId,
                    webStatus:webUrlStatus,
                },
                successMsg : successMsg,
                errorMsg :  "加载数据失败，请稍后重试",
                success : function(result) {
                    renderTable()
                },
                error : function(result) {
                }
            });
        })
    }
}
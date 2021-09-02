$(function () {
    var operate  = localStorage.getItem("operate");
    if (operate == 1){
        $("#shiku-card-header").append("添加部门");
        $("#shiku-from-yg-update").hide();
        $("#shiku-from-bm-update").hide();
        $("#shiku-from-bm-addEmp").hide();
    }else if(operate == 2){
        $("#shiku-card-header").append("修改部门");
        $("#shiku-from-yg-update").hide();
        $("#shiku-from-bm-add").hide();
        $("#shiku-from-bm-addEmp").hide();
        loadDepMsg()
    }else if(operate == 3){
        $("#shiku-card-header").append("添加员工");
        $("#shiku-from-bm-add").hide();
        $("#shiku-from-bm-update").hide();
        $("#shiku-from-yg-update").hide();
    }else{
        $("#shiku-card-header").append("修改员工信息");
        $("#shiku-from-bm-add").hide();
        $("#shiku-from-bm-update").hide();
        $("#shiku-from-bm-addEmp").hide();
        load();
    }

    function loadDepMsg() {
        //加载页面信息
        $.ajax({
            type:"POST",
            url:request("/console/department/all"),
            data:{
                companyId: Common.filterHtmlData(localStorage.getItem("company_Id"))
            },
            dataType:'json',
            async:true,
            success:function(result){

                $("#newDepartName").val( Common.filterHtmlData(localStorage.getItem("shiku_dep_name")) );
                if(result.data!=null){
                    /*渲染下拉框数据*/
                    for(var i=0;i<result.data.length;i++){
                        if (localStorage.getItem("shiku_dep_id") != result.data[i].id){
                            $("#moveDep").append("<option value='"+ result.data[i].id + "'>"+ Common.filterHtmlData(result.data[i].departName) +"</option>");
                        }
                    }
                    layui.form.render();
                }
            }
        })
    }

    function load(){
        //加载页面信息
        $.ajax({
            type:"POST",
            url:request("/console/department/all"),
            data:{
                companyId:localStorage.getItem("company_Id")
            },
            dataType:'json',
            async:true,
            success:function(result){
                console.log(result)
                if(result.data!=null){
                    /*渲染下拉框数据*/
                    for(var i=1;i<result.data.length;i++){
                        $("#dep").append("<option value='"+ result.data[i].id + "'>"+ Common.filterHtmlData(result.data[i].departName) +"</option>");
                    }
                    layui.form.render();

                    $.ajax({
                        type:"POST",
                        url:request("/console/employee/msg"),
                        data:{
                            id:localStorage.getItem("shiku_dep_id")
                        },
                        dataType:'json',
                        async:false,
                        success:function(result){
                            console.log(result)
                            if(result.data!=null){
                                $("#chatNum").val(result.data.chatNum);
                                $("#isPause").val(result.data.isPause);
                                $("#companyId").val(result.data.companyId);
                                $("#userId").val(result.data.userId);
                                $("#operationType").val(result.data.operationType);

                                $("#depId").val(result.data.id);
                                $("#nickname").val(result.data.nickname);
                                $("#position").val(result.data.position);
                                $("#isCustomer").val(result.data.isCustomer);
                                $("#role").val(result.data.role);
                                $("#dep").val(result.data.departmentId);
                            }
                            layui.form.render();
                        }
                    })
                }
            }
        })
    }


    /*提交表单*/
    $("#shiku-submit").click(function () {
        $.ajax({
            type:"POST",
            url:request("/console/update/employee"),
            data:{
                chatNum:$("#chatNum").val(),
                isPause:$("#isPause").val(),
                companyId:$("#companyId").val(),
                userId:$("#userId").val(),
                operationType:$("#operationType").val(),
                id: $("#depId").val(),
                //头衔
                position:$("#position").val(),
                //昵称
                nickname:$("#nickname").val(),
                //是否公众号
                isCustomer:$("#isCustomer").val(),
                //新角色
                role:$("#role").val(),
                //新部门
                departmentId:$("#dep").val()
            },
            dataType:'json',
            async:false,
            success:function(result){
                if(result.resultCode==1){
                    alert("成功修改！")
                }
                history.go(-1)
            }
        })
    })

    /*添加部门*/
    $("#shiku-submit-add").click(function () {

        if ($("#departName").val() == null || $("#departName").val().length <=0){
            layer.msg("请输入部门名称！");
            return;
        }

        if (localStorage.getItem("shiku_dep_id") == 0){
            localStorage.setItem("shiku_dep_id",localStorage.getItem("company_Id"));
        }
        $.ajax({
            type:"POST",
            url:request("/console/add/deparment"),
            data:{
                companyId : Common.filterHtmlData(localStorage.getItem("company_Id")),
                parentId : Common.filterHtmlData(localStorage.getItem("shiku_dep_id")),
                departName : Common.getValueForElement("#departName"),
                createUserId : Common.filterHtmlData(localStorage.getItem("adminId"))
            },
            dataType:'json',
            async:false,
            success:function(result){
                if(result.resultCode==1){
                    alert("添加成功！")
                    history.go(-1)
                }else{
                    layer.msg(result.resultMsg);
                }

            },
            error:function (result) {
                layer.msg(result.resultMsg);
            }
        })
    })

    /*修改部门信息*/
    $("#shiku-submit-upadte").click(function () {

        if ($("#newDepartName").val() == null || $("#newDepartName").val().length <=0){
            layer.msg("请输入部门名称！");
            return;
        }

        $.ajax({
            type:"POST",
            url:request("/console/update/department"),
            data:{
                //当前部门编号
                departmentId: Common.filterHtmlData(localStorage.getItem("shiku_dep_id")),
                //修改的部门名称
                newDpartmentName: Common.filterHtmlData("#newDepartName"),
                //移动到那个部门
                newDepId: Common.getValueForElement("#moveDep"),
                //旧部门名称
                oldDpartmentName: Common.filterHtmlData(localStorage.getItem("shiku_dep_name"))
            },
            dataType:'json',
            async:false,
            success:function(result){
                if(result.resultCode==1){
                    alert("修改成功！")
                    history.go(-1)
                }else{
                    layer.msg(result.resultMsg);
                }

            },
            error:function (result) {
                layer.msg(result.resultMsg);
            }
        })
    })


    $("#bm-userId").blur(function () {
        //不为空操作
        if ($("#bm-userId").val() == null || $("#bm-userId").val().length <=0){
            $("#bm-userId").val("")
            layer.msg("请输入用户编号！");
            return;
        }
        //判断是否是数字
        if (isNaN($("#bm-userId").val().trim())){
            $("#bm-userId").val("")
            layer.msg("请输入正确的用户编号！");
            return;
        }
    })

   /* 部门添加员工*/
    $("#shiku-submit-addEmp").click(function () {

        //不为空操作
        if ($("#bm-userId").val() == null || $("#bm-userId").val().length <=0){
            $("#bm-userId").val("")
            layer.msg("请输入用户编号！");
            return;
        }
        //判断是否是数字
        if (isNaN($("#bm-userId").val().trim())){
            $("#bm-userId").val("")
            layer.msg("请输入正确的用户编号！");
            return;
        }

        $.ajax({
            type:"POST",
            url:request("/console/web/employee/add"),
            data:{
                telephone: Common.getValueForElement("#bm-userId"),
                companyId: Common.filterHtmlData(localStorage.getItem("company_Id")),
                departmentId:Common.filterHtmlData(localStorage.getItem("shiku_dep_id")),
                role: Common.getValueForElement("#bm-role")
            },
            dataType:'json',
            async:false,
            success:function(result){
                console.log(result)
                if(result.resultCode==1 && result.data =="101980"){
                    layer.msg("用户已存在！",{icon: 2});
                }else if(result.resultCode==1){
                    alert("添加成功！")
                    history.go(-1)
                }else if (result.resultCode == 100211){
                    layer.msg("不存在该用户",{icon: 2});
                }else{
                    layer.msg(result.data);
                }
            },
            error:function (result) {
                layer.msg("该用户已存在！");
            }
        })

    })

})

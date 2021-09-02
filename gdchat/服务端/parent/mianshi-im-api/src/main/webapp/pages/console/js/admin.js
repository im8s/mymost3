var currentPageIndex;// 当前页码数
var currentCount;// 当前总数
layui.use(['form','layer','laydate','table','laytpl'],function(){

    var form = layui.form,
        layer = parent.layer === undefined ? layui.layer : top.layer,
        $ = layui.jquery,
        laydate = layui.laydate,
        laytpl = layui.laytpl,
        table = layui.table;

	 //管理员列表
    var tableIns = table.render({

      elem: '#admin_list'
      ,url:request("/console/adminList")+"&adminId="+localStorage.getItem("adminId")+"&type="+"0"+"&userId="+localStorage.getItem("account")
      ,id: 'admin_list'
      ,page: true
      ,curr: 0
      ,limit:Common.limit
      ,limits:Common.limits
      ,groups: 7
      ,cols: [[ //表头
           {field: 'userId', title: 'userId', width:150}
          ,{field: 'phone', title: '账号', width:150}
          ,{field: 'nickName', title: '昵称', width:150}
          ,{field: 'role', title: '角色',sort:'true', width:150,templet: function(d){
          		if(d.role==5){return "普通管理员"}
          		else if(d.role==6){return "超级管理员"}
          }}
      	  ,{field: 'status', title: '状态',sort:'true', width:100,templet: function(d){
          		if(d.status==1){return "正常"}
          		else if(d.status==-1){return "禁用"}
          }}
          ,{field: 'createTime', title: '创建时间',sort:'true', width:200,templet: function(d){
          		return UI.getLocalTime(d.createTime);
          }}
          ,{field: 'lastLoginTime', title: '最后登录时间',sort:'true', width:200,templet: function(d){
          		
      			if(d.lastLoginTime==0 || d.lastLoginTime=='0'){ return "---";}
      			else{ return UI.getLocalTime(d.lastLoginTime);}
          }}
          ,{fixed: 'right', width: 250,title:"操作", align:'left', toolbar: '#adminListBar'}
        ]]
        ,done:function(res){
            checkRequst(res);

            //获取零时保留的值
            var last_value = $("#admin_last").val();
            //获取当前每页大小
            var recodeLimit = tableIns.config.limit;
            //设置零时保留的值
            $("#admin_last").val(recodeLimit);
            //判断是否改变了每页大小数
            if (last_value != recodeLimit){
                // 刷新
                table.reload("admin_list",{
                    url:request("/console/adminList")+"&adminId="+localStorage.getItem("adminId")+"&type="+"0"+"&userId="+localStorage.getItem("account"),
                    page: {
                        curr: 1 //重新从第 1 页开始
                    }
                })
            }


            if(localStorage.getItem("role")==1){
                $(".delete").hide();
                $(".randUser").hide();
                $(".locking").hide();
                $(".cancelLocking").hide();
            }
            var pageIndex = tableIns.config.page.curr;//获取当前页码
            var resCount = res.count;// 获取table总条数
            currentCount = resCount;
            currentPageIndex = pageIndex;
        }
    });

    
    //列表操作
    table.on('tool(admin_list)', function(obj){
        var layEvent = obj.event, data = obj.data;
        console.log("delete:"+JSON.stringify(data));
        if(layEvent === 'delete'){ //删除

         	layer.confirm('确定删除该管理员？',{icon:3, title:'提示信息'},function(index){
         			
         			Common.invoke({
					      url : request('/console/delAdmin'),
					      data : {
                            "adminId" :data.userId,
                              "type":data.role
			          	},
					    successMsg : "删除管理员成功",
					    errorMsg :  "删除管理员失败，请稍后重试",
					    success : function(result) {
					    	layer.close(index); //关闭弹框
					    	// obj.del();
                            Common.tableReload(currentCount,currentPageIndex,1,"admin_list");
					    },
					    error : function(result) {

					    }
				    });
         	 })

        }else if(layEvent === 'randUser'){// 重置密码

            layui.layer.open({
                title:"重置管理员 "+data.phone+" 的密码",
                type: 1,
                btn:["确定","取消"],
                area: ['310px'],
                content: '<div id="changePassword" class="layui-form" style="margin:20px 40px 10px 40px;;">'
                         +   '<div class="layui-form-item">'
                         +      '<div class="layui-input-block" style="margin: 0 auto;">'
                         +        '<input type="password" required  lay-verify="required" placeholder="新的管理员密码" autocomplete="off" class="layui-input admin_passwd">'
                         +      '</div>'
                         +    '</div>'
                         +   '<div class="layui-form-item">'
                         +      '<div class="layui-input-block" style="margin: 0 auto;">'
                         +        '<input type="password" required  lay-verify="required" placeholder="确认密码" autocomplete="off" class="layui-input admin_rePasswd">'
                         +      '</div>'
                         +    '</div>'
                         +'</div>'

                ,yes: function(index, layero){ //确定按钮的回调

                    var newPasswd = Common.getValueForElement("#changePassword .admin_passwd");
                    var reNewPasswd = Common.getValueForElement("#changePassword .admin_rePasswd");
                    if (newPasswd != reNewPasswd) {
                        layui.layer.msg("两次密码输入不一致", {"icon": 2});
                        return;
                    }
                    if (Common.isNil(newPasswd) || Common.isNil(reNewPasswd)) {
                        layui.layer.msg("请输入密码", {"icon": 2});
                        return;
                    }
                    data.password = $.md5(newPasswd);
                    updateRole(data.userId,data.password,function () {
                        layui.layer.close(index); //关闭弹框
                    });

                }


             });

        }else if(layEvent === 'locking'){// 锁定
        	// data.state = 0;
            console.log("禁用："+JSON.stringify(data))
            updateAdmin(localStorage.getItem("account"),data.userId,-1,"禁用管理员",data.role, function(){
                        //layui.layer.close(index); //关闭弹框
                   		table.reload("admin_list",{
  			                page: {
  			                    curr: 1 //重新从第 1 页开始
  			                }
			                })
			      });

		}else if(layEvent === 'cancelLocking'){// 解锁
            data.state = 1;
            updateAdmin(localStorage.getItem("account"),data.userId,1,"解禁管理员",data.role, function(){
                        //layui.layer.close(index); //关闭弹框
                   		table.reload("admin_list",{
			                page: {
			                    curr: 1 //重新从第 1 页开始
			                }
			            })
			      });
        }

     });

    function updateRole(userId,newPassword,callback){
        console.log("userId"+userId+"---"+"password"+newPassword);
        Common.invoke({
            url : request('/console/updateUserPassword'),
            data : {
                "userId" : userId,
                "password": newPassword
            },
            successMsg : "重置密码成功",
            errorMsg :  "重置密码失败，请稍后重试",
            success : function(result) {
                // layui.layer.close(index); //关闭弹框
                callback();
            },
            error : function(result) {

            }
        });
    }

    //更新管理员数据通用方法
    function updateAdmin(adminId,userId,status,infoStr,role,callback) {

	    Common.invoke({
		      url : request('/console/modifyAdmin'),
		      data : {
                    "adminId":adminId,
                    "userId": userId,
                    "status": status,
                    "role": role
          },
		      successMsg : infoStr+"成功",
		      errorMsg :  infoStr+"失败，请稍后重试",
		      success : function(result) {
            callback();
		      },
		      error : function(result) {

		      }
	    });

    }

    //搜索
    $(".search_admin").on("click",function(){
        if($(".admin_keyword").val().indexOf("*")!=-1){
            layer.alert("不支持*号搜索")
            return
        }
        // 关闭超出宽度的弹窗
        $(".layui-layer-content").remove();
        table.reload("admin_list",{
            url:request("/console/adminList")+"&adminId="+localStorage.getItem("adminId")+"&type="+"0"+"&userId="+localStorage.getItem("account"),
            page: {
                curr: 1 //重新从第 1 页开始
            },
            where: {
                keyWorld : Common.getValueForElement(".admin_keyword")   //搜索的关键字
            }
        })
        $(".admin_keyword").val("");
    });


    //add admin
    $(".btn_addAdmin").on("click",function(){
    		$(".admin_accunt").val("");

    		$(".admin_role").val("");
			layui.layer.open({
            title:"",
            type: 1,
            btn:["创建","取消"],
            area: ['400px', '300px'],
            content: $("#add_admin"),
            success : function(layero,index){  //弹窗打开成功后的回调

          		 layui.form.render('select');
          	},
            yes: function(index, layero){

      					var account = Common.getValueForElement("#add_admin_form .admin_accunt");
      					var role = $("#add_admin_form .admin_role").val();
      					if(null == role){
      					    layer.alert("请选择角色");
                            return;
                        }
      					Common.invoke({
    					      url : request('/console/addAdmin'),
    					      data : {
                                telePhone:account,
                                // adminTelePhone:localStorage.getItem("adminId"),
    					      	// password:$.md5(passwd),
    					      	role:role,
                                type:0
    					      },
    					      successMsg : "创建管理员成功",
    					      errorMsg :  "创建管理员失败，请稍后重试",
    					      success : function(result) {

    					      	$("#add_admin").hide();
    					        layui.layer.close(index); //关闭弹框

    					      	table.reload("admin_list",{
  					                page: {
  					                    curr: 1 //重新从第 1 页开始
  					                }
    					        })

    					      },
    					      error : function(result) {

    					      }
    				    });

  					},
  					btn2: function(index, layero){
  						$("#add_admin").hide();
  					},
  					cancel: function(){ 
  						$("#add_admin").hide();
  					}


        });

    });


})



    
 



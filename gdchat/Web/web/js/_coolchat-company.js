
var companysData = {};  //用于存放该用户所有的公司数据 key ：companyId   value ：company

var rootDepartIds = {};  //用于存放根部门id 数据  key：companyId  value ：rootdepartId

var employeeRole = {};  //用于存该用户在某个公司中的员工角色值  key：companyId   value：role(员工角色值)

var companyEmployees = {};  //用于存放公司的员工的userId   key ：companyId  value ：全部员工的userId

var CompanyManager = { 
		filters : {},
		findCompany : function() {
			$("#orgShow").hide();
			$("#o").show();
			$("#companyTab").show();
			$("#roomTab").hide();
			$("#liveRoomTab").hide();
			$("#tab").hide();
			$("#prop").hide();
			$("#setPassword").hide();
			$("#tabCon_new").hide();
			$("#tabCon_1").hide();
			$("#tabCon_2").hide();
			$("#tab").hide();
			myFn.invoke({
				url : '/org/company/getByUserId',
				data : {
					userId : myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						var html = "";
						if(myFn.isNil(result.data)){
							//ownAlert("你当前没有 公司")
							return;
						}
						var length = result.data.length;
						$("#orgShow").empty();

						for (var i = 0; i < length; i++) {
							var obj = result.data[i];

							//将公司的数据储存到map,key为公司id,value 为公司数据
							var key = obj.id;
							companysData[key] = obj;
							CompanyManager.findEmpRole(obj); //调用方法获取并储存员工角色值
						}
						//html += GroupManager.createPager(pageIndex, length, 'GroupManager.showMyRoom');
						$("#orgShow").show();
						$("#privacy").hide();

						
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"获取公司信息失败！");
				}
			})
		},
		showDepartment : function(companyId) {
			if ($("."+companyId+"").css('display') == 'none') { //判断是否处于隐藏状态
				$("."+companyId+"").show();
				$("#img_"+companyId+"").addClass("upside-down");
			}
			else{
				$("."+companyId+"").hide();
				$("#img_"+companyId+"").removeClass("upside-down");
			}
		},
		showCompanyMenu :function(companyId){ //展开/关闭公司菜单
			if ($("#companyMenu_"+companyId+"").css('display') == 'none') { //判断是否处于隐藏状态
				$("#companyMenu_"+companyId+"").show();
			}else{
				$("#companyMenu_"+companyId+"").hide();
			}
		},
		showDepartMenu : function(departmentId){ //展开/关闭部门菜单
			if ($("#departMenu_"+departmentId+"").css('display') == 'none') { //判断是否处于隐藏状态
				$("#departMenu_"+departmentId+"").show();
			}else{
				$("#departMenu_"+departmentId+"").hide();
			}
		},
		findEmpRole : function(obj){ //查找用户在某个公司的角色值
			myFn.invoke({
				url : '/org/employee/role',
				data : {
					companyId : obj.id,
					userId : myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						employeeRole[obj.id] = result.data; //将员工角色值暂时储存
						var htmlItem = CompanyManager.createCompanyItem(obj); //生成公司的html
						$("#orgShow").append(htmlItem);
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"获取员工角色失败！");
				}
			})
		},
		createCompanyItem :function(obj){   
			var departments = obj.departments;
			var departHtml = CompanyManager.createDepartmentItem(departments);
			var itemHtml = "<div id='company_"+obj.id+"'>"
							   +"<div class='company' style=''>"

	                           +   "<div  style='width:30px;float:left'>"
	                           +         "<a href='#' style='cursor: pointer; margin-right: 10px;' class='pull-left'>"
	                           +         	"<img id='img_"+obj.id+"' src='img/unfold.png' class='compUnfold upside-down' onclick='CompanyManager.showDepartment(\"" + obj.id + "\");'>"
	                           +         "</a>"
	                           +   "</div>"

	                           +   "<div style='width:220px;float:left'>"
	                           +	   "<h6 id='companyName' class='media-heading' style='font-weight:bold; font-size:13px;'>" +(obj.companyName.length>15?obj.companyName.substring(0,15)+"...":obj.companyName)+ "</h6> "
							   +  	      "<div class='media-desc'>"
							   +		  	 "<span style='font-size:12px;color:#252525'>公司公告 : </span>"
							   +  		     "<a href='#' id='companyNotice' onclick='CompanyManager.showNotice(\"" + obj.noticeContent + "\",\""+obj.companyName+ "\")'>"
							   +  		 	    (myFn.isNil(obj.noticeContent) ? "暂无公告" : (obj.noticeContent.length>12?obj.noticeContent.substring(0,12)+"...":obj.noticeContent))
							   +  	 	     "</a>"
							   +    	   "</div>"
	                           +  "</div>"
	                           +  "<div style='width:30px;float:left'>"
	                           +          "<img  src='img/menuBar_big.png' class='companyMenuBar' onclick='CompanyManager.showCompanyMenu(\"" + obj.id + "\");' style='margin-right:12px;cursor:pointer;'>"
	                           +  "</div>"


	                           +  "<ul id='companyMenu_"+obj.id+"' class='companyMenu'  onmouseout='CompanyManager.hideCompanyMenu(\"" + obj.id + "\",event);'>";
	                           
	                           if (employeeRole[obj.id]>=2)  //权限判断
							   	    itemHtml += "<li  onclick='CompanyManager.showCreateDepartment(\"" + obj.id + "\")'>创建部门</li>"
							   				 +  "<li  onclick='CompanyManager.modifyCompanyInfo(\"" + obj.id + "\")'>修改信息</li>"
							   				 +  "<li  onclick='CompanyManager.setAdministrator(\"" + obj.id + "\")'>设置管理员</li>";


							   itemHtml += "<li style='' href='#' onclick='CompanyManager.modifyMyPosition(\"" + obj.id + "\")'>我的职位</li>"
							   if(obj.createUserId==myData.userId){
							   		itemHtml += "<li href='#' onclick='CompanyManager.quitCompany(\"" + obj.id + "\")'>解散公司</li>";
							   }else {
							   		itemHtml += "<li href='#' onclick='CompanyManager.quitCompany(\"" + obj.id + "\")'>退出公司</li>";
							   }
							   itemHtml+="</ul>"

	                           +"</div>"


							   +"<div id='departList_"+obj.id+"' class='department "+obj.id+"'  style='display:block;'>"
							   +  departHtml
							   +"</div> "

					        +"</div>";

			return itemHtml;
		},
		createDepartmentItem : function(departments){  //这里只查找根部门下面的一级部门
			var departmentHtml = "";
			var length = departments.length;
			//首先获取根部门ID
			var rootDepartId = null;
			for (var i = 0; i < length; i++) {
				var department = departments[i];
				if (department.type == 1) {   //type = 1 即根部门
					rootDepartId = department.id;
					//将根部门的Id储存到map,key为公司id,value 为根部门ID
					rootDepartIds[department.companyId] = rootDepartId; 
					break;
				}
			}

			for (var i = 0; i < length; i++) {
				var department = departments[i]; 

				if (department.type == 1) { //如果为根部门，则结束当前循环
					continue;
				}
				if (department.parentId == rootDepartId) {
					//获取员工数据
					var employHtml = CompanyManager.createEmployeeItem(department.employees); 
					var departHtml = "<div id='department_"+department.id+"' style='position: relative;'> "
							        + 	"<div class='' style='padding: 8px; border-bottom: 1px solid #f1f1f1; background: #fff'>"                                 
							        +   	"<img id='departImg_"+department.id+"' class='departmentImg' style='cursor:pointer;'  src='img/unfold.png' onclick='CompanyManager.createChildDepartItem(\"" + department.companyId+ "\",\"" + department.id + "\");'> " 
							        +          department.departName 
							        + 	    "<img class='departMenuBar' style='cursor:pointer;' src='img/menuBar.png' onclick='CompanyManager.showDepartMenu(\"" + department.id + "\");'>" 
							        +   "</div>"
							        + 	CompanyManager.createDepartMenusHtml(department)
							        + 	"<div id='childDepartList_"+department.id+"' class='childDepartList'> </div>"
							        + 	"<div id='employeeList_"+department.id+"' style='display: none;'>"+employHtml+"</div>"
						        	+"</div> ";		
					departmentHtml += departHtml;
				}

			}
		    return departmentHtml; 
		},
		//创建部门菜单html
		createDepartMenusHtml : function(department){
			var departMenuHtml = "<ul id='departMenu_"+department.id+"' class='departMenu'  onmouseout='CompanyManager.hideDepartmentMenu(\"" + department.id + "\",event);'>";

		    if (employeeRole[department.companyId]>=1) //权限判断
				departMenuHtml += "<li onclick='CompanyManager.showCreateChildDepartment(\"" +department.companyId+ "\",\"" + department.id + "\")'>创建子部门</li>"
						   	   +  "<li onclick='CompanyManager.delEmployee(\"" +department.companyId+ "\",\"" + department.id + "\")'>删除员工</li>"
						       +  "<li onclick='CompanyManager.quitDepartment(\""+department.id+"\",\""+department.companyId+"\")'>删除部门</li>";

			departMenuHtml += "<li onclick='CompanyManager.addEmployee(\"" + department.id + "\",\"" + department.companyId + "\")'>添加员工</a>"
						   + "</ul>";

		    return departMenuHtml;
		},
		createEmployeeItem : function(employees){ 
			var employeesHtml = "";
			if (myFn.isNil(employees)) {
				return employeesHtml;
			}
			for (var i = 0; i < employees.length; i++) {
			  	var employee = employees[i];
			  	if(myFn.isNil(employee.nickname)) //获取不到昵称说明对应的用户不存在,则不加载该用户的数据
			  		continue;
			  	var imgUrl = myFn.getAvatarUrl(employee.userId);
			  	var empHtml = "<div id='emp_"+employee.userId+"' class='media-main' onclick='CompanyManager.isChoose(\""+employee.userId+"\",\""+employee.departmentId+"\")'>"
			  	 				+	"<a href='javascript:UI.showUser(" +employee.userId+ ")' class='pull-left media-avatar'>"
			  	 				+      "<img onerror='this.src=\"img/ic_avatar.png\"' src='"+imgUrl+ "' class='media-object' style='border-radius:100%;width:40px;height:40px;'>"
			  	 				+	"</a>" 
			  	 				+   "<div onclick='ConversationManager.open(\"" + employee.userId + "\",\"" + employee.nickname+ "\");' style='cursor: pointer;' class='media-body'>"
			  	 				+   	"<h5 class='media-heading empName'>" + employee.nickname + "</h5>"
			  	 				+   	"<div id='position' class='media-desc'>"  +(myFn.isNil(employee.position) ? "员工" : employee.position)+  "</div>"
			  	 				+   "</div>" 
			  	 			   +"</div>";

			  	 			   "<img onerror='this.src=\"img/ic_avatar.png\"' src='"+myFn.getAvatarUrl(myData.userId)+"' style='border-radius:100%;width:60px;height:60px;margin-top:20px'>"
			  	employeesHtml += empHtml;	   
			}  
			return employeesHtml; 

		},
		createCompany : function(){   //创建公司
			var companyName = $("#newCompanyName").val();
			if (myFn.isNil(companyName)) {
				ownAlert(3,"请输入公司名称");
				return;
			}
			//companyName=companyName.trim();
			if(!/^[\u4e00-\u9fa5_a-zA-Z0-9]+$/.test(companyName)){
				ownAlert(3,"公司名称只能由中文、字母、数字组成，不能包含特殊符号和空格")
				return;
			}

			$("#btnCreateCompany").hide();
			$("#loading_comp").show();

			myFn.invoke({
				url : '/org/company/create',
				data : {
					companyName : companyName,
					createUserId : myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						var obj = result.data;
						companysData[obj.id] = obj; //存储公司数据
						employeeRole[obj.id] = 3; //存储用户在该公司的角色值 3：创建者
						var newDepartmentHtml =  CompanyManager.createCompanyItem(obj); 
						//alert("公司创建成功");
						$("#newCompanyModal").modal('hide');
						$("#btnCreateCompany").show();
						$("#loading_comp").hide();
						//html += GroupManager.createPager(pageIndex, length, 'GroupManager.showMyRoom');
						$("#orgShow").append(newDepartmentHtml);
						$("#orgShow").show();
						employeeRole[obj.id] = 3; //将员工角色值暂时储存
						// 将输入框清空
						$("#newCompanyName").val("");	
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"创建公司失败,请重试");
				}
				
			})
			$("#newCompanyModal").modal('hide');
			$("#btnCreateCompany").show();
			$("#loading_comp").hide();

		},
		quitCompany : function(companyId){  //退出公司
			//判断用户在公司的角色是否为创建者
			var role = employeeRole[companyId];
			if (role == 3) {

				ownAlert(4,"您是该公司的创建者，此操作会将公司删除,是否继续？",function(){

					myFn.invoke({
							url : '/org/company/quit',    
							data : {
								companyId : companyId,
								userId : myData.userId
							},
							success : function(result) {
								if (1 == result.resultCode) {
									$("#company_"+companyId+"").remove()	
								} else {
									ownAlert(2,result.resultMsg);
								}
							},
							error : function(result) {
								ownAlert(2,"退出公司失败,请重试");
							}
					})

				});

				return;
			}
			myFn.invoke({
				url : '/org/company/quit',    
				data : {
					companyId : companyId,
					userId : myData.userId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						$("#company_"+companyId+"").remove()	
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"退出公司失败,请重试");
				}
			})

		}, 
		showCreateDepartment :function(companyId){
			$("#newDepartmentModal #footer").empty();
			createDepartmentHtml = "<button type='button' class='btn btn-primary' id='btnCreateDepartment' onclick='CompanyManager.createDepartment(\"" +companyId + "\")'>确认创建</button>"
									+ "<div id='loading_depart' style='display: none;'>"
									+ "<img src='img/loading.gif'/>&nbsp;创建中..."
									+ "</div>";
			$("#newDepartmentModal #footer").append(createDepartmentHtml);
			//显示创建部门窗口
			$("#newDepartmentModal").modal('show');
		},
		showCreateChildDepartment : function(companyId,departmentId){
			$("#newDepartmentModal #modalName").text("创建子部门");
			$("#newDepartmentModal #footer").empty();
			createChildDepartmentHtml = "<button type='button' class='btn btn-primary' id='btnCreateDepartment' onclick='CompanyManager.createChildDepartment(\"" +companyId + "\",\"" +departmentId + "\")'>确认创建</button>"
									+ "<div id='loading_depart' style='display: none;'>"
									+ "<img src='img/loading.gif'/>&nbsp;创建中..."
									+ "</div>";
			$("#newDepartmentModal #footer").append(createChildDepartmentHtml);
			//显示创建部门窗口
			$("#departmentName").val("");
			$("#newDepartmentModal").modal('show');
		},
		createDepartment : function(companyId){  //创建部门
			
			var departmentName = $("#departmentName").val();
			if (myFn.isNil(departmentName)) {
				ownAlert(3,"请输入部门名称");
			}
			$("#btnCreateDepartment").hide();
			$("#loading_depart").show();

			myFn.invoke({
				url : '/org/department/create',    
				data : {
					departName : departmentName,
					createUserId : myData.userId,
					companyId : companyId,
					parentId : rootDepartIds[companyId]
				},
				success : function(result) {
					if (1 == result.resultCode) {
						$("#newDepartmentModal").modal('hide');
						$("#btnCreateDepartment").show();
						$("#loading_depart").hide();
						//html += GroupManager.createPager(pageIndex, length, 'GroupManager.showMyRoom');
						var department = result.data;
						var departHtml = "<div id='department_"+department.id+"'> "
							        + 	"<div class='' style='padding: 8px; border-bottom: 1px solid #f1f1f1; background: #fff'>"   // class='media-heading'                                
							        +   	"<img id='departImg_"+department.id+"' class='departmentImg'  src='img/unfold.png' onclick='CompanyManager.createChildDepartItem(\"" + department.companyId+ "\",\"" + department.id + "\");'> " 
							        +          department.departName 
							        + 	    "<img class='departMenuBar' src='img/menuBar.png' onclick='CompanyManager.showDepartMenu(\"" + department.id + "\");'>" 
							        +   "</div>"  
							        + 	CompanyManager.createDepartMenusHtml(department)
							        + 	"<div id='childDepartList_"+department.id+"' class='childDepartList'> </div>"
							        + 	"<div id='employeeList_"+department.id+"' style='display: none;'></div>"
						        	+"</div> ";		 

						$("#departList_"+companyId+"").append(departHtml);

					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"创建部门失败,请重试");
				}
			});
			$("#newDepartmentModal").modal('hide');
		},
		createChildDepartment : function(companyId,departmentId){  //创建子部门
			var departmentName = $("#departmentName").val();
			if (myFn.isNil(departmentName)) {
				ownAlert(3,"请输入子部门名称")
			}
			$("#btnCreateDepartment").hide();
			$("#loading_depart").show();

            $("#departImg_"+departmentId+"").removeClass('upside-down');
            $("#childDepartList_"+departmentId+"").hide();
            $("#employeeList_"+departmentId+"").hide();

			myFn.invoke({
				url : '/org/department/create',    
				data : {
					departName : departmentName,
					createUserId : myData.userId,
					companyId : companyId,
					parentId : departmentId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						$("#newDepartmentModal").modal('hide');
						$("#btnCreateDepartment").show();
						$("#loading_depart").hide();
						//html += GroupManager.createPager(pageIndex, length, 'GroupManager.showMyRoom');
						var department = result.data;
						var childDepartHtml = "<div id='department_"+department.id+"'> "
							        + 	"<div class='' style='padding: 8px; border-bottom: 1px solid #f1f1f1; background: #fff'>"   // class='media-heading'                                
							        +   	"<img id='departImg_"+department.id+"' class='departmentImg'  src='img/unfold.png' onclick='CompanyManager.createChildDepartItem(\"" + department.companyId+ "\",\"" + department.id + "\");'> " 
							        +          department.departName 
							        + 	    "<img class='departMenuBar' src='img/menuBar.png' onclick='CompanyManager.showDepartMenu(\"" + department.id + "\");'>" 
							        +   "</div>"  
							        + 	CompanyManager.createDepartMenusHtml(department)
							        + 	"<div id='childDepartList_"+department.id+"' class='childDepartList'> </div>"
							        + 	"<div id='employeeList_"+department.id+"' style='display: none;'></div>"
						        	+"</div>";				

						$("#childDepartList_"+departmentId+"").append(childDepartHtml);
						//更新数据
						var employees = [];
						department.employees = employees;
						companysData[companyId].departments.push(department);
							
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"创建部门失败,请重试");
				}
			})

		},
		modifyMyPosition : function(companyId){ //修改我的职位
			$("#modify_myPosition").modal('show');
            $("#poErrorInfo").text("");
            $("#positionModify").unbind('click');
            $("#positionModify").click(function() {  //点击修改
				var newPositionName = $("#positionName").val(); //获取职位
				//首先判断职位是否为空
				if (myFn.isNil(newPositionName)) {
					$("#poErrorInfo").text("请输入职位名");
					return;
				}
				$("#positionModify").hide();
				$("#loading_modifyPosition").show();
				var userId = myData.userId;
				myFn.invoke({
					url : '/org/employee/modifyPosition',
					data : {
						userId : userId,
						companyId : companyId,
						position : newPositionName
					},
					success : function(result) {
						if (1 == result.resultCode) {
							$("#modify_myPosition").modal('hide');
							//在界面上修改职位信息

							$("#emp_"+userId+" #position").text(newPositionName);
							ownAlert(2,"修改成功");
						} else {
							ownAlert(2,result.resultMsg);
						}
					},
					error : function(result) {
						ownAlert(2,"修改职位信息失败,请重试");
					}
    })

    $("#positionModify").show();
    $("#loading_modifyPosition").hide();

});
    	},
		modifyCompanyInfo : function(companyId){     //修改公司信息包括公司名和公告
			$("#modify_companyInfo").modal('show');
			//显示现有的公司名称和公告
			var companyName = companysData[companyId].companyName;
			var noticeContent = companysData[companyId].noticeContent;
			$("#modify_companyInfo  #companyName").val(companyName);
			$("#modify_companyInfo  #companyNotice").val(noticeContent);

			$("#modify_companyInfo  #companyName").blur(function(){   //失去焦点事件
				if ($("#modify_companyInfo  #companyName").val() =="") {
					$("#errorInfo").text("* 公司名称不能为空");
				}
			});
            $("#confirmModify").unbind('click');//先解除绑定
			$("#confirmModify").click(function() {
				//首先判断是否存在错误信息
				if ($("#errorInfo").text()!="" && $("#errorInfo").text()!=null) {
					return;
				}
				var newCompanyName = $("#modify_companyInfo  #companyName").val();
				var newNoticeContent = $("#modify_companyInfo  #companyNotice").val();
				if (newCompanyName==companyName && newNoticeContent==noticeContent) {
					
					//隐藏弹框
					$("#modify_companyInfo").modal('hide');
					return;
				}

				$("#confirmModify").hide();
				$("#loading_modify").show();
				if(newCompanyName==companyName && newNoticeContent!=noticeContent){
					myFn.invoke({
						url : '/org/company/modify',    
						data : {
							companyId : companyId,
							noticeContent : newNoticeContent,
						},
						success : function(result) {
							if (1 == result.resultCode) {
								var company = result.data;
								$("#modify_companyInfo").modal('hide');
								//在界面上修改公司列表中的信息
								$("#company_"+companyId+" #companyName").text((company.companyName.length>15?company.companyName.substring(0,15):company.companyName));
								$("#company_"+companyId+" #companyNotice").text((myFn.isNil(newNoticeContent)?"暂无公告":(newNoticeContent.length>12?newNoticeContent.substring(0,12)+"...":newNoticeContent)));
                                // 点击展示面板更新
                                CompanyManager.findCompany();
                                ownAlert(2,"修改成功");
							} else {
								ownAlert(2,result.resultMsg);
							}
						},
						error : function(result) {
							ownAlert(2,"修改公司信息失败,请重试");
						}
					})
				}else{
					myFn.invoke({
						url : '/org/company/modify',    
						data : {
							companyId : companyId,
							companyName : newCompanyName,
							noticeContent : newNoticeContent
						},
						success : function(result) {
							if (1 == result.resultCode) {
								var company = result.data;
								$("#modify_companyInfo").modal('hide');
								//在界面上修改公司列表中的信息
								$("#company_"+companyId+" #companyName").text((company.companyName.length>15?company.companyName.substring(0,15):company.companyName));
								$("#company_"+companyId+" #companyNotice").text((myFn.isNil(newNoticeContent)?"暂无公告":(newNoticeContent.length>12?newNoticeContent.substring(0,12)+"...":newNoticeContent)));
                                // 点击展示面板更新
                                CompanyManager.findCompany();
                                ownAlert(2,"修改成功");
							} else {
								ownAlert(2,result.resultMsg);
							}
						},
						error : function(result) {
							ownAlert(2,"修改公司信息失败,请重试");
						}
					})
				}
				
				$("#confirmModify").show();
				$("#loading_modify").hide();
				//更新js model中的数据
		  		companysData[companyId].companyName = newCompanyName;
		  		companysData[companyId].noticeContent = newNoticeContent;

			});

		},
		hideCompanyMenu : function(companyId,e){ //隐藏公司菜单
			var id = "companyMenu_"+companyId+"";
			e = e || window.event;
            var o = e.relatedTarget||e.toElement;
            while(o.parentNode&&o.id!=id){
            	o=o.parentNode;
            }
            if(o.id!=id) {
            	$("#companyMenu_"+companyId+"").hide();
                // alert("移出了层");
            }
			
		},
		hideDepartmentMenu : function(departmentId,e){ //隐藏部门菜单
			var id = "departMenu_"+departmentId+"";
			e = e || window.event;
            var o = e.relatedTarget||e.toElement;
            while(o.parentNode&&o.id!=id){
            	o=o.parentNode;
            }
            if(o.id!=id) {
            	$("#departMenu_"+departmentId+"").hide();
                // alert("移出了层");
            }
			
		},
		createChildDepartItem : function(companyId,departmentId){  //创建子部门Item

			//通过公司id 到map中取出对应的部门数据
			var departments = companysData[companyId].departments;

			var childDepartmentHtml = "";
			var length = departments.length;
			for (var i = 0; i < length; i++) {
				var department = departments[i];
				if (department.type == 1) {   //type = 1 即根部门
					continue;
				}

				if (department.parentId == departmentId) {  //判断是否存在子部门
					//获取员工数据
					var employHtml = CompanyManager.createEmployeeItem(department.employees);
					var childDepartHtml =  "<div id='department_"+department.id+"'> "
							        + 	"<div class='' style='padding: 8px; border-bottom: 1px solid #f1f1f1; background: #fff'>"                                 
							        +   	"<img id='departImg_"+department.id+"' class='departmentImg'  src='img/unfold.png' onclick='CompanyManager.createChildDepartItem(\"" + department.companyId+ "\",\"" + department.id + "\");'> " 
							        +          department.departName 
							        + 	    "<img class='departMenuBar' src='img/menuBar.png' onclick='CompanyManager.showDepartMenu(\"" + department.id + "\");'>" 
							        +   "</div>" 
							        + CompanyManager.createDepartMenusHtml(department)
							        + 	"<div id='childDepartList_"+department.id+"' class='childDepartList'> </div>"
							        + 	"<div id='employeeList_"+department.id+"' style='display: none;'>"+employHtml+"</div>"
						        	+"</div> ";		

				    childDepartmentHtml +=  childDepartHtml;

				}
			}
			$("#childDepartList_"+departmentId+"").empty();
			$("#childDepartList_"+departmentId+"").append(childDepartmentHtml);

			if ($("#childDepartList_"+departmentId+"").css('display') == 'none') { //判断子部门列表是否处于隐藏状态
				$("#departImg_"+departmentId+"").addClass('upside-down');
				$("#childDepartList_"+departmentId+"").show();
			}else{
				$("#departImg_"+departmentId+"").removeClass('upside-down');
				$("#childDepartList_"+departmentId+"").hide();
			}
			
			//判断员工列表是否处于隐藏状态
			if ($("#employeeList_"+departmentId+"").css('display') == 'none') {
				$("#employeeList_"+departmentId+"").show();
			}else{
				$("#employeeList_"+departmentId+"").hide();
			}
			
		    //return childDepartmentHtml;
		},
		showNotice :function(noticeContent,companyName){
			$("#showCompanyNotice").empty();
			var noticeHtml = "<div id='noticeModal' class='modal fade' tabindex='-1' role='dialog' aria-labelledby='myModalLabel' aria-hidden='true'>"
							+	"<div class='modal-dialog' style='width: 100%;max-width:600px;margin-top:60px'>"
							+		"<div class='modal-content'>"
							+			"<div class='modal-header'>"
							+				"<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>"
							+				"<h4 class='modal-title' id='myModalLabel'>"+companyName+"公告</h4>"
							+			"</div>"
							+			"<div class='modal-body' id='myModalLabelContent'>"
							+				(myFn.isNil(noticeContent) ? "暂无公告" : noticeContent)
							+			"</div>"
							+		"</div>"
							+ 	"</div>"
							+ "</div>"

			$("#showCompanyNotice").append(noticeHtml);
			$("#noticeModal").modal('show');

		},
		delEmployee : function(companyId,departmentId){ //删除员工

			$("#addEmployee #areadyChooseFriends").empty();  //清空已选好友列表
			Checkbox.cheackedFriends = {};  //清空储存的数据

			$("#empModalLabel").text("删除员工");
			var delHtml = '<button type="button" class="btn sou" id="btnDelEmploy" style="color: white;">确定删除</button>'
						+'<div id="loading_delEmp" style="display: none;"><img src="img/loading.gif" />&nbsp;删除中...</div>';
			$("#addEmployeeFooter").empty();
			$("#addEmployeeFooter").html(delHtml);

			$("#addEmployee").modal('show'); //重用添加员工面板

			//获取部门员工
			var departEmpHtml = "";
			myFn.invoke({
				url : '/org/departmemt/empList',
				data : {
					departmentId : departmentId
				},
				success : function(result) {
					console.log("删除员工："+JSON.stringify(result.data))
					if (1 == result.resultCode) {
						for (var i = 0; i < result.data.length; i++) {
							if(result.data[i].userId==myData.userId){
								continue;
							}
							var employee = result.data[i];
							var imgUrl = myFn.getAvatarUrl(employee.userId);
							departEmpHtml += "<tr><td>"
							              +		"<img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl + "' width=30 height=30  class='roundAvatar'/>"
							              +  "</td><td width=100%><p style='text-overflow:ellipsis;white-space:nowrap;overflow: hidden;'>&nbsp;&nbsp;&nbsp;&nbsp;" + employee.nickname+"</p>"
							              +  "</td><td>"
							              +	 (3 == employee.role?"":"<input id='areadyChooseFriends' name='userId' type='checkbox'  value='" + employee.userId + "' onclick='Checkbox.checkedAndCancel(this)'/></td></tr>");
						}
						//var pageHtml = CompanyManager.createPager(pageIndex, result.pageData.length, uIds, 'CompanyManager.showFriendList');
						$("#cpFriendsList").empty();
						$("#employees_page").empty();
						$("#cpFriendsList").append(departEmpHtml);
						

					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"获取员工数据失败，请稍后再试");
				}
			});


			$("#addEmployee #btnDelEmploy").click(function() { //点击确定删除按钮后
				CompanyManager.removeEmoloyee(companyId,departmentId);
			});

		},
		setAdministrator : function (companyId) {


			$("#setAdmin #setAdminShowArea").empty();  //清空已选好友列表
			Checkbox.cheackedFriends = {};  //清空储存的数据

			//获取公司的所有员工的
			var compEmps = [];
			myFn.invoke({      //获取某个公司的员工列表 
				url : '/org/company/employees',    
				data : {
					companyId : companyId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						for (var i = 0; i < result.data.length; i++) {
							compEmps[i] = (result.data[i]);
						}
						CompanyManager.excludeAdmin(companyId,compEmps); //排除已成为管理员的员工

					} else {
						ownAlert(2,result.resultMsg);
					}
					
				},
				error : function(result) {
					ownAlert(2,"获取员工数据失败,请重试");
				}
			});

		},
		excludeAdmin : function(companyId,compEmps){ //将公司员工中已是管理员的员工排除
			var cEmps = compEmps;
			//排除已经设为管理员的员工
			for (var i = 0; i < cEmps.length; i++) {
				if (cEmps[i].role >= 2) {
						cEmps.splice(i,1); 
					}
			}
			//向页面加载数据
			//公司成员列表，(排除了已经设为管理员的员工)
			var comEmpHtml = "";
			for (var k = 0; k < cEmps.length; k++) {
				var e = cEmps[k];
				var imgUrl = myFn.getAvatarUrl(e.userId);
				comEmpHtml += "<tr><td>"
			              +		"<img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl + "' width=30 height=30  class='roundAvatar'/>"
			              +  "</td><td width=100%>&nbsp;&nbsp;&nbsp;&nbsp;" + e.nickname
			              +  "</td><td>"
			              +	 "<input id='setAdminShowArea' name='userId' type='checkbox'  value='" + e.userId + "'  onclick='Checkbox.checkedAndCancel(this)'/></td></tr>";
			}
			$("#setAdmin #setAdminFriendList").empty();
			$("#setAdmin").modal('show');
			$("#setAdmin #setAdminFriendList").append(comEmpHtml);
			
			$("#setAdmin #btnSetAdmin").click(function() {  //点击确定按钮后
				if (Checkbox.parseData().length <=0 ) {
					ownAlert(3,"请选择要指定的员工");
					return;
				}
				var userIds = JSON.stringify(Checkbox.parseData());
				myFn.invoke({
					url : '/org/company/setManager',
					data : {
						companyId : companyId,
						managerId : userIds
					},
					success : function(result) {
						if (1 == result.resultCode) {
							$("#setAdmin").modal('hide');
							ownAlert(1,"添加管理员成功");
							
						} else {
							ownAlert(2,result.resultMsg);
						}
					},
					error : function(result) {
						ownAlert(2,"设置管理员失败，请稍后再试");
					}
				});
				$("#setAdmin").modal('hide');
				$("#setAdmin #setAdminFriendList").empty();
			});
					
				
		},
		addEmployee : function(departmentId,companyId){
			$("#empModalLabel").text("添加员工");
			var addHtml = '<button type="button" class="btn sou" id="btnAddEmploy" style="color: white;">确定添加</button>'
						+'<div id="loading_1" style="display: none;"><img src="img/loading.gif" />&nbsp;添加中...</div>';
			$("#addEmployeeFooter").empty();
			$("#addEmployeeFooter").html(addHtml);

			$("#addEmployee #areadyChooseFriends").empty();  //清空已选好友列表
			Checkbox.cheackedFriends = {};  //清空储存的数据

			//获取公司的员工的userId
			var userIds = [];
			myFn.invoke({      //获取某个公司的员工列表 
				url : '/org/company/employees',    
				data : {
					companyId : companyId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						for (var i = 0; i < result.data.length; i++) {
							var employee = result.data[i];
							//userIds.push(employee.userId);
							userIds[i] = (employee.userId);
						}
						companyEmployees[companyId] = userIds; //存储公司员工的userId
						CompanyManager.showFriendList(0,companyId);//展示第一页的好友
						$("#addEmployee").modal('show');  //打开弹框
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"获取员工数据失败,请重试");
				}
			})

			$("#btnAddEmploy").click(function() {
				CompanyManager.joinEmploy(departmentId,companyId)
			});
		},
		joinEmploy : function(departmentId,companyId){
			if (Checkbox.parseData().length <=0 ) {
				ownAlert(3,"请选择要添加的员工");
				return;
			}
			var userIds = JSON.stringify(Checkbox.parseData());
			myFn.invoke({
				url : '/org/employee/add',
				data : {
					userId : userIds,
					companyId : companyId,
					departmentId : departmentId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						$("#addEmployee").modal('hide');
						ownAlert(1,"添加员工成功");
						//调用方法将子部门列表和员工列表展开
						if ($("#employeeList_"+departmentId+"").css('display') == 'none') { //若员工列表不是隐藏状态，说明已经调用
							CompanyManager.createChildDepartItem(companyId,departmentId);
						}
						
						var newEmployeeHtml = CompanyManager.createEmployeeItem(result.data);
						$("#employeeList_"+departmentId+"").empty();
						$("#employeeList_"+departmentId+"").append(newEmployeeHtml);

                        $("#departImg_"+departmentId+"").removeClass('upside-down');
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"添加员工失败，请稍后再试");
				}
			});
			$("#addEmployee").modal('hide');
			
		}, 
		removeEmoloyee : function(companyId,departmentId){

			if (Checkbox.parseData().length <=0 ) {
				ownAlert(3,"请选择要删除的员工");
				return;
			}
			var userIds = JSON.stringify(Checkbox.parseData());
			// if(employeeRole[departmentId]>=2){
			// 	ownAlert(2,"不能删除公司创建者");
			// 	return ;
			// }
			myFn.invoke({
				url : '/org/employee/delete',
				data : {
					userIds : userIds,
					departmentId : departmentId
				},
				success : function(result) {
					if (1 == result.resultCode) {
						$("#addEmployee").modal('hide');
						ownAlert(1,"删除员工成功。");
						//调用方法将子部门列表和员工列表展开
						if ($("#employeeList_"+departmentId+"").css('display') == 'none') { //若员工列表不是隐藏状态，说明已经调用
							CompanyManager.createChildDepartItem(companyId,departmentId);
						}
						//处理UI 将员工从列表移除
						for (var i = 0; i < Checkbox.parseData().length; i++) {
							var removeId = Checkbox.parseData()[i];
							$("#employeeList_"+departmentId+" #emp_"+removeId+"").remove();
						}
						
					} else {
						ownAlert(2,result.resultMsg);
					}
				},
				error : function(result) {
					ownAlert(2,"删除员工失败，请稍后再试");
				}
			});
			$("#addEmployee").modal('hide');

		},
		showFriendList : function(pageIndex,companyId){
			mySdk.getFriendsList(myData.userId, null, 2, pageIndex, function(result) {
				
				var cpFriendsListHtml="";
				var uIds = companyEmployees[companyId]; //根据companyId 取出公司员工userId
				for (var i = 0; i < result.pageData.length; i++) {  //循环好友列表
					var obj = result.pageData[i];
					var imgUrl = myFn.getAvatarUrl(obj.toUserId);

					if(obj.toUserId==Checkbox.cheackedFriends[obj.toUserId]){
					 	cpFriendsListHtml+="<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl + "' width=30 height=30 class='roundAvatar'/></td><td width=100% style='white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>&nbsp;&nbsp;&nbsp;&nbsp;" + obj.toNickname
							+ "</td><td><input id='areadyChooseFriends' name='userId' type='checkbox' checked='checked' value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/></td></tr>";
					 	continue; //进入下一次循环
					}

					var isExist = false;
					for (var j = 0; j < uIds.length; j++) {  //公司员工列表
						var userId = uIds[j];
						if (obj.toUserId == userId) {
							isExist = true;
							break;
						}
						
					}
					
					if (isExist) {  
						cpFriendsListHtml += "<tr><td>"+"<img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl + "' width=30 height=30  class='roundAvatar'/></td><td width=100% style='white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>&nbsp;&nbsp;&nbsp;&nbsp;" + obj.toNickname
							+ "</td><td><input id='userId' name='userId_exc' type='checkbox' disabled='false' checked ='checked'/></td></tr>";
					}else{
						cpFriendsListHtml += "<tr><td><img onerror='this.src=\"img/ic_avatar.png\"' src='" + imgUrl + "' width=30 height=30 class='roundAvatar'/></td><td width=100% style='white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>&nbsp;&nbsp;&nbsp;&nbsp;" + obj.toNickname
							+ "</td><td><input id='areadyChooseFriends' name='userId' type='checkbox'  value='" + obj.toUserId + "' onclick='Checkbox.checkedAndCancel(this)'/></td></tr>";
					}

					
					
				}
				var pageHtml = CompanyManager.createPager(pageIndex, result.pageCount, companyId, 'CompanyManager.showFriendList');
				$("#cpFriendsList").empty();
				$("#employees_page").empty();
				$("#cpFriendsList").append(cpFriendsListHtml);
				$("#employees_page").append(pageHtml);

			});
		},
		createPager : function(pageIndex, totalPage, parameter, fnName) {   //用于翻页
			var pagerHtml = "<div style='margin-top: 10px; margin-left: 0px; margin-right: 0px; text-align: center; font-size: 14px;'>";
			if (pageIndex == 0) {
				pagerHtml += "<img style='width:21px;' alt='' src='img/on1.png'>";
			} else {
				pagerHtml += "<a href='javascript:" + fnName + "(" + (pageIndex - 1) + ",\"" + parameter + "\")" + "'>"
						  + "<img  style='width:21px;'  src='img/on.png'>"
						  +  "</a>";
			}
			pagerHtml += "<div class='pageIndex'>" + (pageIndex + 1) + "</div>";
			if ((pageIndex+1) >= totalPage) {
				pagerHtml += "<img style='width:21px;'  src='img/next1.png'>";
			} else {
				pagerHtml += "<a href='javascript:" + fnName + "(" + (pageIndex + 1) + ",\"" + parameter + "\")" + "'><img style='width:21px;'  src='img/next.png'></a>";
			}
			return pagerHtml;
			
		},
		getEmployeeList : function() {  //获取要添加的员工的 userId
			var invitee = new Array();
			$('input[name="userId"]:checked').each(function() {
				invitee.push(parseInt($(this).val()));
			});
			//alert("测试选中员工数："+invitee.length)
			return invitee;
		},
		quitDepartment : function(departmentId,companyId) {
			if (CompanyManager.roleDiscern(companyId,0)) {


				ownAlert(4,"是否确认删除该部门?",function(){

						myFn.invoke({
							url : '/org/department/delete',
							data : {
								departmentId : departmentId
							},
							success : function(result) {
								if (1 == result.resultCode) {
									ownAlert(1,"部门删除成功。");
									$("#department_"+departmentId+"").remove();
								} else {
									ownAlert(2,result.message);
								}
							},
							error : function(result) {
								ownAlert(2,"部门删除失败，请稍后再试")
							}
						});

				});

			} else {
				ownAlert(3,"权限不足！");
				return;
			}
	},
    roleDiscern : function(companyId,roleValue){  //角色识别
    	var role = employeeRole[companyId];
    	var isOk = false;
    	if (role >= roleValue) { //用户的角色值大于给定角色值就表明有权限
    		isOk = true;
    	}
    	return isOk;
    },
    isChoose:function(userId,empId){
    	$("#employeeList_"+empId+" #emp_"+userId+"").siblings().removeClass("fActive");
    	$("#employeeList_"+empId+" #emp_"+userId+"").addClass("fActive");

    	$("#employeeList_"+empId+"").siblings().removeClass("fActive");
    	// $("#employeeList_"+empId+"").addClass("fActive");
    }

		
};

$(function () {
		
   $("#creatCompanyImg").tooltip({ //鼠标移动弹出提示
         trigger:'hover',
         html:true,
         title:'创建公司',
         placement:'bottom'
    })

});

$(document).ready( function() {
    //初始化滚动条
	$("#companyListShow").niceScroll({
		  cursorcolor: "#c7c4c4",
          cursorwidth: "8px", // 滚动条的宽度，单位：便素
          autohidemode: true, // 隐藏滚动条的方式
          railoffset: false,
          enablemousewheel: true, // nicescroll可以管理鼠标滚轮事件
          smoothscroll: true, // ease动画滚动  
          cursorminheight: 32, // 设置滚动条的最小高度 (像素)
          iframeautoresize: true //iframeautoresize: true
	});

   	// $("#companyListShow").getNiceScroll().resize();
  }
);




	
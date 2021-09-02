layui.use(['form','layer','laydate','table','laytpl'],function(){
    var form = layui.form,
        layer = layui.layer;
        //$ = layui.jquery;

       let loginConflict=Utils.getQueryString(location.search, 'loginConflict');
       console.log("loginConflict ===> ",loginConflict);
       if(loginConflict){
       		ownAlert(3,"你的账户在其他地方登陆,被挤下线！");
       		setTimeout(function(){
		 		window.location.href = "login.html";
		 	},3500);
       		
			
       }

	var telephone;
	var password;

	createQRCode();
	//$(function() {
		WEBIM.initConfig();
		
		telephone = $.cookie("telephone");
		password = $.cookie("password");
		
		if(!myFn.isNil(telephone))
			$("#telephone").val(telephone);
		if(!myFn.isNil(password))
			$("#password").val(password);



		//登录
		form.on('submit(user_login)', function(obj) {
	       	/*obj.field.areaCode = $("#telephone").intlTelInput("getSelectedCountryData").dialCode;
	       	obj.field.telephone = $.md5(obj.field.telephone);
	        obj.field.password = $.md5(obj.field.password);
	        console.log("登录密码："+obj.field.password);*/
	        layer.load(1);
	        // areaCode,account,salt
	       /* obj.field.areaCode = $("#telephone").intlTelInput("getSelectedCountryData").dialCode;
	        obj.field.account = obj.field.telephone;
	        obj.field.salt = getCurrentMilliSeconds();*/
            /*var param = {};
            param.areaCode = $("#telephone").intlTelInput("getSelectedCountryData").dialCode;
            param.account = obj.field.telephone;
            param.salt = getCurrentMilliSeconds();*/
	        // param.password = obj.field.password;
	        /*ApiAuthUtils.getLoginCode(obj.field.password,param,function (result) {
				console.log("login  log : "+JSON.stringify(result));
            })*/
	        obj.field.areaCode = 86;//$("#telephone").intlTelInput("getSelectedCountryData").dialCode;
	        obj.field.salt = getCurrentMilliSeconds();
	        // 获取随机code
			obj.field.account = obj.field.telephone;
			obj.field.apiKey = AppConfig.apiKey;
            AuthorityLogin.getLoginCode(obj.field,function (codeResult) {
            	shikuLog(" getLoginCode JSON codeResult : "+JSON.stringify(codeResult));
            	// 获取加密私钥
				let privateKey = {};
				privateKey.userId = codeResult.userId;
            	privateKey.salt = getCurrentMilliSeconds();
            	privateKey.apiKey = AppConfig.apiKey;
            	privateKey.pwd = obj.field.password;
            	privateKey.areaCode = obj.field.areaCode;
            	privateKey.account = obj.field.account;
				AuthorityLogin.getLoginPrivateKey(privateKey,function (privateKeyResult) {
					if(myFn.isNil(codeResult.code)){
                        AuthorityLogin.getLoginCode(obj.field,function (codeData) {
							codeResult.code = codeData.code;
						})
					}
					shikuLog(" getLoginPrivateKey JSON privateKeyResult : "+JSON.stringify(privateKeyResult));
					var userLogin = {};
					userLogin.salt = getCurrentMilliSeconds();
					userLogin.userId = privateKey.userId;
					userLogin.apiKey = AppConfig.apiKey;
					userLogin.pwd = obj.field.password;
					userLogin.code = codeResult.code;
					userLogin.privateKey = privateKeyResult.data.privateKey;
					AuthorityLogin.getUserLoginV1(userLogin,function (loginResult) {
						shikuLog(" getUserLoginV1 JSON loginResult : "+JSON.stringify(loginResult))

                       let decryptData =  ApiAuthUtils.decryptLoginSuccessData(loginResult.data,codeResult.code,privateKeyResult.data.privateKey,obj.field.password);
                       decryptData = JSON.parse(decryptData);
                        var loginData = {};
                        // 常用数据缓存
                        loginData.userId = codeResult.userId;
                        loginData.telephone = obj.field.telephone;
                        loginData.password = $.md5(obj.field.password);
                        loginData.access_token = decryptData.access_token;
                        loginData.loginResult = decryptData;
                        myData.access_token = decryptData.access_token;
                        myData.userId = loginData.userId;
                        loginData.httpKey = decryptData.httpKey;
                        dbStorage.userId = myData.userId;

                        var logoutTime=DataUtils.getLogoutTime();
                        $.cookie("loginData", JSON.stringify(loginData));
                        if(window.sessionStorage){
                            window.sessionStorage.setItem('loginData',JSON.stringify(loginData));
                        }
                        try{
                            if(0==logoutTime){
                                logoutTime=decryptData.login.offlineTime;
                                DataUtils.setLogoutTime(logoutTime);
                            }
                        }catch(ex){
                            console.log(ex);
                        }

                        // 登录成功，跳转到主页面
                        window.location.href = "index.html";
                    })
                })
            })
	       /* myFn.lay_invoke({
				url : '/user/login',
				data : obj.field,
				successMsg : "登录成功",
				successCb : function(result) {
					
						var loginData = {};
						// 常用数据缓存
						loginData.userId = result.data.userId;
						loginData.telephone = obj.field.telephone;
						loginData.password = obj.field.password;
						loginData.access_token = result.data.access_token;
						loginData.loginResult = result.data;
						myData.access_token=result.data.access_token;
						myData.userId=loginData.userId;
						dbStorage.userId=myData.userId;

						var logoutTime=DataUtils.getLogoutTime();
						$.cookie("loginData", JSON.stringify(loginData));
						if(window.sessionStorage){
							window.sessionStorage.setItem('loginData',JSON.stringify(loginData));
						}
						try{
			          			if(0==logoutTime){
									logoutTime=result.data.login.offlineTime;
									DataUtils.setLogoutTime(logoutTime);
								}	
					    }catch(ex){
					            console.log(ex);
					    }
						
						// 登录成功，跳转到主页面
							window.location.href = "index.html";
				},
				errorCb : function(result) {
					//layer.msg("登录失败",{icon: 2});
				}
			});*/
			// End

			layer.closeAll('loading');

	        return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。

	    });


		//自定义验证规则
		form.verify({
		    title: function(value){
		      if(value.length < 5){
		        return '标题至少得5个字符啊';
		      }
		    }
		    ,pass: [/(.+){6,12}$/, '密码必须6到12位']
		    ,content: function(value){
		      layedit.sync(editIndex);
		    }
		}); 

		//注册手机号输入框光标切换事件
		$("#register_telephone").blur(function() {
			var telephone = $("#register_telephone").val();
			if(checkTelephone(telephone)){ 
			    //layer.msg("手机号合法 :  "+telephone,{icon: 1});
			    $("#register_telephone").removeClass("layui-form-danger");
				getImgCode("reg-code-img","register_telephone");
			}else{
				// layer.msg("手机号光标切换===>>手机号不合法 :  "+telephone,{icon: 2});
				$("#register_telephone").addClass("layui-form-danger");
				
			    return; 
			}
		});

		
		//重置密码手机号输入框光标切换事件
		$("#resetPwd_telephone").blur(function() {
			var telephone = $("#resetPwd_telephone").val();
			if(checkTelephone(telephone)){ 
			    $("#resetPwd_telephone").removeClass("layui-form-danger");
				getImgCode("reset-pwd-img","resetPwd_telephone");
			}else{
				$("#resetPwd_telephone").addClass("layui-form-danger");
			    return; 
			}
		});


		//注册
		form.on('submit(register-submit)', function(obj) {
            var regeditPhoneOrName;// 0:手机号注册，1：用户名注册
            mySdk.getConfig(function(result){
                regeditPhoneOrName = result.regeditPhoneOrName;
            });
            // TODO 临时修改
            /*if(0 == regeditPhoneOrName){
            	// 校验注册时填写的手机号必须为数字
				var phone = $("#register_telephone").val();
				console.log("phone : "+phone);
                if(!/^[0-9]+$/.test(phone)){//这是用正则表达是检查
                    layer.msg("请输入有效的手机号",{icon: 2});
                    return;
                }
			}*/
            obj.field.account = $("#register_telephone").val();
	       	obj.field.areaCode = 86;//$("#register_telephone").intlTelInput("getSelectedCountryData").dialCode;
	        obj.field.password = $.md5(obj.field.password);
            obj.field.isSmsRegister = 0;
	        /*if(AppConfig.isOpenSMSCode!=0){ //开启短信验证码
	        	if(!saveAndCheckSmsCode(obj.field.telephone+"",obj.field.smsCode,"register",1)){
		        	layer.msg("错误的短信验证码",{icon: 2});
		        	return false; 
		        }
		        obj.field.isSmsRegister = 1;
	        }else if(AppConfig.registerInviteCode==1){ //开启注册型邀请码,此时邀请码属于必填项
	        	if(myFn.isNil(obj.field.inviteCode)){
	        		layer.msg("请输入邀请码证码",{icon: 2});
	        		return false;
	        	} 
	        }*/
	        obj.field.salt = getCurrentMilliSeconds();
	        delete obj.field.repassword;
	        AuthorityLogin.registerV1(obj.field,function (result) {
				console.log("registerV1  result :"+JSON.stringify(result))
                layer.msg("注册成功",{icon: 1});
                /*var tmid = setTimeout(function(){
                    window.location.href = "login.html";
                    clearTimeout(tmid);
                }, 2000);*/
            })

	       	/*myFn.lay_invoke({
                url : '/user/register',
				data : obj.field,
                successMsg : "注册成功",
                errorMsg : "注册失败,请稍后重试",
                type:"POST",
                successCb : function(result) {
     
                    $.cookie("telephone", obj["telephone"]);
					$.cookie("tel", obj["telephone"]);
					$.removeCookie("password");
					_userId = result.data.userId;

					layer.msg("注册成功",{icon: 1});
					
					var tmid = setTimeout(function(){
						window.location.href = "login.html";
						clearTimeout(tmid);
					}, 2000);
                        
                },
                errorCb : function(result) {
                	
                }
            });*/

			return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
		});


		//重置密码
		form.on('submit(reset-passwd-submit)', function(obj) {

			obj.field.areaCode = $("#resetPwd_telephone").intlTelInput("getSelectedCountryData").dialCode;
			if(!saveAndCheckSmsCode(obj.field.telephone+"",obj.field.smsCode,"resetpwd",1)){
	        	layer.msg("错误的短信验证码",{icon: 2});
	        	return false; 
	        }

	        if(obj.field.password!=obj.field.rePassword){
	        	layer.msg("两次输入的密码不一致",{icon: 2});
	        	return false; 
	        }

	        obj.field.password = $.md5(obj.field.password); 

			myFn.lay_invoke({
				url:'/user/password/reset',
				data:{
					areaCode:obj.field.areaCode,
					telephone:obj.field.telephone,
					randcode:obj.field.smsCode, 
					newPassword:obj.field.password
				},
				successMsg : "重置密码成功",
                errorMsg : "重置密码失败,请稍后重试",
                type:"POST",
				successCb:function(result){
					
					var tmid = setTimeout(function(){
						window.location.href = "login.html";
						clearTimeout(tmid);
					}, 2000);
				}
			});

			return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
		});

		//回车事件
		document.onkeydown=function(e){
			var ev=document.all?window.event:e;
			if(ev.keyCode==13){

				$("#user_login").trigger("click");
			}
		}

		loadTips();


	//});


});


//登录、注册、重置密码等页面切换
function PageSwitch(pageId){
	$("."+pageId+"").show();
	$("."+pageId+"").siblings().hide();

	if(pageId=="register_page"){ //切换到注册页面
		// 用户名、手机号注册
        if(AppConfig.regeditPhoneOrName == 0) { // 开启手机号注册
			if(AppConfig.isOpenSMSCode==1){// 开启短信验证码
                if(AppConfig.registerInviteCode!=0){ //开启邀请码
                    $(".register_inviteCode").show();
                    $(".register_page form").css("height","560px");
                }else{ //关闭邀请码
                    $(".register_inviteCode").remove();
                    $(".register_page form").css("height","510px");
                }
			}else{
                $(".reg-sms-code").remove();

                if(AppConfig.registerInviteCode!=0){ //开启邀请码
                    $(".register_inviteCode").show();
                    $(".register_page form").css("height","450px");
                }else{ //关闭邀请码
                    $(".register_inviteCode").remove();
                    $(".register_page form").css("height","400px");
                }
			}

		}else { //关闭短信验证码
			$(".reg-sms-code").remove();

			if(AppConfig.registerInviteCode!=0){ //开启邀请码
				$(".register_inviteCode").show();
				$(".register_page form").css("height","450px");
			}else{ //关闭邀请码
				$(".register_inviteCode").remove();
				$(".register_page form").css("height","400px");
			}

		} 
	}else if(pageId == "qrLogin_page"){// 切换到扫码登录
		createQRCode();
	}else{
		window.clearInterval(timer);
	}
};
var num=0;// 二维码请求校验数量
var timer ;// 定时器
// 生成二维码
function createQRCode(){
	$("#codeError").hide();
	num=0;
	$("#code").empty();
	myFn.invoke({
		url:'/getQRCodeKey',
		data:{},
        async:false,
		success:function (result) {
			console.log(result);
			$("#code").qrcode({
				// render: "table", //table方式 
				width: 200, //宽度 
				height:200, //高度 
				text: "http://shiku.co/im-download.html?action=webLogin&qrCodeKey="+result.data //任意内容 
			})

			timer = setInterval(function () {
				return checkCode(result.data);
			},1500);
		}
	})
}

// 校验code
function checkCode(code) {
	num++;
	if(num>40){
		console.log("超过一分钟，请重新生成二维码")
		window.clearInterval(timer);
		$("#codeError").show();
		$("#successScan").hide();
		return ;
	}
	myFn.invoke({
		url:'/qrCodeLoginCheck',
		data:{
			qrCodeKey:code
		},
		success:function (result) {
			console.log(result);
			if(result.resultCode==1040307){
				console.log("二维码未被扫取")
			}else if(result.resultCode==1040308){
				console.log("二维码已扫取未登录");
				$("#successScan").show();
			}else if(result.resultCode==1040309){
				console.log("成功");
				
				window.clearInterval(timer);
				console.log(result.data.QRCodeToken);
				console.log(result.data.userId);
				// autoLogin(result.data.QRCodeToken,result.data.userId);
				autoLogin(result.data);
			}else{
				console.log("程序异常")
				window.clearInterval(timer);
			}
		}
	})
}

// function autoLogin(token,userId){
function autoLogin(data){
	let obj ={};
	obj.salt = getCurrentMilliSeconds();
	obj.userId = data.userId;
    obj.loginToken = data.loginToken;
    obj.loginKey = data.loginKey;
    obj.access_token = data.QRCodeToken;
    AuthorityLogin.userLoginAutoV1(obj,function (result) {
		console.log("userLoginAutoV1 result : "+JSON.stringify(result));
		let dataVal = ApiAuthUtils.decryptAutoLoginSuccessData(result.data,obj.loginKey);
        dataVal = JSON.parse(dataVal);
        var loginData = {};
        // 常用数据缓存
        loginData.userId = dataVal.userId;
        loginData.access_token = dataVal.access_token;
		loginData.loginResult = dataVal;
        myData.access_token=dataVal.access_token;
        myData.userId=loginData.userId;
        loginData.httpKey=dataVal.httpKey;
        dbStorage.userId=myData.userId;
        var logoutTime=DataUtils.getLogoutTime();
        $.cookie("loginData", JSON.stringify(loginData));
        if(window.sessionStorage){
            window.sessionStorage.setItem('loginData',JSON.stringify(loginData));
        }
        try{
            if(0==logoutTime){
                logoutTime=dataVal.login.offlineTime;
                DataUtils.setLogoutTime(logoutTime);
            }
        }catch(ex){
            console.log(ex);
        }
        window.location.href = "index.html";
    });

	
}

//核验手机号
function checkTelephone(telephone){
	// var telphoneReg = /^(((13[0-9]{1})|(15[0-9]{1})|(18[0-9]{1}))+\d{8})$/; 
	var telphoneReg = /^(([1-9]{1})+\d{4,})$/; 
	if(!telphoneReg.test(telephone)){
	    return false; 
	}else{
		return true;
	}

}


function loadTips(){
	//根据请求参数加载提示信息
	var url=location.href;
	var number = url.substr(url.indexOf("#")+1);
	if(number!=null && number!=undefined && number==10359){
		var tipsHtml = '<div id="J_xiaomi_dialog" style="z-index: 999999; top: 35%; left: 5%;">'+
						'<div class="J_strong">'+
							'<div class="alicare-strong-card">'+
								'<p class="alicare-strong-header alicare-draggable" style="cursor: move;">'+
									'客服系统试用账号'+
								'</p>'+
								'<ul>'+
									'<li data-id="0" data-index="1">试用账号1：13530899430 密码：123456</li>'+
									'<li data-id="0" data-index="2">试用账号2：15678848206 密码：123456</li>'+
									'<li data-id="0" data-index="3">试用账号3：15768140059 密码：123456</li>'+
									'<li data-id="0" data-index="4">试用账号4：15800003333 密码：123456</li>'+
									'<li data-id="0" data-index="5">试用账号5：15512345678 密码：123456</li>'+
									'<li data-id="0" data-index="6">试用账号6：13530899438 密码：123456</li>'+
									'<li data-id="0" data-index="7">试用账号7：13530899431 密码：123456</li>'+
									'<li data-id="0" data-index="8">试用账号8：13530899435 密码：123456</li>'+
								'</ul>'+
							'</div>'+
						'</div>'+
					'</div>';
		$("#tryUseTitp").append(tipsHtml);
	}

};



//获取图形码
function getImgCode(show_area_id,tel_input_id){
	
	var areaCode = $("#"+tel_input_id+"").intlTelInput("getSelectedCountryData").dialCode;
	var telephone = $("#"+tel_input_id).val();
	if(checkTelephone(telephone)){
		document.getElementById(show_area_id+"").setAttribute('src',AppConfig.apiUrl+"/getImgCode?telephone="+areaCode+telephone+"&n="+Math.random());
	}else{
		document.getElementById(show_area_id+"").setAttribute('src',"./img/get_img_code.png");
		layer.msg("请输入正确的手机号后再获取邀请码",{icon: 2});
	}	
	
}


//发送短信验证码
function sendmessage(show_area_id,imgCode_id,telephone_id,type){
	
	//数据核验
	var imgCode =  $("#"+imgCode_id).val();
	var areaCode = $("#"+telephone_id+"").intlTelInput("getSelectedCountryData").dialCode;
	var telephone = $("#"+telephone_id).val();

	if(!checkTelephone(telephone)){
		layer.msg("请输入正确的手机号",{icon: 2});
		return false;
	}

	if (myFn.isNil(imgCode)) {
		layer.msg("请输入图形码",{icon: 2});
		return false;
	}

	var getSmsCodeObj = document.getElementById(show_area_id+"");
	var time=60; 

	myFn.lay_invoke({
        url:'/basic/randcode/sendSms',
	 	data:{	
	 		telephone:telephone,
	 		areaCode:areaCode,
	 		version:0,
	 		imgCode:imgCode,
	 		isRegister:type,
	 	},
	 	type:"POST",
        successMsg : false,
        errorMsg : "短信验证码发送失败,请稍后重试",
        successCb : function(result) {
            
            saveAndCheckSmsCode(telephone,result.data.code,(type==1?'register':'resetpwd'),0);
            layer.msg("短信验证码发送成功",{icon: 1});
	 		//倒计时UI
 			var opentime = setInterval(function() { 
				getSmsCodeObj.innerHTML = time+' 秒后重新获取';
				time--;
				if(time<=0){
		            getSmsCodeObj.innerHTML = '重新获取';
					clearInterval(opentime);
				}
			},1000);
                
        },
        errorCb : function(result) {
        	
        }
    });

}



function saveAndCheckSmsCode(telephone,smsCode,name,type){  
		/**
		* type : 0 ==>sava   1==>check
		* name  eg: "register"
		**/
 		
 		if(type == 0){ //sava   max time： 5 minute
 			localStorage.setItem(name+'_smsCode',JSON.stringify({telephone:telephone,smsCode:smsCode}));
 			var savaSmsCode = setTimeout(function() { 
				localStorage.removeItem(name+'_smsCode');
				clearTimeout(savaSmsCode);
			},1000*60*5);

			return;

 		}else if(type == 1){ //check
 			var dataObj = JSON.parse(localStorage.getItem(name+'_smsCode'));
 			if(dataObj!=null && telephone==dataObj.telephone && smsCode == dataObj.smsCode){
 				//localStorage.removeItem(name+'_smsCode');
 				return true;
 			}
 			return false;
 		}

}


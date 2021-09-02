var Config={
	uploadUrl:"",
	apiKey:""
}
$(function(){
	myFn.getConfig();
})

var myFn = {
	invoke : function(obj) {
		jQuery.support.cors = true;
		if(!obj.data.secret){
			obj.data=createCommApiSecret(obj.data);
		}
		var params = {
			type : "POST",
			url : obj.url,
			data : obj.data,
			contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
			dataType : 'JSON',
			async:false,
			success : function(result) {
				if(1==result.resultCode){
					obj.success(result);

				}else if(1030101==result.resultCode){
					//缺少访问令牌
					layer.msg("登录异常",{icon: 3});
					window.parent.location.href = "/open/login";
				}else if(1030102==result.resultCode){// 访问令牌过期
					layer.confirm(result.resultMsg,{icon:2, title:'提示消息',yes:function () {
							window.parent.location.href="/open/login";
						},btn2:function () {
							window.parent.location.href="/open/login";
						},cancel:function () {
							window.parent.location.href="/open/login";
						}});
					// layer.msg("登录过期,请重新登录",{icon: 3});
					// window.parent.location.href = "/open/login";
				}else{
					if(result.resultMsg)
						layer.msg(result.resultMsg,{icon: 2,time: 2000});
					else
						layer.msg(obj.errorMsg,{icon: 2,time: 2000});
				}
			},
			error : function(result) {
				obj.error(result);
			},
			complete : function() {
			}
		};
		params.url = params.url;
		params.data["access_token"] = localStorage.getItem("access_token");
		$.ajax(params);
	},
	isNil : function(s) {
		return undefined == s || null == s || $.trim(s) == "" || $.trim(s) == "null";
	},
	getConfig:function(){
		$.ajax({
		    url:'/config',
		    async:false,
		    success:function(result){
		      console.log(result.data.uploadUrl);
		      Config.uploadUrl=result.data.uploadUrl+"upload/UploadifyServlet";
		    }
		  });
	},

    /**
	 * 校验域名合法性 支持二级域名
     * @param str_url
     * @returns {boolean}
     * @constructor
     */
    IsURL: function (str_url) {
        var strRegex = "^((https|http|ftp|rtsp|mms)?://)"
            + "?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?" //ftp的user@
            + "(([0-9]{1,3}\.){3}[0-9]{1,3}" // IP形式的URL- 199.194.52.184
            + "|" // 允许IP和DOMAIN（域名）
            + "([0-9a-z_!~*'()-]+\.)*" // 域名- www.
            + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\." // 二级域名
            + "[a-z]{2,6})" // first level domain- .com or .museum
            + "(:[0-9]{1,4})?" // 端口- :80
            + "((/?)|" // a slash isn't required if there is no file name
            + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$";
        var re = new RegExp(strRegex);
        if (re.test(str_url)) {
            return true;
        } else {
            return false;
        }
    },
}


function createCommApiSecret(obj){
		obj.time=Math.round(((new Date().getTime())/1000));
		var key="";
		if(!myFn.isNil(obj.userId)&&!myFn.isNil(obj.access_token)){
			key = Config.apiKey+obj.time+obj.userId+obj.access_token;
		}else{
			key = Config.apiKey+obj.time+localStorage.getItem("userId")+localStorage.getItem("access_token");
		}
		
		var md5Key=$.md5(key);
		obj.secret=md5Key;
		return obj;
}
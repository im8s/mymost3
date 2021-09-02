var AppConfig={
    // apiUrl : "https://im.shikutech.com",// 接口地址
//    apiUrl : "http://192.168.0.141:8092",// 接口地址
//    apiUrl : "http://120.79.25.45:8092",// 接口地址
    avatarBase : "",// 头像父目录
    apiKey:"",
}

$(function(){
	myFn.invoke({
		url:'/config',
		success:function(result){
			AppConfig.avatarBase=result.data.downloadAvatarUrl+"avatar/o/";
		}
	
	})
})

var myFn = {

    invoke: function (obj) {
        console.log("request obj :"+JSON.stringify(obj))
        if(!myFn.isNil(obj.data)){
            if(!obj.data.secret) {
                obj.data=this.createCommApiSecret(obj.data);
            }
        }

        jQuery.support.cors = true;
        var params = {
            type: "POST",
            url: obj.url,
            data: obj.data,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            dataType: 'JSON',
            async:false,
            success: function (result) {
                obj.success(result);
            },
            error: function (result) {
                //ownAlert(2,result.resultMsg);
                obj.error(result);
            },
            complete: function () {
            }
        };
        //$.extend(params, obj);
//        params.url = AppConfig.apiUrl + params.url;
        params.url = params.url;
        $.ajax(params);
    },

    // 获取头像
    getImgUrl : function(userId){
        /*if(10000==userId)
            return "/pages/img/im_10000.png";*/
        // var downUrl = AppConfig.avatarBase+"avatar/o/";// 头像访问路径
        return AppConfig.avatarBase + (parseInt(userId) % 10000) + '/' + userId + '.jpg';
    },

    //创建 密钥
    createCommApiSecret : function (obj) {
        var time = this.getCurrentSeconds();
        var api_time=AppConfig.apiKey+time;
        var md5Key=$.md5(api_time);
        obj.time = time;
        obj.secret=md5Key;
        return obj;
    },

    isNil : function(s) {
        return undefined == s ||"undefined"==s|| null == s || $.trim(s) == "" || $.trim(s) == "null"||NaN==s;
    },

    // 当前时间
    getCurrentSeconds : function () {
        return Math.round(new Date().getTime() / 1000);
    },

    set: function (key, value, ttl_ms) {
        var data = { value: value, expirse: new Date(ttl_ms).getTime() };
        localStorage.setItem(key, JSON.stringify(data));
    },
    // new Date().getTime()
    get: function (key) {
        var data = JSON.parse(localStorage.getItem(key));
        if (data !== null) {
            debugger
            if (data.expirse != null && data.expirse < myFn.getCurrentSeconds()) {
                localStorage.removeItem(key);
            } else {
                return data.value;
            }
        }
        return null;
    },

}
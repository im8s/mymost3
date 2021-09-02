
var Login= {

    // 授权登录
    authorLogin: function () {
        var telephone, pwd;
        telephone = $.md5($("#telephone").val());
        pwd = $.md5($("#pwd").val());
        console.log("telephone : " + telephone + " ========  " + "pwd : " + pwd);
        myFn.invoke({
            url: '/user/login',
            data: {
                telephone: telephone,
                password: pwd,
            },
            success: function (result) {
                if (1 == result.resultCode) {
                    console.log(result.data)
                    // 自己的接口拿code
                    // var appId = "sk7c4fd05f92c7460a";
                    // var redirectURL = "http://www.meituan.com"
                    console.log("authorLogin data :"+requestData.appId+"  url : "+requestData.callbackUrl);
                    Login.authoCode(requestData.appId, result.data.access_token, requestData.callbackUrl);
                } else {
                    console.log("登录失败" + " ======== " + result.resultMsg);
                    $('.modal-body').html(result.resultMsg);
                    $("#errorMsgByTelephone").modal('show');
                }

            },
            error: function (result) {
                console.log("登录失败！请稍后再试。");
            }
        })
    },

    // 拿code
    authoCode: function (appId, state, callbackUrl) {
        myFn.invoke({
            url: '/open/codeAuthorCheck',
            data: {
                appId: appId,
                state: state,
                callbackUrl: callbackUrl
            },
            success: function (result) {
                if(1 == result.resultCode){
                    console.log("codeAuthorCheck : " + result.data);
                    console.log("code : " + result.data.code);
                    console.log("URL : " + result.data.callbackUrl + "?code=" + result.data.code);
                    // 获取code后重定向到第三方回调地址
                    let callbackUrl = result.data.callbackUrl;
                    if(callbackUrl.indexOf("?") != -1){
                        window.location.href = callbackUrl + "&code=" + result.data.code;
                    }else{
                        window.location.href = callbackUrl + "?code=" + result.data.code;
                    }
                }else{
                    alert(result.resultMsg);
                }

            },
            error: function () {
                alert("网络异常，请重试")
            }
        });
    },
}


    function GetRequest() {
        var url = location.search; //获取url中"?"符后的字串
            var theRequest = new Object();
            if (url.indexOf("?") != -1) {
                var str = url.substr(1);
                strs = str.split("&");
                for(var i = 0; i < strs.length; i ++) {
                    theRequest[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
                }
    }
    return theRequest;
}

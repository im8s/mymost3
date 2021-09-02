/**
 *  登录加固通用数据封装处理API
 */


var ApiAuthUtils = {

    /**
     * 参数mac验签同时验登录密码，内容为apiKey + areaCode+account+ salt，
     * mac key为登录密码密文, HMACMD5算法结果取base64编码成字符串，
     * @param pwd
     * @param obj
     * @returns {*}
     */
    getLoginCodeParam:function(obj){
        obj.areaCode = obj.areaCode ? obj.areaCode : "";
        let macValue = obj.apiKey+obj.areaCode+obj.account+obj.salt;
        console.log("getLoginCode param macValue :",macValue);
        obj.mac = EncryptUtils.encryptMacToBase64(macValue,EncryptUtils.buildLoginPassword(obj.password));
        var objParam = {};
        objParam.areaCode = obj.areaCode;
        objParam.account = obj.account;
        objParam.salt = obj.salt;
        objParam.deviceId = "web";
        objParam.mac = obj.mac;
        return objParam;
    },

    /**
     * 获取加密私钥
     * 参数mac验签同时验登录密码，内容为apiKey + userId+ salt，
     * mac key为登录密码密文, HMACMD5算法结果取base64编码成字符串，
     * @param obj
     */
    getLoginPrivateKeyParam:function(obj){
        obj.mac = EncryptUtils.encryptMacToBase64(obj.apiKey+obj.userId+obj.salt,EncryptUtils.buildLoginPassword(obj.pwd));
        let privateKey = {};
        privateKey.userId = obj.userId;
        privateKey.salt = obj.salt;
        privateKey.apiKey = obj.apiKey;
        return obj;
    },

    /**
     * 上传RSA公私钥
     *
     * 参数userId，判断身份用，
     * 参数salt为时间，精确到毫秒的13位数字，
     *
     * 参数privateKey表示加密私钥，aes加密，加密内容是私钥字节数组不是base64字符串，aes key为登录密码明文, 加密结果 base64编码
     *
     * 参数publicKey表示公钥，base64编码
     参数mac验签，内容为apiKey+userId+privateKey+ publicKey+salt,
     参与拼接的公私钥是base64编码后的字符串，应当与参数字符串完全相同，不能出现base64解码后再编码才参与计算，
     key为登录密码密文，HMACMD5算法结果取base64编码成字符串，
     * @param obj
     */
    uploadLoginKeyParam:function(obj){
        // 生成一对RSA公私钥
        let keyPrair = EncryptUtils.generatedRSAKey();
        let rsaPrivate = keyPrair.getPrivateKeyB64();
        let rsaPublic = keyPrair.getPublicKeyB64();
        obj.privateKey = EncryptUtils.encryptAES_StrToStr_test(CryptoJS.enc.Base64.parse(rsaPrivate),CryptoJS.MD5(obj.pwd));
        obj.publicKey = rsaPublic;
        let macParam = obj.apiKey + obj.userId + obj.privateKey + rsaPublic + obj.salt;
        obj.mac = EncryptUtils.encryptMacToBase64(macParam,EncryptUtils.buildLoginPassword(obj.pwd));
        let longKeyParam = {};
        longKeyParam.salt = obj.salt;
        longKeyParam.userId = obj.userId;
        longKeyParam.privateKey = obj.privateKey;
        longKeyParam.publicKey = rsaPublic;
        longKeyParam.mac = obj.mac;
        return longKeyParam;
    },
    /**
     * forge 上传生成RSA公私钥
     */
    uploadLoginKeyParam_Forge:function(obj){
        const kp = forge.pki.rsa.generateKeyPair(1024);
        // 和其他平台统一的(pkcs1|x509)&der格式公私钥字节数组，
        let publicKey = forge.util.encode64(EncryptUtils.toPublicKeyData(kp.publicKey));
        let rsaPrivate = forge.util.encode64(EncryptUtils.toPublicKeyData(kp.privateKey));
        obj.privateKey = EncryptUtils.encryptAES_StrToStr_test(CryptoJS.enc.Base64.parse(rsaPrivate),CryptoJS.MD5(obj.pwd));
        obj.publicKey = publicKey;
        let macParam = obj.apiKey + obj.userId + obj.privateKey + publicKey + obj.salt;
        obj.mac = EncryptUtils.encryptMacToBase64(macParam,EncryptUtils.buildLoginPassword(obj.pwd));
        let longKeyParam = {};
        longKeyParam.salt = obj.salt;
        longKeyParam.userId = obj.userId;
        longKeyParam.privateKey = obj.privateKey;
        longKeyParam.publicKey = publicKey;
        longKeyParam.mac = obj.mac;
        return longKeyParam;
    },



    /**
     * 参数userId，判断身份用，
     参数salt为时间，精确到毫秒的13位数字，
     参数deviceId设备名，与接口1上传的该参数相同，即android、ios、web，用于服务器获取对应code使用，
     参数data为aes加密json参数列表，
     aes加密key为接口1获取到的code,
     aes加密内容json参数列表为该接口原有参数外加以下几个参数，
     参数mac验参同时验登录密码，内容为apiKey+userId+所有参数依次排列+salt+登录密码密文，key为接口1获取到的code, HMACMD5算法结果取base64编码成字符串，
     *
     * forge rsa 相关处理
     * 登录加固接口
     */
    getUserLoginV1Param_Forge:function(obj){
        var userLoginParam = {};
        obj.deviceId = "web";
        userLoginParam.deviceId = obj.deviceId;
        userLoginParam.userId = obj.userId;
        userLoginParam.salt = obj.salt;
        // 解密code 1.获取私钥 2.解密私钥 3.创建秘钥 4。解密code
        // code为随机128位16字节数组byte[]公钥rsa加密后base64编码
        let privateKey = obj.privateKey;
        let decryptPrivateKey = EncryptUtils.decryptAES_Str(privateKey,CryptoJS.MD5(obj.pwd));// aes解密私钥
        let decryptCode = EncryptUtils.rsaDecrypt(obj.code,decryptPrivateKey);
        //console.log("loginv1 code :"+obj.code+"  decryptcode："+ decryptCode);
        //console.log("paramKeySort : "+EncryptUtils.paramKeySort(userLoginParam))
        //console.log("loginV1 macValue :"+obj.apiKey+obj.userId+EncryptUtils.paramKeySort(userLoginParam)+obj.salt+EncryptUtils.buildLoginPassword(obj.pwd));
        var macValue= obj.apiKey+obj.userId+EncryptUtils.paramKeySort(userLoginParam)+obj.salt+EncryptUtils.buildLoginPassword(obj.pwd);
        let mac = EncryptUtils.encryptMacToBase64(macValue,CryptoJS.enc.Base64.parse(decryptCode));
        userLoginParam.mac = mac;
        userLoginParam.data = EncryptUtils.encryptAES_StrToStr(JSON.stringify(userLoginParam),decryptCode);
        delete userLoginParam.mac;
        return userLoginParam;
    },

    /**
     * 解密登录成功后返回的data
     *
     * 返回结果data为加密结果列表，具体是json字符串aes加密后的base64编码，
     * aes加密key为接口1获取到的code,私钥解密
     */
    decryptLoginSuccessData:function(data,code,privateKey,pwd){
        let decryptPrivateKey = EncryptUtils.decryptAES_Str(privateKey,CryptoJS.MD5(pwd));// aes解密私钥
        let decryptCode = EncryptUtils.rsaDecrypt(code,decryptPrivateKey);
        data = EncryptUtils.decryptAES(data,CryptoJS.enc.Base64.parse(decryptCode));
        let userData = CryptoJS.enc.Utf8.stringify(data);
        shikuLog("login success testData : "+userData);
        return userData;
    },

    /**
     *
     * 参数salt为时间，精确到毫秒的13位数字，
     参数deviceId设备名，与接口1上传的该参数相同，即android、ios、web，
     参数data为aes加密json参数列表，
     aes加密key为apiKey计算md5后的16字节数据,
     aes加密内容json参数列表为该接口原有参数外加以下几个参数，
     参数smsCode检查短信验证码，
     参数mac验参，内容为apiKey +所有参数依次排列+salt，key为apiKey计算md5后的16字节数据, HMACMD5算法结果取base64编码成字符串，
     返回结果同密码登录接口4，解密key为apiKey计算md5后的16字节数据,
     *
     * 普通注册接口user/register/v1
     *
     */
    userRegeditParam:function(obj){
        let paramSortVal = EncryptUtils.paramKeySort(obj);
        let macVal = AppConfig.apiKey+paramSortVal+obj.salt;
        let mac = EncryptUtils.encryptMacToBase64(macVal,CryptoJS.MD5(AppConfig.apiKey));
        obj.mac = mac;
        let regeditParam = {};
        regeditParam.data = EncryptUtils.encryptAES_StrToStr_test(JSON.stringify(obj),CryptoJS.MD5(AppConfig.apiKey));
        regeditParam.deviceId = "web";
        regeditParam.salt = obj.salt;
        return regeditParam;
    },

    /**
     * /user/login/auto/v1?
     data=+9hiSVdSfwo8Fs8aPiAOhw/rJkT14y4syOoyfaxXQ5fEupWI2MfmxWqtbK4FXmtq7XcxBr6uEj9rpLRX/MGyqjLVpANzLikAp5OvX0xwGIKpcmKhBnrHABpcpUD0j4Csh+1Lqh+EcBQHze25H3iAm3dURP39GhwYVnFruQnbBzL44XT2E8f8YIF/B2wx613+zQW5pPQ4w3eghJ8g8ykOw6zbQxuJtuS05SwL1E/CinkTMZaGWbrcdTUXSLQwceUjaSg/f/vPmf2vSev2h0EaJg==&
     loginToken=7194d5edd86149a7a50a557230a046f0&
     salt=1568774355856&
     secret=RAg1ct7hryQdf+krVrs78w==&
     *
     * 参数loginToken为登录身份，用于判断登录的用户以及设备，base64编码字符串，
     参数salt为时间，精确到毫秒的13位数字，
     参数data为加密参数列表，具体是json字符串aes加密后base64编码，
     aes加密key为该loginToken对应loginKey, base64解码后的16字节数据，
     json参数列表为该接口原有参数外加以下几个参数，参数mac验参，内容为apiKey+userId+loginToken+所有参数依次排列+salt，key为loginKey,

     返回结果data为加密结果列表，具体是json字符串aes加密后的base64编码，
     aes加密key为该loginToken对应loginKey, base64解码后的16字节数据，
     json格式返回结果有以下几个字段，
     accessToken, 用于普通接口明文传输判断身份，16字节随机数组base64编码，
     httpKey 用于加密自动登录参数列表，不明文传输，16字节随机数组base64编码，
     messageKey 用于消息加固，具体待定，
     payKey 用于支付加固，具体待定，
     自动登录接口也按登录前普通接口添加secret验参，不带accessToken,
     如果loginToken过期返回错误码1030112，
     需要退出登录，回到密码登录页面，
     *
     * @param obj
     */
    userAutoLoginParam:function(obj){
        let macSoart ={};
        macSoart.access_token = obj.access_token;
        macSoart.userId = obj.userId;
        let paramSortVal = EncryptUtils.paramKeySort(macSoart);
        let macVal = AppConfig.apiKey+obj.userId+obj.loginToken+paramSortVal+obj.salt;
        macSoart.mac = EncryptUtils.encryptMacToBase64(macVal,CryptoJS.enc.Base64.parse(obj.loginKey));
        let autoLoginParam = {};
        autoLoginParam.data = EncryptUtils.encryptAES_StrToStr_test(JSON.stringify(macSoart),CryptoJS.enc.Base64.parse(obj.loginKey));
        autoLoginParam.loginToken = obj.loginToken;
        autoLoginParam.salt = obj.salt;
        return autoLoginParam;
    },

    /**
     *返回结果data为加密结果列表，具体是json字符串aes加密后的base64编码，
     aes加密key为该loginToken对应loginKey, base64解码后的16字节数据，
     json格式返回结果有以下几个字段，
     accessToken, 用于普通接口明文传输判断身份，16字节随机数组base64编码，
     httpKey 用于加密自动登录参数列表，不明文传输，16字节随机数组base64编码，
     messageKey 用于消息加固，具体待定，
     payKey 用于支付加固，具体待定，
     自动登录接口也按登录前普通接口添加secret验参，不带accessToken,
     如果loginToken过期返回错误码1030112，
     需要退出登录，回到密码登录页面，
     *
     * 解密自动登录成功后返回的data
     */
    decryptAutoLoginSuccessData:function(data,loginKey){
        let dataVal = EncryptUtils.decryptAES(data,CryptoJS.enc.Base64.parse(loginKey));
        let userData = CryptoJS.enc.Utf8.stringify(dataVal);
        console.log("decryptAutoLoginSuccessData  userData :"+userData);
        return userData;
    },


    /**
     * 登录前的秘钥生成规则secret
     * 参数secret验签，内容为apiKey +所有参数依次排列+salt，key为apiKey计算md5后的
     * @param obj
     * @returns {*}
     */
    apiAuthoCreateSecret:function(obj,timeSend,url){
        //console.log("登录前的url : "+url);
        let sortParam = EncryptUtils.paramKeySort(obj);
        //console.log("sortParam :"+sortParam);
        if(myFn.isNil(timeSend))
            timeSend = getCurrentMilliSeconds();
        obj.secret = AppConfig.apiKey+sortParam+timeSend;
        //console.log("请求参数排序结果 ："+obj.secret);
        obj.secret = EncryptUtils.encryptMacToBase64(obj.secret,CryptoJS.MD5(AppConfig.apiKey));
        obj.salt = timeSend;
       // console.log("计算后的secret  ："+obj.secret);
        return obj;
    },

    /**
     * 登录后普通接口mac验参，添加参数，
     参数salt为时间，精确到毫秒的13位数字，
     参数secret验签，内容为apiKey+userId+accessToken+所有参数依次排列+salt，key为httpKey做base64解码后的16字节数据, HMACMD5算法结果取base64编码成字符串，
     *  userId 当前请求的人
     * 登录后的秘钥生成规则
     * @param obj
     * @param timeSend
     */
    apiAuthoLoginCreateSecret:function(obj,timeSend,url){
       // console.log("login 后的url : "+url);
        let sortParam = EncryptUtils.paramKeySort(obj);
        //console.log("login 后参数排序 ："+sortParam);
        if(myFn.isNil(timeSend))
            timeSend = getCurrentMilliSeconds();
        obj.secret = AppConfig.apiKey+myData.userId+myData.access_token+sortParam+timeSend;
        obj.secret = EncryptUtils.encryptMacToBase64(obj.secret,CryptoJS.enc.Base64.parse(myData.httpKey));
        obj.salt = timeSend;
        return obj;
    },

    /**
     * 创建密钥 secret
     * @param obj
     * @returns {*}
     */
    apiCreateCommApiSecret:function(obj,url){
        let timesend = obj.salt;
        delete obj.salt;
        var key="";
        if(!myFn.isNil(myData.access_token)){
            //console.log("login  后")
            return ApiAuthUtils.apiAuthoLoginCreateSecret(obj,timesend,url);
        }else{
            //console.log("login  前")
            return ApiAuthUtils.apiAuthoCreateSecret(obj,timesend,url);
        }
        var md5Key=$.md5(key);
        obj.secret=md5Key;
        return obj;
    },



};

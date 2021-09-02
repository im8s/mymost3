var EncryptUtils={
	AES:{
		aesIvKey:null,
		getAesIvKey:function(){
			if(!this.aesIvKey){
				let ivArr=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
				let iv=EncryptUtils.getStrFromBytes(ivArr);
				this.aesIvKey=CryptoJS.enc.Utf8.parse(iv);
			}
			return this.aesIvKey;
		},
		encrypt:function (value,key) {
			return CryptoJS.AES.encrypt(value, key, this.getOption(this.getAesIvKey()));
		},
		decrypt:function (value,key) {
			return CryptoJS.AES.decrypt(value, key,this.getOption(this.getAesIvKey()));
		},
		option:null,
		getOption:function(ivKey){
			if(!this.option){
				this.option={
		    	 iv: ivKey,
			    mode:CryptoJS.mode.CBC,
			    padding:CryptoJS.pad.Pkcs7,
		    	}
			}
		   
		    return this.option;
		 },
	},

    encryptAES_StrToStr_test:function(value,key){
        // value=CryptoJS.enc.Utf8.parse(value);
        // key=CryptoJS.enc.Base64.parse(key);
        let result= this.AES.encrypt(value,key);
        return CryptoJS.enc.Base64.stringify(result.ciphertext);
    },

    encryptAES_StrToStr:function(value,key){
		value=CryptoJS.enc.Utf8.parse(value);
		key=CryptoJS.enc.Base64.parse(key);
		let result= this.AES.encrypt(value,key);
		return CryptoJS.enc.Base64.stringify(result.ciphertext);
	},
	encryptAES:function(value,key){
		return this.AES.encrypt(value,key);
	},

    decryptAES_Str:function(value,key){
        let result = this.AES.decrypt(value,key);
        return CryptoJS.enc.Base64.stringify(result);
    },
	decryptAES:function(value,key){
		return this.AES.decrypt(value,key);
	},
	encryptMac:function(value,key){
		return CryptoJS.HmacMD5(value, key);
	},
	encryptMacToBase64:function(value,key){
		let mac= this.encryptMac(value, key);
		return CryptoJS.enc.Base64.stringify(mac);
	},
	/*
	构建登陆密码  
	pwd 密文密码
	*/
	buildLoginPassword:function(pwd){
		let md5pwd=CryptoJS.MD5(pwd);
		//console.log("md5 "+md5pwd.toString());
		let md5Str=CryptoJS.enc.Base64.stringify(md5pwd);
		let encryptAES=EncryptUtils.encryptAES(CryptoJS.enc.Base64.parse(md5Str),md5pwd);
		//console.log("encryptAES ===> "+encryptAES);
		let md5Aes=CryptoJS.MD5(encryptAES.ciphertext);

		//console.log("Base64 MD5 ===> "+CryptoJS.enc.Base64.stringify(md5Aes));
		let encode =CryptoJS.enc.Hex.stringify(md5Aes);
		//console.log("pwd encode ===> "+md5Aes);
		return encode;
	},
	rsaKeySize:1024,
	/*
	key 公钥 or 私钥
	key 不传值 则创建一对新的密钥对
	*/
	generatedRSAKey:function(key){
		/*创建 RSA 密钥对*/
		let rsaKeyPair = new JSEncrypt({default_key_size:this.rsaKeySize});
		if(!key){
			rsaKeyPair.getKey();
		}else {
			rsaKeyPair.setKey(key);
		}

		return rsaKeyPair;
	},
	/*
	RSA 加密
	keyPair 公钥
	*/
	encryptByRSA:function(keyPair,str){
		return keyPair.encrypt(str);
	},
	/*
	RSA 解密
	keyPair 私钥
	*/
	decryptByRSA:function(keyPair,str){
		return keyPair.decrypt(str);
	},

	/*
	RSA 签名方法
	keyPair 密钥对 
	str 签名字符串
	*/
	signByRSA:function(keyPair,str){
		return keyPair.sign(str,CryptoJS.SHA1,"sha1");
	},


	/*
	str  验签明文
	signStr 验签密文
	*/
	verifyByRSA:function(keyPair,str,signStr){
		return keyPair.verify(str,signStr,CryptoJS.SHA1);
	},

	/*
	DH 算法
	*/
	DH:{
		/*
		公钥转换截取 字符串
		*/
		beginPubKey:"3056301006072a8648ce3d020106052b8104000a034200",

		/*
		私钥转换截取 字符串 前缀
		*/
		beginPriKey:"30740201010420",
		/*
		私钥转换截取 字符串 后缀
		*/
		endPriKey:"A00706052B8104000AA144034200",
		ecdh:null,/*DH 对象*/
		getECDH:function(){
			if(!this.ecdh)
			 	this.ecdh = new elliptic.ec('secp256k1');
			 return this.ecdh;
		},
		/*
		创建DH 密钥对
		*/
		genKeyPair:function(){
			return this.getECDH().genKeyPair();
		},
		/*
		js DH公钥对象转换为 服务器 base64 公钥字符串
		pub  js DH公钥对象
		*/
		encryptPublicKey:function(pub){
			let pubHexStr= this.beginPubKey+pub.encode('hex');
			let pubByte=CryptoJS.enc.Hex.parse(pubHexStr);
			return CryptoJS.enc.Base64.stringify(pubByte);
		},
		/*
		服务器 公钥字符串 转换为 js 公钥
		pubBase64Str base64 的公钥字符串
		*/
		decryptPublicKey:function(pubBase64Str){
			 let byteBase64= CryptoJS.enc.Base64.parse(pubBase64Str);
			let hexString = CryptoJS.enc.Hex.stringify(byteBase64);
			//console.log("hexString ",hexString);
			hexString=hexString.substring(46,hexString.length); 
			return this.getECDH().keyFromPublic(hexString,"hex");
		},
		/*
		js DH私钥对象转换为 服务器 base64 公钥字符串
		keyPair  js 密钥对象
		*/
		encryptPrivateKey:function(keyPair){
			let pri=keyPair.getPrivate('hex');
			let pub=keyPair.getPublic('hex');
			let priHexStr= this.beginPriKey+pri+this.endPriKey+pub;
			let priByte=CryptoJS.enc.Hex.parse(priHexStr);
			return CryptoJS.enc.Base64.stringify(priByte);
		},
		/*
		服务器 私钥字符串 转换为 js 密钥
		priBase64Str base64 的私钥字符串
		*/
		decryptPrivateKey:function(priBase64Str){
			 let byteBase64= CryptoJS.enc.Base64.parse(priBase64Str);
			let hexString = CryptoJS.enc.Hex.stringify(byteBase64);
			//console.log("hexString ",hexString);
			hexString=hexString.substring(14,hexString.length); 
			hexString=hexString.substring(0,64); 
			//console.log("decryptPrivateKey pri ",hexString);
			return this.getECDH().keyFromPrivate(hexString,"hex");
		},


	},
	/*
	创建DH 密钥对
	*/
	genDHKeyPair:function(){
		return this.DH.genKeyPair();
	},
	/*
	js DH公钥对象转换为 服务器 base64 公钥字符串
	pub  js DH公钥对象
	*/
	encryptDHPublicKey:function(pub){
		return this.DH.encryptPublicKey(pub);
	},
	/*
	服务器 公钥字符串 转换为 js 公钥
	pubBase64Str base64 的公钥字符串
	*/
	decryptDHPublicKey:function(pubBase64Str){
		return this.DH.decryptPublicKey(pubBase64Str);
	},
	/*
	js DH私钥对象转换为 服务器 base64 公钥字符串
	keyPair  js 密钥对象
	*/
	encryptDHPrivateKey:function(keyPair){
		return this.DH.encryptPrivateKey(keyPair);
	},
	/*
	服务器 私钥字符串 转换为 js 公钥
	priBase64Str base64 的私钥字符串
	*/
	decryptDHPrivateKey:function(priBase64Str){
		return this.DH.decryptPrivateKey(priBase64Str);
	},
	/*
	根据 base64 私钥字符串 和 base64 的公钥字符串
	生成协商密钥 base64 字符串
	*/
	deriveDHFromBase64Key:function(priBase64Str,pubBase64Str){
		let priKey=this.decryptPrivateKey(priBase64Str);
		let key=this.decryptDHPublicKey(pubBase64Str);
		let deriveKey=priKey.derive(key.getPublic());
		let hex=CryptoJS.enc.Hex.parse(comm1.toString(16));
		return CryptoJS.enc.Base64.stringify(hex);
	},
	/*
	根据 密钥对 和 base64 的公钥字符串
	生成协商密钥 base64 字符串
	*/
	deriveDHKey:function(keyPair,pubBase64Str){
		let key=this.decryptDHPublicKey(pubBase64Str);
		let deriveKey=keyPair.derive(key.getPublic());
		let hex=CryptoJS.enc.Hex.parse(comm1.toString(16));
		return CryptoJS.enc.Base64.stringify(hex);
	},


	/*
	字节数组转换为字符串
	*/
	getStrFromBytes:function (arr) {
		let r = "";
	   /* for (let i in arr) {
	    	r += String.fromCharCode(i);
	    }*/
		 for(let i=0;i<arr.length;i++){
		    r += String.fromCharCode(arr[i]);
		 }
		//console.log(r);
		return r;
	},
	/**
		按参数名的ascii码从小到大排序
		如age在city前
	*/
	paramKeySort:function(arys){
		//先用Object内置类的keys方法获取要排序对象的属性名数组，
		//再利用Array的sort方法进行排序
       let newkey = Object.keys(arys).sort();
       // console.log('newkey=' + newkey);
       //创建一个新的对象，用于存放排好序的键值对
       let newObj = ''; 
       for (let i = 0; i < newkey.length; i++) {
       	/*if(newkey[i] == "salt"){
       		continue;
		}*/
       	if(myFn.isNil(arys[newkey[i]])){
       		continue
		}
           //遍历newkey数组
           // newObj += [newkey[i]] + '=' + arys[newkey[i]] + '&';
           newObj += arys[newkey[i]];
       }
   	 	// return newObj.substring(0, newObj.length - 1);
   	 	return newObj;
	},

    /**
     * rsa解密，
     *
     * @param data 密文byte string,
     * @param privateKeyData pkcs1&der格式私钥，
     */
	rsaDecrypt : function (data, privateKeyData) {
		data = forge.util.decode64(data);
		privateKeyData = forge.util.decode64(privateKeyData);
		// return this.fromPrivateKeyData(privateKeyData).decrypt(data);
		return forge.util.encode64(this.fromPrivateKeyData(privateKeyData).decrypt(data));
	},

	/**
	 * 导入pkcs1&der格式私钥，
	 *
	 * @param privateKeyData pkcs1&der格式私钥，
	 */
	fromPrivateKeyData : function (privateKeyData) {
		return forge.pki.privateKeyFromAsn1(forge.asn1.fromDer(privateKeyData));
	},

    /**
     * 导出统一的pkcs1&der格式私钥，
     *
     * @param privateKeyObject forge使用的私钥对象，
     */
    toPrivateKeyData : function (privateKeyObject) {
    	return forge.asn1.toDer(forge.pki.privateKeyToAsn1(privateKeyObject)).getBytes();
	},

    /**
     * 导出统一的x509&der格式公钥，
     *
     * @param publicKeyObject forge使用的公钥对象，
     */
    toPublicKeyData : function (publicKeyObject) {
    	return forge.asn1.toDer(forge.pki.publicKeyToAsn1(publicKeyObject)).getBytes();
	}


}

var Test = {
	// 私钥
    testRSAOpen: function (privateKey, encrypted) {

        // console.log("原先加密 ： ",privateKey.decrypt(encrypted));
        //解密
        var decrypt = new JSEncrypt();
        //获取私钥
        decrypt.setPrivateKey(privateKey);
        //解钥 (公钥加密的内容)
        var uncrypted = decrypt.decryptLong2(encrypted);
        return uncrypted;
    },

}

//公钥加密
JSEncrypt.prototype.encryptLong2 = function (string) {
    var k = this.getKey();
    try {
        var lt = "";
        var ct = "";
        //RSA每次加密117bytes，需要辅助方法判断字符串截取位置
        //1.获取字符串截取点
        var bytes = new Array();
        bytes.push(0);
        var byteNo = 0;
        var len, c;
        len = string.length;
        var temp = 0;
        for (var i = 0; i < len; i++) {
            c = string.charCodeAt(i);
            if (c >= 0x010000 && c <= 0x10FFFF) {
                byteNo += 4;
            } else if (c >= 0x000800 && c <= 0x00FFFF) {
                byteNo += 3;
            } else if (c >= 0x000080 && c <= 0x0007FF) {
                byteNo += 2;
            } else {
                byteNo += 1;
            }
            if ((byteNo % 117) >= 114 || (byteNo % 117) == 0) {
                if (byteNo - temp >= 114) {
                    bytes.push(i);
                    temp = byteNo;
                }
            }
        }
        //2.截取字符串并分段加密
        if (bytes.length > 1) {
            for (var i = 0; i < bytes.length - 1; i++) {
                var str;
                if (i == 0) {
                    str = string.substring(0, bytes[i + 1] + 1);
                } else {
                    str = string.substring(bytes[i] + 1, bytes[i + 1] + 1);
                }
                var t1 = k.encrypt(str);
                ct += t1;
            }
            ;
            if (bytes[bytes.length - 1] != string.length - 1) {
                var lastStr = string.substring(bytes[bytes.length - 1] + 1);
                ct += k.encrypt(lastStr);
            }
            return hexToBytes(ct);
        }
        var t = k.encrypt(string);
        var y = hexToBytes(t);
        return y;
    } catch (ex) {
        return false;
    }
};

// 解钥
JSEncrypt.prototype.decryptLong2 = function (string) {
    var k = this.getKey();
    // var maxLength = ((k.n.bitLength()+7)>>3);
    var MAX_DECRYPT_BLOCK = 128;
    try {
        var ct = "";
        var t1;
        var bufTmp;
        var hexTmp;
        var str = bytesToHex(string);
        var buf = hexToBytes(str);
        var inputLen = buf.length;
        //开始长度
        var offSet = 0;
        //结束长度
        var endOffSet = MAX_DECRYPT_BLOCK;

        //分段加密
        while (inputLen - offSet > 0) {
            if (inputLen - offSet > MAX_DECRYPT_BLOCK) {
                bufTmp = buf.slice(offSet, endOffSet);
                hexTmp = bytesToHex(bufTmp);
                t1 = k.decrypt(hexTmp);
                ct += t1;

            } else {
                bufTmp = buf.slice(offSet, inputLen);
                hexTmp = bytesToHex(bufTmp);
                t1 = k.decrypt(hexTmp);
                ct += t1;

            }
            offSet += MAX_DECRYPT_BLOCK;
            endOffSet += MAX_DECRYPT_BLOCK;
        }
        return ct;
    } catch (ex) {
        return false;
    }
};
//十六进制转字节
function hexToBytes(hex) {
    for (var bytes = [], c = 0; c < hex.length; c += 2)
        bytes.push(parseInt(hex.substr(c, 2), 16));
    return bytes;
}

// 字节转十六进制
function bytesToHex(bytes) {
    for (var hex = [], i = 0; i < bytes.length; i++) {
        hex.push((bytes[i] >>> 4).toString(16));
        hex.push((bytes[i] & 0xF).toString(16));
    }
    return hex.join("");
}
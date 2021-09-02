var AppConfig = {

	apiUrl : "http://127.0.0.1:9000",// 接口地址
    websocketUrl:"ws://127.0.0.1:6260",//xmpp 主机的 地址
    jitsiServer:"https://meet.jit.si/",//jitsi 音视频链接地址
    uploadServer:"http://127.0.0.1:9000/",
    fileServer:"http://127.0.0.1:9000/",
    apiKey:"",
	isOpenReceipt:1,
	isOpenSMSCode:0,  //是否开短信验证码
	registerInviteCode:0, //注册邀请码  0：关闭 1:一码一用(注册型邀请码)  2：一码多用（推广型邀请码）
	regeditPhoneOrName:1,// 注册方式 0:手机号注册，1：用户名注册

}



var myData = {
	isReadDel:0,
	isAutoOpenCustomer:0,  //是否自动开启客服模式
	resource:"youjob",//多点登陆 用到的 设备标识
	jid:null,
	userId :"",
	telephone : null,
	password : null,
	access_token : null,
	loginResult : null,
	user : null,
	nickname:null,

	locateParams : null,
	keepalive:70,//xmpp 心跳间隔
	charArray : '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split(''),
	isShowGroupMsgReadNum : false,  //是否显示群组消息已读人数，false：不显示 true:显示 默认不显示
	/** 登录后请求传参 **/
	httpKey:null,
}


//日志打印
function shikuLog(obj){
	//log 打印
 	console.log("shikuLog "+obj);
}


var ivKey=[1,2,3,4,5,6,7,8];

function getStrFromBytes (arr) {
    var r = "";
    for(var i=0;i<arr.length;i++){
        r += String.fromCharCode(arr[i]);
    }
    //console.log(r);
    return r;
}
var iv=getStrFromBytes(ivKey);

var myFn = {
	invoke : function(obj) {
		jQuery.support.cors = true;
		var type="POST";
		var async=false;
		if(obj.type){
			type=obj.type;
		}
		if(obj.async){
			async=obj.async;
		}
		if(!obj.data.secret){
			// obj.data=WEBIM.createCommApiSecret(obj.data);
			// 登录加固生成secret
			obj.data=ApiAuthUtils.apiCreateCommApiSecret(obj.data,obj.url);
		}
		var params = {
			type :type,
			async:false,
			url : obj.url,
			data : obj.data,
			dataType : 'json',
			
 			success : function(result) {
				
				if(1030101==result.resultCode){
						//缺少访问令牌
						console.log("===> "+obj.url+" >> "+result.resultMsg);
						if(result.resultMsg)
							ownAlert(3,result.resultMsg);

				}else if(1030102==result.resultCode){
						//访问令牌过期
						console.log("===> "+obj.url+" >> "+result.resultMsg);
						if(result.resultMsg)
							ownAlert(3,result.resultMsg);
						setTimeout(function(){
							 window.location.href = "login.html";
						},1000);
						
				}else if(1010101==result.resultCode){
					console.log("===> "+obj.url+" >> "+result.resultMsg);
				}else if(1040307 == result.resultCode||1040308 == result.resultCode||1040309 == result.resultCode){
					
				}else if(1!=result.resultCode && myFn.notNull(result.resultMsg)){
					if(false==obj.isShowAlert){return;}
					if(result.resultMsg)
						ownAlert(3,result.resultMsg);
					if(obj.fail){
						obj.fail();
					}
					return;	
				}else if(myFn.notNull(result.resultMsg)){
					if(obj.isShowAlert)
						ownAlert(3,result.resultMsg);
				}
				obj.success(result);
			},
			error : function(result) {
				 if(false==obj.isShowAlert){return;}
				 if(result.resultMsg)
					 ownAlert(2,result.resultMsg);
				// obj.error(result);
			},
			complete : function() {
			}
		};

		params.url = AppConfig.apiUrl + params.url;
		if(myFn.isNil(params.data["access_token"])){
			params.data["access_token"] = myData.access_token;
		}
		$.ajax(params);
	},
	/** 调用接口通用方法,该方法的弹框提示等ui部分使用layui  */
	lay_invoke : function(obj){
		jQuery.support.cors = true;
		layer.load(1); //显示等待框
		var params = {
			type : (myFn.isNil(obj.type)?"POST":obj.type),
			url : obj.url,
			data : obj.data,
			contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
			dataType : 'JSON',
			success : function(result) {
				layer.closeAll('loading');
				
				if(1==result.resultCode){
					if(obj.successMsg!=false)
						layer.msg(obj.successMsg,{icon: 1});
					obj.successCb(result);//执行成功的回调函数					
				
				}else if(1030101==result.resultCode){
						//缺少访问令牌
						layer.msg(result.resultMsg,{icon: 3});
						/*setTimeout(function(){
							 window.location.href = "login.html";
						},1000);*/
						
				}else if(1030102==result.resultCode){
						//访问令牌过期
						layer.msg(result.resultMsg,{icon: 3});
						setTimeout(function(){
							 window.location.href = "login.html";
						},1000);
				
				}else if(-1==result.resultCode){
					if(result.resultMsg)
						layer.msg(result.resultMsg,{icon: 3});

				}else{
					if(!myFn.isNil(result.resultMsg))
						layer.msg(result.resultMsg,{icon: 2});
					
					//obj.errorCb(result);
				}
				return;
					
			},
			error : function(result) {
				layer.closeAll('loading');
				if(!myFn.isNil(result.resultMsg)){
					layer.msg(result.resultMsg,{icon: 2});
				}else{
					layer.msg(obj.errorMsg,{icon: 2});
				}
				obj.errorCb(result);//执行失败的回调函数
				return;
			},
			complete : function(result) {
				layer.closeAll('loading');           
			}
		}
		params.url = AppConfig.apiUrl + params.url;

		if(myFn.isNil(params.data["access_token"]) && !myFn.isNil(myData.access_token)){
			params.data["access_token"] = myData.access_token;
		}

		if(!params.data.secret){
			params.data=WEBIM.createCommApiSecret(params.data);
		}
		$.ajax(params);
	},
	getAvatarUrl : function(userId,update) {
		if(myFn.isNil(userId))
			userId=myData.userId;
		if(10000==userId)
			return "img/im_10000.png";
		var imgUrl = AppConfig.avatarBase + (parseInt(userId) % 10000) + "/" + userId + ".jpg";
		if(1==update)
			imgUrl+="?x="+Math.random()*10;
		return imgUrl;
	},
	
	/*是否为阅后即焚消息*/
	isReadDelMsg : function(msg){
		try {
			if(!msg.isReadDel){
				return false;
			}
			return ("true"==msg.isReadDel||1==msg.isReadDel);
		} catch (e) {
		 	//console.log(e.name + ": " + e.message);
		 return false;
		}
		
	},
	isContains: function(str, substr) {
    	return str.indexOf(substr) >= 0;
	},
	isNil : function(s) {
		return undefined == s ||"undefined"==s|| null == s || $.trim(s) == "" || $.trim(s) == "null"||NaN==s;
	},
	notNull : function(s) {
		return !this.isNil(s);
	},
	//截取指定长度的字符串 text:文本  length ：长度
	getText:function(text,length){
		if(myFn.isNil(text))
			return  " ";
		text = text.replace(/<br\/>/g, '');  
		if(!length)
			length=15;
		if (text.length<=length) 
			return text;
		text = text.substring(0,length)+"...";  
		    return text;
		
	},
	strToJson : function(str) {
		return eval("(" + str + ")");
	},
	setCookie:function(key,value){
		$.cookie(key,JSON.stringify(value));
	},
	getCookie:function(key){
		var value=$.cookie(key);
		return myFn.strToJson(value);
	},
	removeCookie:function(key){
		return $.removeCookie(key);
	},
	switchEncrypt:function(key){
		if(key==1){
			WEBIM.setEncrypt(true);
		}else{
			WEBIM.setEncrypt(false);
		}
		/*var isEncrypt = myData.isEncrypt;  //是否为加密  false:不是  true:是
			myData.isEncrypt=!isEncrypt;
			ownAlert(3,myData.isEncrypt);*/
			
	},
	switchCustomer:function(key){
		if(key==1){
			myData.openService=1;
		}else{
			myData.openService=0;
		}
	},
	randomUUID : function() {
		var chars = myData.charArray, uuid = new Array(36), rnd = 0, r;
		for (var i = 0; i < 36; i++) {
			if (i == 8 || i == 13 || i == 18 || i == 23) {
				uuid[i] = '-';
			} else if (i == 14) {
				uuid[i] = '4';
			} else {
				if (rnd <= 0x02)
					rnd = 0x2000000 + (Math.random() * 0x1000000) | 0;
				r = rnd & 0xf;
				rnd = rnd >> 4;
				uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
			}
		}
		return uuid.join('').replace(/-/gm, '').toLowerCase();
	},
	getTimeSecond:function(){
		return Math.round(new Date().getTime());
	},
	toDateTime : function(timestamp,isSecond) {
		if(isSecond)
			timestamp=Number(timestamp*1000);
		else
			timestamp=Number(timestamp);
		return (new Date(timestamp)).format("yyyy-MM-dd hh:mm");
	},
	toDate : function(timestamp) {
		return (new Date(Number(timestamp)) ).format("yyyy-MM-dd");
	},
	getAudioPlayer : function(passedOptions) {
		var playerpath = "/js/";

		// passable options
		var options = {
			"filepath" : "", // path to MP3 file (default: current directory)
			"backcolor" : "", // background color
			"forecolor" : "ffffff", // foreground color (buttons)
			"width" : "25", // width of player
			"repeat" : "no", // repeat mp3?
			"volume" : "50", // mp3 volume (0-100)
			"autoplay" : "false", // play immediately on page load?
			"showdownload" : "true", // show download button in player
			"showfilename" : "true" // show .mp3 filename after player
		};

		if (passedOptions) {
			jQuery.extend(options, passedOptions);
		}
		var filename = options.filepath;
		var mp3html = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ';
		mp3html += 'width="' + options.width + '" height="20" ';
		mp3html += 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab">';
		mp3html += '<param name="movie" value="' + playerpath + 'singlemp3player.swf?';
		mp3html += 'showDownload=' + options.showdownload + '&file=' + filename + '&autoStart=' + options.autoplay;
		mp3html += '&backColor=' + options.backcolor + '&frontColor=' + options.forecolor;
		mp3html += '&repeatPlay=' + options.repeat + '&songVolume=' + options.volume + '" />';
		mp3html += '<param name="wmode" value="transparent" />';
		mp3html += '<embed wmode="transparent" width="' + options.width + '" height="20" ';
		mp3html += 'src="' + playerpath + 'singlemp3player.swf?'
		mp3html += 'showDownload=' + options.showdownload + '&file=' + filename + '&autoStart=' + options.autoplay;
		mp3html += '&backColor=' + options.backcolor + '&frontColor=' + options.forecolor;
		mp3html += '&repeatPlay=' + options.repeat + '&songVolume=' + options.volume + '" ';
		mp3html += 'type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />';
		mp3html += '</object>';
		console.log(mp3html);
		return mp3html;
	},
	/**
	 * [处理消息内容，将表情字符替换为图片]
	 * @param  {[type]} content [description]
	 * @param  type   1 表示消息列表的小图  2 表示到上一级目录中去加载表情
	 *
	 */
	parseContent : function(content,type) {
		var emojlKeys = new Array();
		if(myFn.isNil(content))
			return content;
		var s = content;
		var fromIndex = 0;
		while (fromIndex != -1) {
			fromIndex = s.indexOf("[", fromIndex);
			if (fromIndex == -1)
				break;
			else {
				var stop = s.indexOf("]", fromIndex);
				if (stop == -1)
					break;
				else {
					var emojlKey = s.substring(fromIndex, stop + 1);
					emojlKeys.push(emojlKey);
					fromIndex = fromIndex + 1;
				}
			}
		}
		//表情
		if (emojlKeys.length != 0) {
			var key=null;
			var emojl=null;
			for (var i = 0; i < emojlKeys.length; i++) {
				 key = emojlKeys[i];
				 emojl=(type==2?"../"+_emojl[key]:_emojl[key]);
				 if(!myFn.isNil(emojl)){
				 	if(undefined!=type && 1==type)
				 		s = s.replace(key, "<img src='" + emojl + "' width='18' height='18' />");
				 	else
						s = s.replace(key, "<img src='" + emojl + "' width='25' height='25' />");
				 }
					
			}
			return s;
		}

		content=Utils.hrefEncode(content);
		
		return content;
		
	},
	parseFileSize : function(value){
	    if(null==value||value==''){
	        return "0 B";
	    }
	    var unitArr = new Array("B","KB","MB","GB");
	    var index=0;
	    var srcsize = parseFloat(value);
	    index=Math.floor(Math.log(srcsize)/Math.log(1024));
	    var size =srcsize/Math.pow(1024,index);
	    size=size.toFixed(2);//保留的小数位数
	    return size+unitArr[index];
	},
	getAvatar : function (){
		$("#avatarForm #avatar").click();
		// document.getElementsById["photo"].click();
	},
	getPicture : function(){
		$("#uploadFileModal #myfile").click();
	},
	getFile : function(){

	},
	deleteReadDelMsg : function(messageId){ //删除缓存未读消息中的某条阅后即焚消息
		var unReadMsg = DataMap.unReadMsg[ConversationManager.fromUserId]; //获取缓存的消息
		if(myFn.isNil(unReadMsg) || 0 == unReadMsg.length)
			return;
		for (var i = 0; i < unReadMsg.length; i++) {
			var msg = unReadMsg[i];
			if (messageId==msg.id) {
				DataMap.unReadMsg[ConversationManager.fromUserId].splice(i, 1);
			}
		}
	},
	getFilemd5sum : function (ofile,dataObj,msgFunction) {
            var file = ofile;
            var blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice,

                chunkSize = 8097152, // Read in chunks of 2MB
                chunks = Math.ceil(file.size / chunkSize),
                currentChunk = 0,
                spark = new SparkMD5.ArrayBuffer(),
                fileReader = new FileReader(),
                fileReader1 = new FileReader();


            loadNext();

            fileReader.readAsDataURL(ofile);

            fileReader.onload = function(evt) {

            	if(msgFunction)
            		msgFunction(evt);

                spark.append(evt.target.result); // Append array buffer
                currentChunk++;

                if (currentChunk < chunks) {
                    loadNext();
                } else {
                    dataObj.md5Str = spark.end();


                }
                //fileReader1.readAsDataURL(ofile);
            };


            /*fileReader.onload = function(evt) {
            	if(msgFunction)
            		msgFunction(evt);
            }*/


            function loadNext() {
                var start = currentChunk * chunkSize,
                    end = ((start + chunkSize) >= file.size) ? file.size : start + chunkSize;
                fileReader1.readAsArrayBuffer(blobSlice.call(file, start, end));
            }


    },
    getFilemd5sum_n : function (file,dataObj,msgFunction,submitFunction){

    	var fileReader = new FileReader();

    	fileReader.readAsDataURL(file);

    	fileReader.onload = function(evt) {
    		//加载UI
    		if(msgFunction)
            		msgFunction(evt);

            var format="image/jpeg";
            //抽取DataURL中的数据部分，从Base64格式转换为二进制格式
            var bin = atob(evt.target.result.split(',')[1]);
            //创建空的Uint8Array
            var buffer = new Uint8Array(bin.length);
            //将图像数据逐字节放入Uint8Array中
            for (var i = 0; i < bin.length; i++) {
                buffer[i] = bin.charCodeAt(i);
            };
            //利用Uint8Array创建Blob对象
            blob = new Blob([buffer.buffer], {type : format});
            var fileReader1 = new FileReader();
            fileReader1.readAsBinaryString(blob);
            fileReader1.onload = function(evt) {
                if (evt.target.readyState == FileReader.DONE) {
                    var imgblob = evt.target.result;
                    var sparkMD5 = new SparkMD5();
                    sparkMD5.appendBinary(imgblob);
                    dataObj.md5Str = sparkMD5.end();
                    console.log(file.name + "的MD5值是：" + dataObj.md5Str);

                    console.log("=====>>>> 执行提交");
                    if(submitFunction)
                    	submitFunction(dataObj.md5Str);
                }
            };
        };

        fileReader.onerror = function() {
                console.warn('oops, something went wrong.');
        };

    },
    checkMd5Str: function(fileNameAndMd5Str,Callback){


			//jQuery.support.cors = true;
    		$.ajax({
	            type : "POST",
	            async:false,
	            url : AppConfig.uploadServer+'upload/checkMd5',
	            dataType : 'json',
	            data : {
					fileNameAndMd5Str : JSON.stringify(fileNameAndMd5Str)
				},
	            //请求成功
	            success : function(result) {
	                console.log(result.data);
	                if (Callback)
	                	Callback(result.data);
	            },
	            //请求失败，包含具体的错误信息
	            error : function(e){
	                console.log(e.status);
	                console.log(e.responseText);
	            }
	        });



    }


};


/**
 * 
 * @param type //type : 1 成功 2:失败 3：提示 4:询问
 * @param infoText
 * @param okCallback
 * @returns
 */
function ownAlert(type,infoText,okCallback){  //自定义的弹框

	if(type==1)
		layer.msg(infoText, {icon: 1});

	if(type==2)
		layer.msg(infoText, {icon: 5});
	if(type==3)
		layui.layer.open({
		  title: false,
		  closeBtn: 0,
		  btnAlign: 'c',
		  skin: 'my-skin',
		  content: '<div style="text-align:center;">'+infoText+'</div>',
		  yes: function(index, layero){
		  	if(okCallback)
		  		okCallback();
		  	layui.layer.close(index);
		  }

		});
	if(type==4)

		layui.layer.confirm(
				'<div style="text-align:center;">'+infoText+'</div>', 
				{icon: 3, title:false, closeBtn: 0,btnAlign: 'c',skin: 'my-skin'}, 
				function(index){
				   if(okCallback)	
						 okCallback();
                   layui.layer.close(index);

			    }
		);

};


var Checkbox = {
	/*用于存储被选中的好友的userId  key:userId  value:userId 
	 用于解决checkbox翻页后上一页的选中数据无法记录的问题*/
	cheackedFriends : {}, 
	checkedNames:[],
	checkedAndCancel : function(that) {  //checkbox选中与取消选中
		// ownAlert(3,"点击选中与取消");
	    if (that.checked) {//判断是否为选中状态
	        Checkbox.checked(that);
	    } else {
	        Checkbox.cancel(that.value,that.id);
	    }
		
	},
	checked : function (that) {  //checkbox选中事件
		
		var userId=that.value;
		var showAreaId=that.id;
		if(Checkbox.cheackedFriends[userId]==userId){  //判断是否存在
			return;
		}
		Checkbox.cheackedFriends[userId] = userId; //选中后将userId 存到map中
		var nickname=$(that).attr("nickname");
		
		if(!myFn.isNil(nickname)){
			Checkbox.checkedNames[userId+"uId"]=nickname; 
			Checkbox.checkedNames.length+=1;
		}
		var imgUrl = myFn.getAvatarUrl(userId);
		var avatarHtml = "<img id='img_"+userId+"' onerror='this.src=\"img/ic_avatar.png\"'  src='" + imgUrl + "' class='roundAvatar checked_avatar' />"
		if("areadyChooseFriends"==showAreaId){
			$("#addEmployee  #"+showAreaId+"").append(avatarHtml);
		}else if ("setAdminShowArea"==showAreaId) {
			$("#setAdmin  #"+showAreaId+"").append(avatarHtml);
		}else if ("false"==showAreaId) {
			//id 为 false 则不显示已选头像 
		}else{
			$("#"+showAreaId+"").append(avatarHtml);
		}
	},
	cancel : function (userId,showAreaId) {  //checkbox取消选中事件
		delete Checkbox.cheackedFriends[userId]; //取消选中后将userId 从map中移除
		if(!myFn.isNil(Checkbox.checkedNames[userId+"uId"])){
			delete Checkbox.checkedNames[userId+"uId"];
			Checkbox.checkedNames.length-=1;
		}
		if(!myFn.isNil(showAreaId))
			$("#"+ showAreaId +" #img_"+userId+"").remove();
	},
	cleanAll:function(){
		Checkbox.cheackedFriends={};
		Checkbox.checkedNames=[];
	},
	parseData : function(){ //解析 cheackedFriends 中的数据
		if(myFn.isNil(Checkbox.cheackedFriends)){ //判断是否存在数据
			return null;
		}
		var invitees = new Array();
		for(var key in Checkbox.cheackedFriends){  //通过定义一个局部变量key遍历获取到了cheackedFriends中所有的key值  
		  
		   invitees.push(Checkbox.cheackedFriends[key]); //获取key所对应的value的值,并存入数组  
		}
		// return JSON.stringify(invitees);
		return invitees;
	}

};

var _emojl = {
	"[smile]" : "emojl/e-01.png",
	"[joy]" : "emojl/e-02.png",
	"[heart-eyes]" : "emojl/e-03.png",
	"[sweat_smile]" : "emojl/e-04.png",
	"[laughing]" : "emojl/e-05.png",
	"[wink]" : "emojl/e-06.png",
	"[yum]" : "emojl/e-07.png",
	"[relieved]" : "emojl/e-08.png",
	"[fearful]" : "emojl/e-09.png",
	"[ohYeah]" : "emojl/e-10.png",
	"[cold-sweat]" : "emojl/e-11.png",
	"[scream]" : "emojl/e-12.png",
	"[kissing_heart]" : "emojl/e-13.png",
	"[smirk]" : "emojl/e-14.png",
	"[angry]" : "emojl/e-15.png",
	"[sweat]" : "emojl/e-16.png",
	"[stuck]" : "emojl/e-17.png",
	"[rage]" : "emojl/e-18.png",
	"[etriumph]" : "emojl/e-19.png",
	"[mask]" : "emojl/e-20.png",
	"[confounded]" : "emojl/e-21.png",
	"[sunglasses]" : "emojl/e-22.png",
	"[sob]" : "emojl/e-23.png",
	"[blush]" : "emojl/e-24.png",
	"[doubt]" : "emojl/e-26.png",
	"[flushed]" : "emojl/e-27.png",
	"[sleepy]" : "emojl/e-28.png",
	"[sleeping]" : "emojl/e-29.png",
	"[disappointed_relieved]" : "emojl/e-30.png",
	"[tire]" : "emojl/e-31.png",
	"[astonished]" : "emojl/e-32.png",
	"[buttonNose]" : "emojl/e-33.png",
	"[frowning]" : "emojl/e-34.png",
	"[shutUp]" : "emojl/e-35.png",
	"[expressionless]" : "emojl/e-36.png",
	"[confused]" : "emojl/e-37.png",
	"[tired_face]" : "emojl/e-38.png",
	"[grin]" : "emojl/e-39.png",
	"[unamused]" : "emojl/e-40.png",
	"[persevere]" : "emojl/e-41.png",
	"[relaxed]" : "emojl/e-42.png",
	"[pensive]" : "emojl/e-43.png",
	"[no_mouth]" : "emojl/e-44.png",
	"[worried]" : "emojl/e-45.png",
	"[cry]" : "emojl/e-46.png",
	"[pill]" : "emojl/e-47.png",
	"[celebrate]" : "emojl/e-48.png",
	"[gift]" : "emojl/e-49.png",
	"[birthday]" : "emojl/e-50.png",
	"[paray]" : "emojl/e-51.png",
	"[ok_hand]" : "emojl/e-52.png",
	"[first]" : "emojl/e-53.png",
	"[v]" : "emojl/e-54.png",
	"[punch]" : "emojl/e-55.png",
	"[thumbsup]" : "emojl/e-56.png",
	"[thumbsdown]" : "emojl/e-57.png",
	"[muscle]" : "emojl/e-58.png",
	"[maleficeent]" : "emojl/e-59.png",
	"[broken_heart]" : "emojl/e-60.png",
	"[heart]" : "emojl/e-61.png",
	"[taxi]" : "emojl/e-62.png",
	"[eyes]" : "emojl/e-63.png",
	"[rose]" : "emojl/e-64.png",
	"[ghost]" : "emojl/e-65.png",
	"[lip]" : "emojl/e-66.png",
	"[fireworks]" : "emojl/e-67.png",
	"[balloon]" : "emojl/e-68.png",
	"[clasphands]" : "emojl/e-69.png",
	"[bye]" : "emojl/e-70.png"
};

var emojiList = [
	{"filename":"e-01","english":"smile","chinese":"微笑"},
	{"filename":"e-02","english":"joy","chinese":"快乐"},
	{"filename":"e-03","english":"heart-eyes","chinese":"色咪咪"},
	{"filename":"e-04","english":"sweat_smile","chinese":"汗"},
	{"filename":"e-05","english":"laughing","chinese":"大笑"},
	{"filename":"e-06","english":"wink","chinese":"眨眼"},
	{"filename":"e-07","english":"yum","chinese":"百胜"},
	{"filename":"e-08","english":"relieved","chinese":"放松"},
	{"filename":"e-09","english":"fearful","chinese":"可怕"},
	{"filename":"e-10","english":"ohYeah","chinese":"欧耶"},
	{"filename":"e-11","english":"cold-sweat","chinese":"冷汗"},
	{"filename":"e-12","english":"scream","chinese":"尖叫"},
	{"filename":"e-13","english":"kissing_heart","chinese":"亲亲"},
	{"filename":"e-14","english":"smirk","chinese":"得意"},
	{"filename":"e-15","english":"angry","chinese":"害怕"},
	{"filename":"e-16","english":"sweat","chinese":"沮丧"},
	{"filename":"e-17","english":"stuck","chinese":"卡住"},
	{"filename":"e-18","english":"rage","chinese":"愤怒"},
	{"filename":"e-19","english":"etriumph","chinese":"生气"},
	{"filename":"e-20","english":"mask","chinese":"面具"},
	{"filename":"e-21","english":"confounded","chinese":"羞愧"},
	{"filename":"e-22","english":"sunglasses","chinese":"太阳镜"},
	{"filename":"e-23","english":"sob","chinese":"在"},
	{"filename":"e-24","english":"blush","chinese":"脸红"},
	{"filename":"e-26","english":"doubt","chinese":"疑惑"},
	{"filename":"e-27","english":"flushed","chinese":"激动"},
	{"filename":"e-28","english":"sleepy","chinese":"休息"},
	{"filename":"e-29","english":"sleeping","chinese":"睡着"},
	{"filename":"e-30","english":"disappointed_relieved","chinese":"失望"},
	{"filename":"e-31","english":"tire","chinese":"累"},
	{"filename":"e-32","english":"astonished","chinese":"惊讶"},
	{"filename":"e-33","english":"buttonNose","chinese":"抠鼻"},
	{"filename":"e-34","english":"frowning","chinese":"皱眉头"},
	{"filename":"e-35","english":"shutUp","chinese":"闭嘴"},
	{"filename":"e-36","english":"expressionless","chinese":"面无表情"},
	{"filename":"e-37","english":"confused","chinese":"困惑"},
	{"filename":"e-38","english":"tired_face","chinese":"厌倦"},
	{"filename":"e-39","english":"grin","chinese":"露齿而笑"},
	{"filename":"e-40","english":"unamused","chinese":"非娱乐"},
	{"filename":"e-41","english":"persevere","chinese":"坚持下去"},
	{"filename":"e-42","english":"relaxed","chinese":"傻笑"},
	{"filename":"e-43","english":"pensive","chinese":"沉思"},
	{"filename":"e-44","english":"no_mouth","chinese":"无嘴"},
	{"filename":"e-45","english":"worried","chinese":"担心"},
	{"filename":"e-46","english":"cry","chinese":"哭"},
	{"filename":"e-47","english":"pill","chinese":"药"},
	{"filename":"e-48","english":"celebrate","chinese":"庆祝"},
	{"filename":"e-49","english":"gift","chinese":"礼物"},
	{"filename":"e-50","english":"birthday","chinese":"生日 "},
	{"filename":"e-51","english":"paray","chinese":"祈祷"},
	{"filename":"e-52","english":"ok_hand","chinese":"好"},
	{"filename":"e-53","english":"first","chinese":"冠军"},
	{"filename":"e-54","english":"v","chinese":"耶"},
	{"filename":"e-55","english":"punch","chinese":"拳头"},
	{"filename":"e-56","english":"thumbsup","chinese":"赞"},
	{"filename":"e-57","english":"thumbsdown","chinese":"垃圾"},
	{"filename":"e-58","english":"muscle","chinese":"肌肉"},
	{"filename":"e-59","english":"maleficeent","chinese":"鼓励"},
	{"filename":"e-60","english":"broken_heart","chinese":"心碎"},
	{"filename":"e-61","english":"heart","chinese":"心 "},
	{"filename":"e-62","english":"taxi","chinese":"出租车"},
	{"filename":"e-63","english":"eyes","chinese":"眼睛"},
	{"filename":"e-64","english":"rose","chinese":"玫瑰"},
	{"filename":"e-65","english":"ghost","chinese":"鬼"},
	{"filename":"e-66","english":"lip","chinese":"嘴唇"},
	{"filename":"e-67","english":"fireworks","chinese":"烟花"},
	{"filename":"e-68","english":"balloon","chinese":"气球"},
	{"filename":"e-69","english":"clasphands","chinese":"握手"},
	{"filename":"e-70","english":"bye","chinese":"抱拳"}
];


var gifList = [
	{"filename":"eight.gif","english":"eight"},
	{"filename":"eighteen.gif","english":"eighteen"},
	{"filename":"eleven.gif","english":"eleven"},
	{"filename":"fifity.gif","english":"fifity"},
	{"filename":"fifity_four.gif","english":"fifity_four"},
	{"filename":"fifity_one.gif","english":"fifity_one"},
	{"filename":"fifity_three.gif","english":"fifity_three"},
	{"filename":"fifity_two.gif","english":"fifity_two"},
	{"filename":"fifteen.gif","english":"fifteen"},
	{"filename":"five.gif","english":"five"},
	{"filename":"forty.gif","english":"forty"},
	{"filename":"forty_eight.gif","english":"forty_eight"},
	{"filename":"forty_five.gif","english":"forty_five"},
	{"filename":"forty_four.gif","english":"forty_four"},
	{"filename":"forty_nine.gif","english":"forty_nine"},
	{"filename":"forty_one.gif","english":"forty_one"},
	{"filename":"forty_seven.gif","english":"forty_seven"},
	{"filename":"forty_three.gif","english":"forty_three"},
	{"filename":"forty_two.gif","english":"forty_two"},
	{"filename":"fourteen.gif","english":"fourteen"},
	{"filename":"nine.gif","english":"nine"},
	{"filename":"nineteen.gif","english":"nineteen"},
	{"filename":"one.gif","english":"one"},
	{"filename":"seven.gif","english":"seven"},
	{"filename":"seventeen.gif","english":"seventeen"},
	{"filename":"sixteen.gif","english":"sixteen"},
	{"filename":"ten.gif","english":"ten"},
	{"filename":"thirteen.gif","english":"thirteen"},
	{"filename":"thirty.gif","english":"thirty"},
	{"filename":"thirty_eight.gif","english":"thirty_eight"},
	{"filename":"thirty_five@.gif","english":"thirty_five@"},
	{"filename":"thirty_four.gif","english":"thirty_four"},
	{"filename":"thirty_nine.gif","english":"thirty_nine"},
	{"filename":"thirty_seven.gif","english":"thirty_seven"},
	{"filename":"thirty_six.gif","english":"thirty_six"},
	{"filename":"thirty_three.gif","english":"thirty_three"},
	{"filename":"thirty_two.gif","english":"thirty_two"},
	{"filename":"thirty-one.gif","english":"thirty-one"},
	{"filename":"three.gif","english":"three"},
	{"filename":"twelve.gif","english":"twelve"},
	{"filename":"twenty.gif","english":"twenty"},
	{"filename":"twenty_eight.gif","english":"twenty_eight"},
	{"filename":"twenty_five.gif","english":"twenty_five"},
	{"filename":"twenty_four.gif","english":"twenty_four"},
	{"filename":"twenty_nine.gif","english":"twenty_nine"},
	{"filename":"twenty_one.gif","english":"twenty_one"},
	{"filename":"twenty_seven.gif","english":"twenty_seven"},
	{"filename":"twenty_six.gif","english":"twenty_six"},
	{"filename":"twenty_three.gif","english":"twenty_three"},
	{"filename":"twenty_two.gif","english":"twenty_two"}
];


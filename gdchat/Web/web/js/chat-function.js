//网络链接上了
function onNet(){
	//网络链接上了
	
	setTimeout(function(){
		WEBIM.loginIM(function(){
			UI.online();
		});
	},3000);
	
    	
}
//网络断开了
function offNet(){
	UI.offline();
}

//检查网络状态 和xmpp 链接状态
function checkNetAndXmppStatus(){
	shikuLog("当前网络状态 "+NetWork.online);
	if(NetWork.online){
	
	}else 
		ownAlert(3,"网络断开了,请检查网络!");
	
}

function shikuLog(obj){
	//log 打印
 	console.log("shikuLog "+obj);
}



function sleep(numberMillis) {
    var now = new Date();
    var exitTime = now.getTime() + numberMillis;
    while (true) {
        now = new Date();
        if (now.getTime() > exitTime)
            return;
    }
}

function welcome(){
	//进入页面，打开10000号系统聊天框，并显示欢迎语。
	var welcomeContent ="欢迎使用 咕喃WEB 版 (^_^)";
	var userId = 10000;
	var nickname = "系统客服";

		$("#userModal").modal('hide');
		ConversationManager.isOpen = true;
		var from=userId+"";
		ConversationManager.from = userId;
		ConversationManager.fromUserId=userId;
		var chatType = WEBIM.isGroup(userId)?WEBIM.GROUPCHAT:WEBIM.CHAT;
		
	    UI.showDetails(from,chatType,nickname);//打开系统聊天框
	    $("#detailsTab").addClass("msgMabayChange"); //让消息Tab 处于选中状态
		


		var welcomeHtml = "<div id=msg_"+userId+">"
			            +		"<div class='clearfix'>"
						+			"<div style='overflow: hidden;' >"
						+	    		"<div  class='message you'>"
						+			        "<div  class='message_system'>"
						+			        	"<div  class='content'>"+getTimeText(Date.parse(new Date()))+"</div>"
						+			        "</div>"
						+	        		"<img  class='avatar' onerror='this.src=\"img/ic_avatar.png\"' src='./img/im_10000.png'>"
						+	        		"<div class='content'>"
			            +	            	"<div class='bubble js_message_bubble bubble_default left'>"
						+	               		 "<div class='bubble_cont'>"
						+							'<div class="plain">'
						+			                     "<pre class='js_message_plain'>"+welcomeContent+"</pre>"
						+			                "</div>"
						+	               		 "</div>"
						+	            	"</div>"
						+	        	"</div>"
						+	    	"</div>"
						+		"</div>"
						+	"</div>"
			       		+"</div>";


		// 追加消息
		$("#messageContainer").append(welcomeHtml);

		// 滚动到底部
		UI.scrollToEnd();

};

   // 获取当前浏览器名 及 版本号
    function appInfo(){  
         var browser = {appname: 'unknown', version: 0,versionStr:0,},  
             userAgent = window.navigator.userAgent.toLowerCase();  // 使用navigator.userAgent来判断浏览器类型
        //msie,firefox,opera,chrome,netscape,ie 
         if ( /(msie|firefox|opera|chrome|netscape)\D+(\d[\d.]*)/.test(userAgent) ){  
            browser.appname = RegExp.$1;  
           browser.versionStr = RegExp.$2;  
        } else if ( /version\D+(\d[\d.]*).*safari/.test( userAgent ) ){ // safari  
             browser.appname = 'safari';  
             browser.versionStr = RegExp.$2;  
         }  
         shikuLog("appInfo name "+browser.appname+" version  "+browser.version);
         browser.version=browser.versionStr.split(".")[0];
         browser.version=parseInt(browser.version);
         shikuLog("appInfo  version  "+ browser.version);

         var errMsg="目前音视频只支持 Chrome 47 以下版本和Firefox 49及以下版本 请下载相应版本使用 ";
	         if("chrome"==browser.appname){
	         	if(47<browser.version){
	         		ownAlert(3,errMsg);
	         		return false;
	         	}

	         }else if("firefox"==browser.appname){
	         	if(49<browser.version){
	         		ownAlert(3,errMsg);
	         		return false;
	         	}
	         }else{
	           ownAlert(3,errMsg);
	           return false;
	       	}
       return true;  
         	
     } 
var DBUtils={

	getStreamId:function(){
		var  key ="streamId_";
		return dbStorage.getItem(key);
	},
	setStreamId:function(value){
		var  key ="streamId_";
		dbStorage.setItem(key,value);
	},
	getIsEncrypt:function(){
		var  key ="isEncrypt_";
		var value=dbStorage.getItem(key);
		if(myFn.isNil(value)){
			value=0;
		}else{
			value=Number(value);
		}
		return value;
	},
	setIsEncrypt:function(value){
		var  key ="isEncrypt_";
		dbStorage.setItem(key,value);
	},
	getLogoutTime:function(){
		var  key ="logOutTime_";
		var value=dbStorage.getItem(key);
		if(myFn.isNil(value)){
			value=0;
		}else{
			value=Number(value);
		}
		return value;
	},
	setLogoutTime:function(time){
		var  key ="logOutTime_";
		dbStorage.setItem(key,time);
	},
	/*获取好友聊天记录*/
	getMsgRecordList:function(userId){
		var key="msgRecordList_"+userId;
		var arrList=dbStorage.getItem(key);
		if(myFn.isNil(arrList))
			arrList=new Array();
		else
			arrList=JSON.parse(arrList);
		return arrList;
	},
	setMsgRecordList:function(userId,arrList){
		var key="msgRecordList_"+userId;
		dbStorage.setItem(key,JSON.stringify(arrList));
	},
	putMsgRecordList:function(userId,msgId){
		var key="msgRecordList_"+userId;
		var arrList=DBUtils.getMsgRecordList(userId);
		arrList.push(msgId);
		dbStorage.setItem(key,JSON.stringify(arrList));
	},
	clearMsgRecordList:function(userId){
		var key="msgRecordList_"+userId;
		dbStorage.removeItem(key);
	},
	getMsgNumCount:function(){
		var key="msgNumCount_"
		var num=dbStorage.getItem(key);
		if(myFn.isNil(num)){
			num=0;
		}
		num=parseInt(num);
		return num;
	},
	setMsgMumCount:function(num){
		var key="msgNumCount_"
		dbStorage.setItem(key,num);
	},
	getMsgNum:function(id){
		var key="msgNum_"+id;
		var num=dbStorage.getItem(key);
		if(myFn.isNil(num))
			num=0;
		else
			num=parseInt(num);
		return num;
	},
	setMsgNum:function(id,num){
		var key="msgNum_"+id;
		dbStorage.setItem(key,num);
	},
	/*获取最近的消息列表记录*/
	getUIMessageList:function(){
		var key="messageList_";
		var messageList=dbStorage.getItem(key);
		//shikuLog("getUIMessageList ===> "+messageList);
		if(myFn.isNil(messageList)){
			return null;
		}else{
			messageList=JSON.parse(messageList);
		}
		return messageList;
	},
	putUIMessageList:function(msg){
		var key="messageList_";
		var messageList=DBUtils.getUIMessageList();
		if(myFn.isNil(messageList)){
			messageList={};
		}
		/*var temp=messageList[msg.id];*/
		
		messageList[msg.id]=msg;
		dbStorage.setItem(key,JSON.stringify(messageList));
	},
	removeUIMessageList:function(userId){
		var key="messageList_";
		var messageList=DBUtils.getUIMessageList();
		if(myFn.isNil(messageList)){
			return ;
		}
		delete messageList[userId];

		dbStorage.setItem(key,JSON.stringify(messageList));
	},
	getLastMsg:function(userId){
		var messageList=DBUtils.getUIMessageList();
		if(myFn.isNil(messageList)){
			return null;
		}
		return messageList[userId];
	},
	getMessageKey:function(messageId){
		return "msg_"+messageId;
	},
	getMessage:function(messageId){
		var msg=dbStorage.getItem(this.getMessageKey(messageId));
		msg=JSON.parse(msg);
		return msg;
	},
	saveMessage:function(msg){
		dbStorage.setItem(this.getMessageKey(msg.messageId),JSON.stringify(msg));
	},
	deleteMessage:function(messageId){
		return dbStorage.removeItem(this.getMessageKey(messageId));
	},
	getMsgReadList:function(messageId){
		var key="msgReadList_"+messageId;
		var readList=dbStorage.getItem(key);
		if(myFn.isNil(readList)){
			readList=new Array();
		}else{
			readList=JSON.parse(readList);
		}
		return readList;
	},
	/*添加已读列表 消息对象*/
	putMsgReadList:function(messageId,msg){
		/*msg={id:"",userId:"",nickname,"",timeSend:100}*/
		var key="msgReadList_"+messageId;
		var readList=dbStorage.getItem(key);
		if(myFn.isNil(readList)){
			readList=new Array();
		}else{
			readList=JSON.parse(readList);
		}
		readList.push(msg);

		dbStorage.setItem(key,JSON.stringify(readList));
	},
	/*获取消息已读数量*/
	getMsgReadNum:function (messageId) {
		//设置已读数量
		var key="msgReadNum_"+messageId;
		var value= dbStorage.getItem(key);
		if(myFn.isNil(value))
			value=0;
		else
			value=parseInt(value);
		return value;
	},
	//更新消息已读数量
	setMsgReadNum:function (messageId,num) {
		//设置已读数量
		var key="msgReadNum_"+messageId;
		 dbStorage.setItem(key,num);
		
	},
	/*获取消息过滤状态*/
	getMsgFilters:function(id){
		var status=dbStorage.getItem(id);
		if(myFn.isNil(status))
			status="0";
		return status;
	
	},
	setMsgFilters:function(id,status){
		GroupManager.filters[id]=status;
		dbStorage.setItem(id,status);
	},
	/*
	好友阅后即焚状态
	*/
	getFriendReadDelStatus:function(userId){
		let key="friendReadDel_"+userId;
		let status=dbStorage.getItem(key);
		if(!status)
			return 0;
		return status;
	},
	setFriendReadDelStatus:function(userId,status){
		let key="friendReadDel_"+userId;
		if(1==status){
			dbStorage.setItem(key,status);
		}else{
			dbStorage.removeItem(key);
		}
		
	},
	getStr:function(key){
		return dbStorage.getItem(key);
	},
	saveStr:function(key,value){
		return dbStorage.setItem(key,value);
	},
	getObj:function(key){
		var value=dbStorage.getItem(key);
		if(isJSON(str)){
			value=JSON.parse(msg);
		}
		return value;
	},
	saveObj:function (key,obj) {
		dbStorage.setItem(key,JSON.stringify(obj));
	},
	deleteObj:function(key){
	   return dbStorage.removeItem(key);
	},
	clearAll:function(){
		dbStorage.clear();
	}
};

function isJSON(str) {
    if (typeof str == 'string') {
        try {
            var obj=JSON.parse(str);
            if(typeof obj == 'object' && obj ){
                return true;
            }else{
                return false;
            }

        } catch(e) {
            console.log('error：'+str+'!!!'+e);
            return false;
        }
    }
    console.log('It is not a string!')
}
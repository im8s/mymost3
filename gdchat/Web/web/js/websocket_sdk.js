var SKIMSDK={

    cont:"skimweb_",
    websocket:null,
    serverUrl:null,
    /*登陆成功的回调*/
    logincallBack:null,
    /*收到消息的回调*/
    messageReceiver:null,
    /*消息回执 处理方法*/
    handlerMsgReceipt:null,
    handlerLoginConflict:null,
    userIdStr:null,
    token:null,
    /*心跳间隔时间*/
    pingTime:30,
    /*最后一次传递消息的时间*/
    lastTransferTime:0,
    waitSendReceiptIds:"",
    initApi(url,userId,resource,token,pingTime,server){
        
        SKIMSDK.token=token;
        SKIMSDK.serverUrl=url;
        SKIMSDK.server=server;
        SKIMSDK.resource=SKIMSDK.resource;
        SKIMSDK.userIdStr=userId+"/"+resource;
        SKIMSDK.pingTime=pingTime;
        SKIMSDK.server=server;
         /*SKIMSDK.messageReceiver=messageReceiver;
        SKIMSDK.handlerMsgReceipt=handlerMsgReceipt;
        SKIMSDK.handlerLoginConflict=handlerLoginConflict;*/
    },
    loginIM:function(callback){
          try {
            if(callback)
                SKIMSDK.logincallBack=callback;

             SKIMSDK.websocket = new WebSocket(SKIMSDK.serverUrl);
             
             SKIMSDK.websocket.onopen=SKIMSDK.onopen;
             SKIMSDK.websocket.onmessage=SKIMSDK.onmessage;
             SKIMSDK.websocket.onerror=SKIMSDK.onerror;
             SKIMSDK.websocket.onclose=SKIMSDK.onclose;
             SKIMSDK.websocket.binaryType = "arraybuffer";
            
        } catch (e) {
          console.log(e.message);
        }
         
    },
    loginSuccess:function(message){
        if(SKIMSDK.logincallBack)
                SKIMSDK.logincallBack(message);
        if(SKIMSDK.userIdStr==message.from){
            clearInterval(SKIMSDK.ping);
            //XmppSdk.ping=null
            SKIMSDK.pingTime=SKIMSDK.pingTime*1000;
            SKIMSDK.ping = window.setInterval(function(){
                SKIMSDK.sendPing();
            },SKIMSDK.pingTime); 
        }else{
            /*其他设备登陆*/
        }

        
    },
    onopen:function(e){
         console.log("onopen  ===> "+e);
         var message=SKIMSDK.buildAuthMessage();

        var buffer=SKIMSDK.encodeMessage(message,Command.COMMAND_AUTH_REQ);
        
       SKIMSDK.sendBytes(buffer);
    },
    /*收到服务器消息*/
    onmessage:function(e){
        var dataArr = new Uint8Array(e.data) ; 
        var cmd=dataArr[0];
        if(cmd>127){
            cmd=cmd-256;
        }
        SKIMSDK.lastTransferTime=SKIMSDK.getCurrentSeconds();
        console.log("onmessage  cmd ===> "+cmd);
        if(0==cmd)
            return;
        var bytes= dataArr.subarray(1,dataArr.length);
        var message=SKIMSDK.decodeMessage(bytes,cmd);
       /*var dataStr=JSON.stringify(message);*/
      
       message=SKIMSDK.convertToClientMsg(message);
       
       SKIMSDK.handlerMessageBycmd(cmd,message); 
    },
    disconnect:function(e){
        clearInterval(SKIMSDK.ping);
        SKIMSDK.websocket.close();
    },
    isConnect:function(){
        if(!SKIMSDK.websocket)
            return false;
        return 1==SKIMSDK.websocket.readyState;
    },
    sendPing:function(){
         if(!SKIMSDK.isConnect())
            return;
        /*var currTime=SKIMSDK.getCurrentSeconds();
        if((currTime-SKIMSDK.pingTime)<SKIMSDK.lastTransferTime){
            //最后通讯时间相近 不需要发送心跳包
            //console.log("最后通讯时间相近 不需要发送心跳包");
            return ;
        }*/

        //console.log("发送心跳包");
        var message=SKIMSDK.buildPingMessage();
        var buffer=SKIMSDK.encodeMessage(message,Command.Ping_REQ);
        SKIMSDK.sendBytes(buffer);
    },
    onerror:function(e){
        console.log("onerror ====> "+e);
        SKIMSDK.loginIM();
    },
    onclose:function(e){
        console.log("onclose ====> "+e);
        
    },
    handlerMessageBycmd(cmd,message){
        /*发送客户端消息回执*/
        if(ChatType.CHAT==message.chatType&&85<message.type&&94>message.type){
            return;
        }else if(ChatType.GROUPCHAT==message.chatType&&SKIMSDK.userIdStr==message.fromJid){
           SKIMSDK.handlerMsgReceipt(message.messageId);
        }

        switch (cmd){
            case Command.COMMAND_CHAT:
                SKIMSDK.sendReceipt(message.messageId);
                SKIMSDK.messageReceiver(message);
                break;
            case Command.SUCCESS:
                SKIMSDK.handlerMsgReceipt(message.messageId);
                break;
            case Command.MESSAGE_RECEIPT:
                SKIMSDK.handlerMsgReceipt(message.messageId);
                break;
            case Command.PULL_BATCH_GROUP_MESSAGE_RESP:
                SKIMSDK.handlerGroupMessageResult(message);
                break;
            case Command.PULL_MESSAGE_RECORD_RESP:
                SKIMSDK.handlerHistoryMessageResult(message);
                break;
            case Command.COMMAND_AUTH_RESP:
                SKIMSDK.loginSuccess(message);
                break;
            case Command.Login_Conflict:
                SKIMSDK.handlerLoginConflict();
                break;
           
            default://默认 其他
                content="";
                break ;

        }
    },
   /* handlerMsgReceipt(message){

    },*/

    /*
    发送消息 api  
    */
    sendMessage:function(msg,cmd){
        if(!cmd)
            cmd=Command.COMMAND_CHAT;
        var head=SKIMSDK.buildMessageHead(msg.to,msg.chatType);
        if(msg.messageId)
            head.messageId=msg.messageId;
        msg.messageHead=head;
        if(msg.timeLen)
            msg.fileTime=msg.timeLen;
        //delete msg["to"];
        var buffer=SKIMSDK.encodeMessage(msg,cmd);
       SKIMSDK.sendBytes(buffer);
    },
    sendBytes:function(bytes){
     if(!SKIMSDK.isConnect()) 
           sleep(1000);
        //console.log("sendBytes  ===>  "+bytes);
        SKIMSDK.websocket.send(bytes);
        
    },
    sendReceipt:function(messageId){
        SKIMSDK.waitSendReceiptIds+=(messageId+",");
        if(!SKIMSDK.sendReceiptTask){
            SKIMSDK.sendReceiptTask=window.setInterval(function(){
                if(""==SKIMSDK.waitSendReceiptIds)
                    return;
                 var receipt=SKIMSDK.buildReceiptMessage(SKIMSDK.waitSendReceiptIds,1,SKIMSDK.server);
                 var buffer=SKIMSDK.encodeMessage(receipt,Command.MESSAGE_RECEIPT);
                 SKIMSDK.sendBytes(buffer);
                 //console.log("sendReceipt ===> "+JSON.stringify(receipt))
                SKIMSDK.waitSendReceiptIds="";
            },3000); 
        }
       
    },
    /*转换为 客户端的 消息*/
    convertToClientMsg:function(msg){
      msg=JSON.parse(JSON.stringify(msg)) ;
        var message=msg;
        if(msg.messageHead){
            if(ChatType.GROUPCHAT==msg.messageHead.chatType){
                message.from=msg.messageHead.to;
                message.to=SKIMSDK.userIdStr;
                message.fromJid=msg.messageHead.from;
            }else{
                message.from=msg.messageHead.from;
                message.to=msg.messageHead.to;
            }
         message.messageId=msg.messageHead.messageId;
         message.chatType=msg.messageHead.chatType;
         message.offline=msg.messageHead.offline;
         message.timeLen=message.fileTime;
         if(message.locationX){
             message.location_x=message.locationX;
              delete message["locationX"];
         }
        if(message.locationY){
            message.location_y=message.locationY;
             delete message["locationY"];
         }
             
         delete message["messageHead"];
         delete message["fileTime"];

        }else{
            message.messageId=msg.messageId;
            message.chatType=msg.chatType;
        }
           
       /* var dataStr=JSON.stringify(message);
        console.log("convertToClientMsg end  ===> "+dataStr);*/
        return message;
       
    },
    buildChatMessage:function(){

    },
    /*创建消息头*/
    buildMessageHead:function(to,chatType){

        var head = {
                from:SKIMSDK.userIdStr,
                messageId:SKIMSDK.randomUUID(),
                chatType:!chatType?0:chatType,
                to:!to?"":(to+""),
            };
        return head;
    },
    buildAuthMessage:function(){
        var head=SKIMSDK.buildMessageHead("server",ChatType.AUTH);
        var message={
            messageHead:head,
            token:SKIMSDK.token,
        }
        return message;
    },
    buildPingMessage:function(){
        var head=SKIMSDK.buildMessageHead("server",ChatType.PING);
        var message={
            messageHead:head,
         }
        return message;
    },
    buildReceiptMessage:function(messageId,chatType,to){
        var head=SKIMSDK.buildMessageHead(to,chatType);
        var message={
            messageHead:head,
            messageId:messageId,
            status:2,
         }
        return message;
    },
    /*加入群组*/
    joinGroupChat(jid,seconds){
        var head=SKIMSDK.buildMessageHead("server",ChatType.CHAT);
        var message={
            messageHead:head,
            jid:jid,
            seconds:seconds,
        }
        var buffer=SKIMSDK.encodeMessage(message,Command.JOINGROUP_REQ);
        SKIMSDK.sendBytes(buffer);
    },
    exitGroupChat(jid){
        var head=SKIMSDK.buildMessageHead("server",ChatType.CHAT);
        var message={
            messageHead:head,
            jid:jid,
        }
        var buffer=SKIMSDK.encodeMessage(message,Command.EXITGROUP_REQ);
        SKIMSDK.sendBytes(buffer);
    },
    /*批量请求 群组消息数量*/
    pullBatchGroupMessage:function(jidList){
       var head=SKIMSDK.buildMessageHead("server",ChatType.CHAT);
        var message={
            messageHead:head,
            jidList:jidList,
            endTime:SKIMSDK.getCurrentSeconds()
        }
        var buffer=SKIMSDK.encodeMessage(message,Command.PULL_BATCH_GROUP_MESSAGE_REQ);
        SKIMSDK.sendBytes(buffer);
       
    },
    /*请求漫游聊天记录*/
    pullHistoryMessage:function(chatType,jid,size,startTime,endTime){
        var head=SKIMSDK.buildMessageHead("server",chatType);

        var message={
            messageHead:head,
            jid:jid,
            size:size,
            startTime:startTime,
            endTime:endTime
        }
        var buffer=SKIMSDK.encodeMessage(message,Command.PULL_MESSAGE_RECORD_REQ);
         SKIMSDK.sendBytes(buffer);
    },
    /*解码*/
    decodeMessage:function(buffer,cmd,messageType){
        
        var message =null;
        if(cmd){
          if(!messageType)
            messageType=SKIMSDK.getProtoMessageType(cmd);
            message=messageType.decode(buffer);
        }else{
            message= messageType.decode(buffer);
        }

        return message;
    },
    /*编码*/
    encodeMessage:function(jsonMsg,cmd,messageType){
        if(!messageType)
            messageType=SKIMSDK.getProtoMessageType(cmd);

        var errMsg = messageType.verify(jsonMsg);
        if (errMsg){
            throw Error(errMsg);
        }
         var message = messageType.create(jsonMsg);

        var buffer = messageType.encode(message).finish();
        //console.log("encodeMessage cmd   > "+cmd);
        if(cmd){
            var bytes =new Uint8Array(buffer.length+1);
             bytes[0]=cmd;
            for (var i = 0; i < buffer.length; i++) {
                bytes[i+1]=buffer[i];
            }
            return bytes;
        }else{
            return buffer;
        }
    },
    /*根据 cmd 获取 proto 的编解码 MessageType */
    getProtoMessageType:function(cmd){
        var messageType=null;
         switch (cmd){
            case Command.COMMAND_CHAT:
                messageType=ProtoMessageType.chatMessage;
              break;
            case Command.COMMAND_AUTH_REQ:
                messageType=ProtoMessageType.authMessageReq;
              break;
            case Command.COMMAND_AUTH_RESP:
                messageType=ProtoMessageType.authMessageResp;
              break;
            case Command.MESSAGE_RECEIPT:
                messageType=ProtoMessageType.messageReceipt;
              break;
            case Command.PULL_MESSAGE_RECORD_REQ:
                messageType=ProtoMessageType.pullMessageHistoryRecordReq;
              break;
            case Command.PULL_MESSAGE_RECORD_RESP:
                messageType=ProtoMessageType.pullMessageHistoryRecordResp;
              break;
            case Command.PULL_BATCH_GROUP_MESSAGE_REQ:
                messageType=ProtoMessageType.pullBatchGroupMessageReq;
              break;
             case Command.PULL_BATCH_GROUP_MESSAGE_RESP:
                messageType=ProtoMessageType.pullBatchGroupMessageResp;
              break;
            case Command.SUCCESS:
                messageType=ProtoMessageType.commonSuccess;
              break;
            case Command.ERROR:
                messageType=ProtoMessageType.commonError;
              break;
            case Command.Ping_REQ:
                messageType=ProtoMessageType.pingMessage;
              break;
            case Command.JOINGROUP_REQ:
                messageType=ProtoMessageType.joinGroupMessage;
              break;
            case Command.EXITGROUP_REQ:
                messageType=ProtoMessageType.exitGroupMessage;
              break;
            case Command.GROUP_REQUEST_RESULT:
                messageType=ProtoMessageType.groupMessageResp;
              break;
            case Command.Login_Conflict:
                 messageType= ProtoMessageType.commonError;
              break;
           
            default://默认 其他
               
                break ;

            }

        return messageType;
    },
    getUserIdFromJid:function (jid){
        jid+="";
        return jid ? jid.split("/")[0] : "";
    },
    getBareJid: function (jid){
        jid+="";
        return jid ? jid.split("/")[0] : "";
    },
    getResource : function(jid) {
        if(myFn.isNil(jid))
            return "";
        jid+="";
        var resource = jid.substr(jid.indexOf("/")+1, jid.length);
        return resource;
    },
    /*是否为群组 Jid*/
    isGroup : function(userId) {
        var reg = /^[0-9]*$/;
        if(!reg.test(userId))
            return true;
        else
            return false;
    },
    randomUUID : function() {
        return SKIMSDK.cont+SKIMSDK.getCurrentSeconds()+Math.round(Math.random()*1000);
    },
    getCurrentSeconds:function(){
        return Math.round(new Date().getTime());
    },
       
}

var Command={
    /*握手请求，含http的websocket握手请求*/
    COMMAND_HANDSHAKE_REQ:1,
    /*握手响应，含http的websocket握手响应*/
    COMMAND_HANDSHAKE_RESP:2,
    /*登录消息请求*/
    COMMAND_AUTH_REQ:5,
    /*登录消息结果*/
    COMMAND_AUTH_RESP:6,
    /*关闭请求*/
    COMMAND_CLOSE:7,
    /*聊天请求*/
    COMMAND_CHAT:10,
    /*消息回执*/
    MESSAGE_RECEIPT:11,
    /*拉取 聊天历史记录 */
    PULL_MESSAGE_RECORD_REQ:12,
    /*拉取 聊天历史记录 结果*/
    PULL_MESSAGE_RECORD_RESP:13,
    /*批量拉取群组消息数量  请求*/
    PULL_BATCH_GROUP_MESSAGE_REQ:14,
    /*批量拉取群组消息数量  结果*/
    PULL_BATCH_GROUP_MESSAGE_RESP:15,
    /*失败错误*/
    ERROR:-1,
    /*登陆 被挤下线*/
    Login_Conflict:-3,
    /*加入群组*/
    JOINGROUP_REQ:20,
    /*退出群组*/
    EXITGROUP_REQ:21,
    /*群组请求结果协议*/
    GROUP_REQUEST_RESULT:22,
    /*心跳消息*/
    Ping_REQ:99,
    /*成功请求*/
    SUCCESS:100,
  }
 var ProtoMessageType={
    messageHead:null,
    chatMessage:null,
    authMessageReq:null,
    authMessageResp:null,
    messageReceipt:null,
    joinGroupMessage:null,
    exitGroupMessage:null,
    groupMessageResp:null,
    pullMessageHistoryRecordReq:null,
    pullMessageHistoryRecordResp:null,
    pullBatchGroupMessageReq:null,
    pullBatchGroupMessageResp:null,
    pingMessage:null,
    commonSuccess:null,
    commonError:null,
   
  };

  protobuf.load("proto/message.proto",function (err,root) {
    if(err)
        throw err;
   ProtoMessageType.messageHead=root.lookupType("Message.MessageHead");

   ProtoMessageType.chatMessage=root.lookupType("Message.ChatMessage");

   ProtoMessageType.authMessageReq=root.lookupType("Message.AuthMessage");

   ProtoMessageType.authMessageResp=root.lookupType("Message.AuthRespMessageProBuf");

    ProtoMessageType.messageReceipt=root.lookupType("Message.MessageReceiptStatusProBuf");

    ProtoMessageType.joinGroupMessage=root.lookupType("Message.JoinGroupMessageProBuf");

    ProtoMessageType.exitGroupMessage=root.lookupType("Message.ExitGroupMessageProBuf");

    ProtoMessageType.groupMessageResp=root.lookupType("Message.GroupMessageRespProBuf");

    ProtoMessageType.pullMessageHistoryRecordReq=root.lookupType("Message.PullMessageHistoryRecordReqProBuf");
    
    ProtoMessageType.pullMessageHistoryRecordResp=root.lookupType("Message.PullMessageHistoryRecordRespProBuf");
    
    ProtoMessageType.pullBatchGroupMessageReq=root.lookupType("Message.PullBatchGroupMessageReqProBuf");

    ProtoMessageType.pullBatchGroupMessageResp=root.lookupType("Message.PullGroupMessageRespProBuf");
    
    ProtoMessageType.pingMessage=root.lookupType("Message.PingMessageProBuf");

    ProtoMessageType.commonSuccess=root.lookupType("Message.CommonSuccessProBuf");
    
    ProtoMessageType.commonError=root.lookupType("Message.CommonErrorProBuf");

});
var ChatType={
     UNKNOW:0,
    /**
     * 单聊
     */
    CHAT:1,
    /**
     * 群聊
     */
    GROUPCHAT:2,
    /**
     * 广播
     */
    ALL:3,

    /*授权*/
    AUTH:5,
    
    /**
     *心跳消息
     */
    PING:9,
    /**
     * 返回结果
     */
    RESULT:10,
    /**
     * 消息回执
     */
    RECEIPT:11,
}


   

/*var ClientMessage={
    from:null,
    to:null,
    messageId,
    buildFromNetMsg:function(msg){

    },
}*/
  

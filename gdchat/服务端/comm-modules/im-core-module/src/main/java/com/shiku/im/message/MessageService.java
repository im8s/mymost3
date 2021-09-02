package com.shiku.im.message;

import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.config.MQConfig;
import com.shiku.im.model.PressureParam;
import com.shiku.im.support.Callback;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.StringUtil;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.client.producer.SendStatus;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Repository;

import javax.annotation.Resource;
import java.util.List;

@Repository
public abstract class MessageService implements IMessageService{

    @Resource
    @Lazy
    private RocketMQTemplate rocketMQTemplate;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());


    @Autowired(required=false)
    @Lazy
    private MQConfig mqConfig;

    //private UserCoreService userCoreService;


    public abstract void setTimeSend(com.shiku.im.comm.model.MessageBean messageBean);


    @Override
    public void publishMessageToMQ(String topic, String message) {

        try {
            if(StringUtil.isEmpty(topic)){
                logger.warn(" topic is null {} ",message);
                return;
            }
            SendResult result = rocketMQTemplate.syncSend(topic, message);
            if(SendStatus.SEND_OK!=result.getSendStatus()){
                logger.warn("发送失败   {}",result.toString());
            }else{
               logger.info("发送成功  {}",result.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 发送单聊消息
     * @param messageBean
     */
    public void send(com.shiku.im.comm.model.MessageBean messageBean){
        setTimeSend(messageBean);

        if(StringUtil.isEmpty(messageBean.getMessageId())){
            messageBean.setMessageId(StringUtil.randomUUID());
        }

        try {
            SendResult result = rocketMQTemplate.syncSend("xmppMessage", messageBean.toString());
            if(SendStatus.SEND_OK!=result.getSendStatus()){
                System.out.println("发送失败   "+result.toString());
            }else{
                //System.out.println("发送成功  "+result.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * 发送单聊消息
     * @param messageBean
     * @param userIdList
     */
    public void send(com.shiku.im.comm.model.MessageBean messageBean, List<Integer> userIdList){
        setTimeSend(messageBean);
        if(StringUtil.isEmpty(messageBean.getMessageId())){
            messageBean.setMessageId(StringUtil.randomUUID());
        }

        for(Integer i:userIdList){
            messageBean.setToUserId(i.toString());

            //messageBean.setToUserName(userCoreService.getNickName(i));
            messageBean.setMsgType(0);// 单聊消息
            send(messageBean);
        }
    }

    /**
     * 发送 消息 到 群组中
     * @param messageBean
     * @param roomJidArr
     */
    public void sendMsgToMucRoom(MessageBean messageBean, String... roomJidArr){
        setTimeSend(messageBean);

        if(StringUtil.isEmpty(messageBean.getMessageId())){
            messageBean.setMessageId(StringUtil.randomUUID());
        }
        for (String jid : roomJidArr) {
            try {
                messageBean.setMsgType(1);
                messageBean.setRoomJid(jid);
                SendResult result = rocketMQTemplate.syncSend("xmppMessage",messageBean.toString());
                if(SendStatus.SEND_OK!=result.getSendStatus()){
                    System.out.println(result.toString());
                }else{

                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

    }


    /** @Description:（群控制消息）
     * @param jid
     * @param messageBean
     * @throws Exception
     **/
    public void sendMsgToGroupByJid(String jid, MessageBean messageBean){
        setTimeSend(messageBean);
        ThreadUtils.executeInThread(new Callback() {

            @Override
            public void execute(Object obj) {
                sendMsgToMucRoom(messageBean, jid);
            }
        });
    }

    public void sendManyMsgToGroupByJid(String jid,List<MessageBean> messageList) {
        try {
            for(MessageBean messageBean : messageList){
                setTimeSend(messageBean);
                sendMsgToMucRoom(messageBean, jid);
            }
        }catch (Exception e) {
            e.printStackTrace();
        }

    }

    public void send(List<Integer> userIdList, List<MessageBean> messageList)  {

        ThreadUtils.executeInThread(new Callback() {

            @Override
            public void execute(Object obj) {

                try {

                    for (MessageBean messageBean : messageList) {
                        for (int userId : userIdList) {
                            setTimeSend(messageBean);
                            messageBean.setMsgType(0);// 单聊消息
                            if(messageBean.getToUserId().equals(String.valueOf(userId))){

                                send(messageBean);
                            }
                        }
                    }
                } catch (Exception e1) {
                    e1.printStackTrace();
                    System.out.println("发送推送失败!" );
                }
            }
        });
    }
    //发送消息验证
    public void pushAuthLoginDeviceMessage(Integer userId,String strKey){
        try {
            MessageBean messageBean = new MessageBean();
            //信息编号
            messageBean.setType(MessageType.AUTHLOGINDEVICE);
            //信息接受方
            messageBean.setTo(userId.toString());
            //信息推送方
            messageBean.setFromUserId(userId.toString());
            //信息推送方名称
            messageBean.setFromUserName("localhost");
            //信息类型
            messageBean.setMsgType(0);
            //推送的信息
            messageBean.setContent(strKey);
            //信息编号
            messageBean.setMessageId(StringUtil.randomUUID());
            //发送消息
            send(messageBean);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

   public abstract void createMucRoomToIMServer(String roomJid,String password,String userId, String roomName);
   public abstract void deleteTigaseUser(Integer userId);

   public abstract JSONMessage pressureMucTest(PressureParam param, Integer userId);
}

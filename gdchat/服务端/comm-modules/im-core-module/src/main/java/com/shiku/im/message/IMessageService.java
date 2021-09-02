package com.shiku.im.message;

import com.shiku.im.comm.model.MessageBean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public interface IMessageService  {



    void send(MessageBean messageBean);

    void publishMessageToMQ(String topic,String message);
}

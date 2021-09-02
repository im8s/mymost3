package com.sk.weichat.socket.protocol;

import com.alibaba.fastjson.JSONObject;
import com.google.protobuf.Descriptors.Descriptor;
import com.google.protobuf.DynamicMessage;
import com.google.protobuf.util.JsonFormat;
import com.sk.weichat.socket.msg.AbstractMessage;
import com.sk.weichat.socket.msg.MessageHead;

public class ProBufUtils {

    public static <T> T decoderMessageBody(byte[] bytes, Descriptor descriptor, Class<T> classz) {
        T message = null;
        try {
            DynamicMessage parseFrom = DynamicMessage.parseFrom(descriptor, bytes);
            String msgStr = JsonFormat.printer().print(parseFrom);
            message = JSONObject.parseObject(msgStr, classz);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return message;
    }

    public static <T extends AbstractMessage> byte[] encodeMessageBody(T message, Descriptor descriptor) {

        try {
            DynamicMessage.Builder builder = DynamicMessage.newBuilder(descriptor);
            String msg = message.toString();
            JsonFormat.parser().merge(msg, builder);
            byte[] bytes = builder.build().toByteArray();
            return bytes;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

//    public static byte[] encodeMessageBody(AuthMessage message, Descriptor descriptor) {
//
//        try {
//            byte[] bytes = null;
//            DynamicMessage.Builder builder = DynamicMessage.newBuilder(descriptor);
//            String msg = message.toString();
//            JsonFormat.parser().merge(msg, builder);
//            bytes = builder.build().toByteArray();
//            return bytes;
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return null;
//    }

    public static <T> MessageProBuf.MessageHead encodeProBufMessageHead(MessageHead messageHead) {
        MessageProBuf.MessageHead result = null;

        try {
            DynamicMessage.Builder builder = DynamicMessage.newBuilder(MessageProBuf.MessageHead.getDescriptor());
            JsonFormat.parser().merge(messageHead.toString(), builder);
            result = MessageProBuf.MessageHead.parseFrom(builder.build().toByteArray());

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}

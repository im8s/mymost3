/**
 *
 */
package com.sk.weichat.socket.protocol;

import java.nio.ByteBuffer;

/**
 * 版本: [1.0]
 * 功能说明:
 *
 * @author : WChao 创建时间: 2017年8月21日 下午3:08:04
 */
public class TcpServerDecoder {

//	private static Logger logger = LoggerFactory.getLogger(TcpServerDecoder.class);

    public static TcpPacket decode(ByteBuffer buffer) {
        //校验协议头
        if (!isHeaderLength(buffer)) {
            return null;
        }
        //获取第一个字节协议版本号;
        byte version = buffer.get();
        if (version != Protocol.VERSION) {
            return null;
//			throw new AioDecodeException(ImStatus.C10013.getText());
        }
        //标志位
        byte maskByte = buffer.get();
        Integer synSeq = 0;
        //同步发送;
        if (ImPacket.decodeHasSynSeq(maskByte)) {
            synSeq = buffer.getInt();
        }
        //cmd命令码
        short cmdByte = buffer.getShort();
		/*if(Command.forNumber(cmdByte) == null){
			throw new AioDecodeException(ImStatus.C10014.getText());
		}*/
        int bodyLen = buffer.getInt();
        //数据不正确，则抛出AioDecodeException异常
        if (bodyLen < 0) {
            return null;
        }
        int readableLength = buffer.limit() - buffer.position();
        int validateBodyLen = readableLength - bodyLen;
        // 不够消息体长度(剩下的buffer组不了消息体)
        if (validateBodyLen < 0) {
            return null;
        }
        byte[] body = new byte[bodyLen];
        buffer.get(body, 0, bodyLen);


        //byteBuffer的总长度是 = 2byte协议版本号+1byte消息标志位+4byte同步序列号(如果是同步发送则多4byte同步序列号,否则无4byte序列号)+1byte命令码+4byte消息的长度+消息体的长度
        TcpPacket tcpPacket = new TcpPacket(cmdByte, body);
        tcpPacket.setVersion(version);
        tcpPacket.setMask(maskByte);
        //同步发送设置同步序列号
        if (synSeq > 0) {
            tcpPacket.setSynSeq(synSeq);
        }
        return tcpPacket;
    }

    /**
     * 判断是否符合协议头长度
     *
     * @param buffer
     * @return
     */
    private static boolean isHeaderLength(ByteBuffer buffer) {
        int readableLength = buffer.limit() - buffer.position();
        if (readableLength == 0) {
            return false;
        }
        //协议头索引;
        int index = buffer.position();
        try {
            //获取第一个字节协议版本号;
            buffer.get(index);
            index++;
            //标志位
            byte maskByte = buffer.get(index);
            //同步发送;
            if (ImPacket.decodeHasSynSeq(maskByte)) {
                index += 4;
            }
            index++;
            //cmd命令码, 此处为Short两个字节, 原代码为Byte一个字节, 有误，
            buffer.getShort(index);
            index += 2;
            //消息体长度
            int bodyLen = buffer.getInt(index);
            index += 4;
            int leftLength = buffer.limit() - index;
            if (leftLength < bodyLen) {
                // 剩下的长度不够这个包的内容，
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}

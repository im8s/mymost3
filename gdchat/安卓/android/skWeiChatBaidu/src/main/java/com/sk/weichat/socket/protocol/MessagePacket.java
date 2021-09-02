package com.sk.weichat.socket.protocol;

/**
 * 消息 包 body
 *
 * @author lidaye
 */
public class MessagePacket extends TcpPacket {

    /**
     *
     */
    private static final long serialVersionUID = 1L;

    public MessagePacket() {
        // TODO Auto-generated constructor stub
    }

    public MessagePacket(byte[] bytes) {
        this.bytes = bytes;
    }

}

package com.sk.weichat.socket.protocol;

/**
 * @author WChao
 */
public abstract class ImPacket extends Packet {
    private static final long serialVersionUID = 2000118564569232098L;

    /**
     * 消息体;
     */
    protected byte[] bytes;
    /**
     * 消息命令;
     */
    private short command;

    public ImPacket() {
    }

    public ImPacket(byte[] bytes) {
        this.bytes = bytes;
    }


    public ImPacket(short command, byte[] body) {
        this(body);
        this.setCommand(command);
    }

    public ImPacket(short command) {
        this(command, null);
    }

    public static byte encodeEncrypt(byte bs, boolean isEncrypt) {
        if (isEncrypt) {
            return (byte) (bs | Protocol.FIRST_BYTE_MASK_ENCRYPT);
        } else {
            return (byte) (Protocol.FIRST_BYTE_MASK_ENCRYPT & 0b01111111);
        }
    }

    //public abstract void release() ;

    public static boolean decodeCompress(byte version) {
        return (Protocol.FIRST_BYTE_MASK_COMPRESS & version) != 0;
    }

    public static byte encodeCompress(byte bs, boolean isCompress) {
        if (isCompress) {
            return (byte) (bs | Protocol.FIRST_BYTE_MASK_COMPRESS);
        } else {
            return (byte) (bs & (Protocol.FIRST_BYTE_MASK_COMPRESS ^ 0b01111111));
        }
    }

    public static boolean decodeHasSynSeq(byte maskByte) {
        return (Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ & maskByte) != 0;
    }

    public static byte encodeHasSynSeq(byte bs, boolean hasSynSeq) {
        if (hasSynSeq) {
            return (byte) (bs | Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ);
        } else {
            return (byte) (bs & (Protocol.FIRST_BYTE_MASK_HAS_SYNSEQ ^ 0b01111111));
        }
    }

    public static boolean decode4ByteLength(byte version) {
        return (Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH & version) != 0;
    }

    public static byte encode4ByteLength(byte bs, boolean is4ByteLength) {
        if (is4ByteLength) {
            return (byte) (bs | Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH);
        } else {
            return (byte) (bs & (Protocol.FIRST_BYTE_MASK_4_BYTE_LENGTH ^ 0b01111111));
        }
    }

    public static byte decodeVersion(byte version) {
        return (byte) (Protocol.FIRST_BYTE_MASK_VERSION & version);
    }

    /*释放message的body*/
    public void releaseMessageBody() {
        setBytes(null);
    }

    /**
     * 计算消息头占用了多少字节数
     *
     * @return 2017年1月31日 下午5:32:26
     */
    public int calcHeaderLength(boolean is4byteLength) {
        int ret = Protocol.LEAST_HEADER_LENGHT;
        if (is4byteLength) {
            ret += 2;
        }
        if (this.getSynSeq() > 0) {
            ret += 4;
        }
        return ret;
    }

    public short getCommand() {
        return command;
    }

    public void setCommand(short type) {
        this.command = type;
    }

    /**
     * @return the body
     */
    public byte[] getBytes() {
        return bytes;
    }

    /**
     * @param bytes
     */
    public void setBytes(byte[] bytes) {
        this.bytes = bytes;
    }

}

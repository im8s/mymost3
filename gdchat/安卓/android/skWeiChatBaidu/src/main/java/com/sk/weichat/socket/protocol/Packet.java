package com.sk.weichat.socket.protocol;

import android.util.Log;

import java.io.Serializable;
import java.nio.ByteBuffer;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicLong;

/**
 * @author tanyaowu
 * 2017年4月1日 上午9:34:59
 */
public class Packet implements Serializable, Cloneable {

    private static final long serialVersionUID = 5275372187150637318L;

    private static final AtomicLong ID_ATOMICLONG = new AtomicLong();

    private Long id = ID_ATOMICLONG.incrementAndGet();

    private int byteCount = 0;

    private Long respId = null;

    private PacketListener packetListener;

    private boolean isBlockSend = false;

    private Meta meta = null;

    /**
     * 消息是否是另外一台机器通过topic转过来的，如果是就不要死循环地再一次转发啦
     * 这个属性是tio内部使用，业务层的用户请勿使用
     */
    private boolean isFromCluster = false;

    /**
     * 同步发送时，需要的同步序列号
     */
    private Integer synSeq = 0;

    /**
     * 预编码过的bytebuffer，如果此值不为null，框架则会忽略原来的encode()而直接用此值
     */
    private ByteBuffer preEncodedByteBuffer = null;

    /**
     * 是否已经进行ssl加密过
     */
    private boolean isSslEncrypted = false;

    @Override
    public Packet clone() {
        try {
            Packet ret = (Packet) super.clone();
            ret.setPreEncodedByteBuffer(null);
            ret.setSslEncrypted(false);
            return ret;
        } catch (CloneNotSupportedException e) {
            Log.e("xuan", "CloneNotSupportedException: " + e);
            return null;
        }
    }

    /**
     * @return the byteCount
     */
    public int getByteCount() {
        return byteCount;
    }

    /**
     * @param byteCount the byteCount to set
     */
    public void setByteCount(int byteCount) {
        this.byteCount = byteCount;
    }

    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * @return the packetListener
     */
    public PacketListener getPacketListener() {
        return packetListener;
    }

    /**
     * @param packetListener the packetListener to set
     */
    public void setPacketListener(PacketListener packetListener) {
        this.packetListener = packetListener;
    }

    /**
     * @return the preEncodedByteBuffer
     */
    public ByteBuffer getPreEncodedByteBuffer() {
        return preEncodedByteBuffer;
    }

    /**
     * @param preEncodedByteBuffer the preEncodedByteBuffer to set
     */
    public void setPreEncodedByteBuffer(ByteBuffer preEncodedByteBuffer) {
        this.preEncodedByteBuffer = preEncodedByteBuffer;
    }

    /**
     * @return the respId
     */
    public Long getRespId() {
        return respId;
    }

    /**
     * @param respId the respId to set
     */
    public void setRespId(Long respId) {
        this.respId = respId;
    }

    /**
     * @return the synSeq
     */
    public Integer getSynSeq() {
        return synSeq;
    }

    /**
     * @param synSeq the synSeq to set
     */
    public void setSynSeq(Integer synSeq) {
        this.synSeq = synSeq;
    }

    /**
     * @return the isBlockSend
     */
    public boolean isBlockSend() {
        return isBlockSend;
    }

    /**
     * @param isBlockSend the isBlockSend to set
     */
    public void setBlockSend(boolean isBlockSend) {
        this.isBlockSend = isBlockSend;
    }

    public String logstr() {
        return "";
    }

    public boolean isFromCluster() {
        return isFromCluster;
    }

    public void setFromCluster(boolean isFromCluster) {
        this.isFromCluster = isFromCluster;
    }

    public boolean isSslEncrypted() {
        return isSslEncrypted;
    }

    public void setSslEncrypted(boolean isSslEncrypted) {
        this.isSslEncrypted = isSslEncrypted;
    }

    public Meta getMeta() {
        return meta;
    }

    public void setMeta(Meta meta) {
        this.meta = meta;
    }

    public static class Meta {
        private Boolean isSentSuccess = false;
        private CountDownLatch countDownLatch = null;

        public Boolean getIsSentSuccess() {
            return isSentSuccess;
        }

        public void setIsSentSuccess(Boolean isSentSuccess) {
            this.isSentSuccess = isSentSuccess;
        }

        public CountDownLatch getCountDownLatch() {
            return countDownLatch;
        }

        public void setCountDownLatch(CountDownLatch countDownLatch) {
            this.countDownLatch = countDownLatch;
        }
    }
}

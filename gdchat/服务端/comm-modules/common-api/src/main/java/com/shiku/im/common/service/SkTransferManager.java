package com.shiku.im.common.service;

public interface SkTransferManager {


    /**
     * 转账超时未领取 退回余额
     */
    void autoRefreshTransfer();


    String queryTransferOverGroupCount(long startTime, long endTime);


}

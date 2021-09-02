package com.shiku.im.common.service;

import java.util.Map;

/**
 * @Description: TODO （红包操作接口 功能）
 *
 * @Date 2019/12/2
 **/
public interface RedPacketsManager {

    public Object getRedPacketList(String userName, int pageIndex, int pageSize, String redPacketId);

    public Object receiveWater(String redId, int pageIndex, int pageSize);

    public Object getRedPackListTimeOut(long outTime, int status);

    public void updateRedPackListTimeOut(long outTime, int status, Map<String, Object> map);


    public void autoRefreshRedPackect();


    public String queryRedpackOverGroupCount(long startTime, long endTime);

}

package com.shiku.im.msg.service;

public interface MsgListManager {
    Object getHotList(int cityId, int pageIndex, int pageSize);

    Object getLatestList(int cityId, int pageIndex, int pageSize);

    String getHotId(int cityId, Object userId);

    String getLatestId(int cityId, Object userId);
}

package com.shiku.im.msg.service.impl;
import com.alibaba.fastjson.JSON;
import com.shiku.im.comm.constants.KKeyConstant;
import com.shiku.im.msg.service.MsgListManager;
import com.shiku.im.utils.SKBeanUtils;
import org.springframework.stereotype.Service;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/7 10:05
 */
@Service
public class MsgListManagerImpl implements MsgListManager {

    @Override
    public String getHotId(int cityId, Object userId) {
        return null;
    }

    @Override
    public Object getHotList(int cityId, int pageIndex, int pageSize) {
        String key = String.format(KKeyConstant.HotMsgListTemplate, cityId);
        String hget = SKBeanUtils.getRedisCRUD().hget(key, String.valueOf(pageIndex));
        return JSON.parse(hget);
    }

    @Override
    public String getLatestId(int cityId, Object userId) {
        String key = String.format(KKeyConstant.UserLatestMsgIdTemplate, cityId);

        return SKBeanUtils.getRedisCRUD().hget(key, String.valueOf(userId));

    }

    @Override
    public Object getLatestList(int cityId, int pageIndex, int pageSize) {
        String key = String.format(KKeyConstant.LatestMsgListTemplate, cityId);
        String hget = SKBeanUtils.getRedisCRUD().hget(key, String.valueOf(pageIndex));
        return JSON.parse(hget);
    }
}

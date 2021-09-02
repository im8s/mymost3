package com.shiku.im.user.utils;

import cn.hutool.core.util.RandomUtil;
import com.shiku.im.comm.constants.KConstants;
import lombok.experimental.UtilityClass;

/**
 * @Date: 2021/7/20 10:49
 */
@UtilityClass
public class UserUtil {
    /**
     * 获取通讯号
     */
    public String getAccountNo(Integer userId) {
        String random = RandomUtil.randomInt(1000, 9999) + "";
        return userId < KConstants.MIN_USERID ? userId + random : (userId - KConstants.MIN_USERID) + random;
    }
}

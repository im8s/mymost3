package com.shiku.im.utils;

import cn.hutool.core.collection.CollectionUtil;
import lombok.experimental.UtilityClass;
import org.apache.commons.lang3.StringUtils;

import java.util.Collection;

@UtilityClass
public class IPUtil {
    /**
     * 自定义ip命中检测器
     *
     * 规则：相等或通配符匹配
     * 注：ips中的值支持通配符*，如192.168.*
     */
    public boolean hitIp(String ip, Collection<String> ips) {
        if (StringUtils.isBlank(ip) || CollectionUtil.isEmpty(ips)) {
            return false;
        }
        for (String cIp : ips) {
            if ("*".equals(cIp)) {
                return true;
            }
            if (ip.equals(cIp)) {
                return true;
            }
            if (cIp.contains("*")) {
                if (ip.startsWith(cIp.substring(0, cIp.indexOf("*")))) {
                    return true;
                }
            }
        }
        return false;
    }
}

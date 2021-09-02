package com.shiku.im.api.utils;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpUtil;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.apache.commons.lang3.StringUtils;

/**
 * @author csf
 */
public class IpLocationUtil {
    private static final String TB_API = "https://ip.taobao.com/outGetIpInfo?ip={}&accessKey=alibaba-inc";

    public static String getIpLocation(String ip) {
        StringBuilder location = new StringBuilder();
        if (StringUtils.isBlank(ip)) {
            return location.toString();
        }
        try{
            String url = StrUtil.format(TB_API, ip);
            String result = HttpUtil.get(url);
            JSONObject resultJson = JSON.parseObject(result);
            if (resultJson.getInteger("code").equals(0)) {
                Object data = resultJson.get("data");
                JSONObject dataJson = (JSONObject) JSON.toJSON(data);
                location.append(dataJson.getString("country"));
                location.append(dataJson.getString("region"));
                location.append(dataJson.getString("city"));
            }
        }catch (Exception e) {
            e.printStackTrace();
        }
        return location.toString();
    }
}

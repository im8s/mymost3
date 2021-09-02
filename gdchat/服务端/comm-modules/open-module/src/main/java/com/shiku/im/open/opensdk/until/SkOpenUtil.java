package com.shiku.im.open.opensdk.until;

import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.utils.DateUtil;
import com.shiku.utils.Md5Util;

public class SkOpenUtil {
	
	public static String getAppId(){
		final String sk = "im";
		return sk + NumberUtil.get16UUID();
	}
	
	// 暂定这样
	public static String getAppScrect(String appId){
		return Md5Util.md5Hex(appId+ DateUtil.currentTimeSeconds());
	}

}

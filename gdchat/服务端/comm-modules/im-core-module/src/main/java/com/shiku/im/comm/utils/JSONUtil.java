package com.shiku.im.comm.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.SerializeConfig;
import com.shiku.im.support.jackson.ObjectIdSerializer;
import org.bson.types.ObjectId;

public class JSONUtil {

	private static final SerializeConfig serializeConfig;
	static {
		serializeConfig = new SerializeConfig();
		serializeConfig.put(ObjectId.class, new ObjectIdSerializer());
	}

	public static String toJSONString(Object obj) {
		return JSON.toJSONString(obj, serializeConfig);
	}

}

package com.shiku.im.api.utils;

import com.alibaba.fastjson.serializer.SerializeConfig;
import org.bson.types.ObjectId;

/**
 */
public class FastjsonSerializeConfig {

    public static SerializeConfig SERIALIZE_CONFIG = SerializeConfig.getGlobalInstance();

    static {
        SERIALIZE_CONFIG.put(ObjectId.class , FastjsonObjectIdSerializer.instance);
    }
}

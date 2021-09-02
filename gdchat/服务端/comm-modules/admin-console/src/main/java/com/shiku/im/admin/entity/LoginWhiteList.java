package com.shiku.im.admin.entity;

import lombok.Data;
import lombok.experimental.Accessors;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Accessors(chain = true)
public class LoginWhiteList {
    /**
     * 类型(0-PC端,1-管理后台)
     */
    Integer type;
    String ip;
    String typeDesc;

    public String getTypeDesc() {
        return null != type ? (0 == type ? "PC端" : "管理后台"): typeDesc;
    }
}

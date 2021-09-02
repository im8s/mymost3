package com.shiku.im.friends.entity;

import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(value = "friendsterWebsite")
@Data
public class FriendsterWebsite {
    private @Id
    ObjectId id;

    //图标url
    private String icon;

    //链接(网站orApp)
    private String url;

    //itunes地址
    private String itunes;

    //标题
    private String title;

    //广告类型(0-app,1-网站)
    private int type;

    //时间
    private long time;
}

package com.shiku.im.open.dao;

import com.shiku.im.open.opensdk.entity.OpenLoginInfo;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface OpenLoginInfoDao extends IMongoDAO<OpenLoginInfo, ObjectId> {

    void addOpenLoginInfo(OpenLoginInfo openLoginInfo);

    OpenLoginInfo getOpenLoginInfo(int userId);
}

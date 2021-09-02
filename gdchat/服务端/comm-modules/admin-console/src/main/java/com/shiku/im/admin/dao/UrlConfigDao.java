package com.shiku.im.admin.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.UrlConfig;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface UrlConfigDao extends IMongoDAO<UrlConfig, ObjectId> {

    UrlConfig addUrlConfig(UrlConfig urlConfig);

    PageResult<UrlConfig> getUrlConfigList(ObjectId id, String type);

    void updateUrlConfig(ObjectId id, Map<String, Object> map);

    void deleteUrlConfig(ObjectId id);

    UrlConfig getUrlConfig(String area);
}

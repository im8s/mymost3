package com.shiku.im.admin.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.CenterConfig;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface CenterConfigDao extends IMongoDAO<CenterConfig, ObjectId> {

    CenterConfig addCenterConfig(CenterConfig centerConfig);

    void updateCenterConfig(ObjectId id, Map<String,Object> map);

    PageResult<CenterConfig> getCenterConfig(String type, ObjectId id);

    void deleteCenterConfig(ObjectId id);

    CenterConfig getCenterConfig(String clientA, String clientB);
}

package com.shiku.im.admin.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.AreaConfig;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface AreaConfigDao extends IMongoDAO<AreaConfig, ObjectId> {

    void addAreaConfig(AreaConfig areaConfig);

    PageResult<AreaConfig> getAreaConfigList(String area, int pageIndex, int pageSize);

    void updateAreaConfig(ObjectId id, Map<String,Object> map);

    void deleteAreaConfig(ObjectId id);
}

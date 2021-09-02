package com.shiku.im.admin.dao;

import com.shiku.im.admin.entity.TotalConfig;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface TotalConfigDao extends IMongoDAO<TotalConfig, ObjectId> {

    void addTotalConfig(TotalConfig totalConfig);

    void updateTotalConfig(ObjectId id, Map<String, Object> map);
}

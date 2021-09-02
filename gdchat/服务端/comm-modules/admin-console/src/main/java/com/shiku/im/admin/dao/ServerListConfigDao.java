package com.shiku.im.admin.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.ServerListConfig;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface ServerListConfigDao extends IMongoDAO<ServerListConfig, ObjectId> {

    void addServerList(ServerListConfig serverListConfig);

    PageResult<ServerListConfig> getServerList(ObjectId id, int pageIndex, int pageSize);

    PageResult<ServerListConfig> getServerListByArea(String area);

    void updateServer(ObjectId id, Map<String, Object> map);

    void deleteServer(ObjectId id);
}

package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.ServerListConfigDao;
import com.shiku.im.admin.entity.ServerListConfig;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 15:14
 */
@Repository
public class ServerListConfigDaoImpl extends MongoRepository<ServerListConfig, ObjectId> implements ServerListConfigDao {

    @Override
    public Class<ServerListConfig> getEntityClass() {
        return ServerListConfig.class;
    }

    @Override
    public PageResult<ServerListConfig> getServerList(ObjectId id, int pageIndex, int pageSize) {
        Query query=createQuery();
        if(id!=null)
            addToQuery(query,"_id",id);

        PageResult<ServerListConfig> result=new PageResult<>();
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }

    @Override
    public PageResult<ServerListConfig> getServerListByArea(String area) {
        Query query=createQuery();
       addToQuery(query,"area",area);
        PageResult<ServerListConfig> result=new PageResult<>();
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }

    @Override
    public void addServerList(ServerListConfig serverListConfig) {
        getDatastore().save(serverListConfig);
    }

    @Override
    public void updateServer(ObjectId id, Map<String, Object> map) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void deleteServer(ObjectId id) {
       deleteById(id);
    }
}

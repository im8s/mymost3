package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.UrlConfigDao;
import com.shiku.im.admin.entity.UrlConfig;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 15:43
 */
@Repository
public class UrlConfigDaoImpl extends MongoRepository<UrlConfig, ObjectId> implements UrlConfigDao {


    @Override
    public Class<UrlConfig> getEntityClass() {
        return UrlConfig.class;
    }

    @Override
    public UrlConfig addUrlConfig(UrlConfig urlConfig) {
        UrlConfig data = getDatastore().save(urlConfig);
        return data;
    }

    @Override
    public PageResult<UrlConfig> getUrlConfigList(ObjectId id, String type) {
        Query query=createQuery();
        if(id!=null){
            addToQuery(query,"_id",id);
        }else if(!StringUtil.isEmpty(type)){
            addToQuery(query,"type",type);
        }
        PageResult<UrlConfig> result=new PageResult<>();
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }

    @Override
    public void updateUrlConfig(ObjectId id, Map<String, Object> map) {
        Query query =createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void deleteUrlConfig(ObjectId id) {
       deleteById(id);
    }

    @Override
    public UrlConfig getUrlConfig(String area) {
        Query query=createQuery("area",area);
        return findOne(query);
    }
}

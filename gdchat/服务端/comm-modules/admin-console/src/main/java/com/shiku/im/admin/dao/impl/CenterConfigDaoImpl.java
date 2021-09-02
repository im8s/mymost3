package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.CenterConfigDao;
import com.shiku.im.admin.entity.CenterConfig;
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
 * @date 2019/9/3 15:52
 */
@Repository
public class CenterConfigDaoImpl extends MongoRepository<CenterConfig, ObjectId> implements CenterConfigDao {
  

    @Override
    public Class<CenterConfig> getEntityClass() {
        return CenterConfig.class;
    }

    @Override
    public CenterConfig addCenterConfig(CenterConfig centerConfig) {
        return getDatastore().save(centerConfig);
    }

    @Override
    public void updateCenterConfig(ObjectId id, Map<String, Object> map) {
        Query query = createQuery("_id",id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });

       update(query,ops);
    }

    @Override
    public PageResult<CenterConfig> getCenterConfig(String type, ObjectId id) {
        Query query=createQuery();
        if(!StringUtil.isEmpty(type))
          addToQuery(query,"type",type);
        if(id!=null){
           addToQuery(query,"_id",id);
        }
        PageResult<CenterConfig> result=new PageResult<>();
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }

    @Override
    public void deleteCenterConfig(ObjectId id) {
       deleteById(id);
    }

    @Override
    public CenterConfig getCenterConfig(String clientA, String clientB) {
        Query query=createQuery("clientA", clientA);
        addToQuery(query,"clientB", clientB);

        return findOne(query);
    }
}

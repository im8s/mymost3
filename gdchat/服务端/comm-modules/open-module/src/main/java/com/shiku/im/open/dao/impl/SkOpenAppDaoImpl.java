package com.shiku.im.open.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.open.dao.SkOpenAppDao;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/2 17:44
 */
@Repository
public class SkOpenAppDaoImpl extends MongoRepository<SkOpenApp, ObjectId> implements SkOpenAppDao {


    @Override
    public Class<SkOpenApp> getEntityClass() {
        return SkOpenApp.class;
    }

    @Override
    public void addSkOpenApp(SkOpenApp skOpenApp) {
        getDatastore().save(skOpenApp);
    }

    @Override
    public SkOpenApp getSkOpenApp(ObjectId id) {
        return get(id);
    }

    @Override
    public SkOpenApp getSkOpenApp(String appId) {
        return findOne("appId",appId);
    }

    @Override
    public SkOpenApp getSkOpenApp(String appName, byte appType) {
       Query query = createQuery();
        if(!StringUtil.isEmpty(appName)){
           addToQuery(query,"appName",appName);
        }
       addToQuery(query,"appType",appType);
        return findOne(query);
    }

    @Override
    public PageResult<SkOpenApp> getSkOpenAppList(int status, int type, int pageIndex, int limit, String keyword) {
       Query query=createQuery("appType",type);
        if(status==0){
            addToQuery(query,"status",status);
        }
        if(!StringUtil.isEmpty(keyword)){
            query.addCriteria(contains("appName", keyword));
        }
        PageResult<SkOpenApp> result=new PageResult<SkOpenApp>();
        result.setCount(count(query));
        result.setData(queryListsByQuery(query,pageIndex,limit,1));

        return result;
    }

    @Override
    public void deleteSkOpenApp(ObjectId id, String accountId) {
       Query query = createQuery(id);
       addToQuery(query,"accountId",accountId);
        deleteByQuery(query);
    }

    @Override
    public List<SkOpenApp> getSkOpenAppList(String accountId, int appType, int pageIndex, int pageSize) {
       Query query=createQuery("accountId",accountId);
       addToQuery(query,"appType",appType);
        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public void updateSkOpenApp(ObjectId id,String accountId, Map<String, Object> map) {
       Query query = createQuery(id);
        if(!StringUtil.isEmpty(accountId))
			addToQuery(query,"accountId",accountId);
        Update ops =createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    public SkOpenApp findByAppIdAndSecret(String appId,String secret){
        Query query=createQuery("appId",appId);
        addToQuery(query,"appSecret",secret);
        return findOne(query);
    }
}

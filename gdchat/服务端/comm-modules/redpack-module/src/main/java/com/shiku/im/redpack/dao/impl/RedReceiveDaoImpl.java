package com.shiku.im.redpack.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.redpack.dao.RedReceiveDao;
import com.shiku.im.redpack.entity.RedReceive;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/2 10:14
 */
@Repository
public class RedReceiveDaoImpl extends BaseMongoRepository<RedReceive, ObjectId> implements RedReceiveDao {

    @Override
    public Class<RedReceive> getEntityClass() {
        return RedReceive.class;
    }

    @Override
    public Object addRedReceiveResult(RedReceive redReceive) {
        return getDatastore().save(redReceive).getId();
    }

    @Override
    public void addRedReceive(RedReceive redReceive) {
        getDatastore().save(redReceive);
    }

    @Override
    public void updateRedReceive(ObjectId redPacketId,int userId, Map<String, Object> map) {
        Query query = createQuery("userId",userId);

       addToQuery(query,"redId", redPacketId);
        Update ops =createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
       update(query,ops);
    }

    @Override
    public List<RedReceive> getRedReceiveList(ObjectId redPacketId) {
        return (List<RedReceive>) getEntityListsByKey(getEntityClass(), "redId", redPacketId,"-time");
    }

    @Override
    public List<RedReceive> getRedReceiveList(int userId, int pageIndex, int pageSize) {
        return (List<RedReceive>) getEntityListsByKey(getEntityClass(), "userId", userId, "time",1, pageIndex, pageSize);
    }

    /**
     * 排序
     * @param clazz
     * @param key
     * @param value
     * @param sortKey
     * @param sort 1：降序 0：升序
     * @param pageIndex
     * @param pageSize
     * @return
     */
    public List<?> getEntityListsByKey(Class<?> clazz,String key,Object value,String sortKey,int sort,int pageIndex,int pageSize) { Query query =new Query(Criteria.where(key).is(value));
        if(!StringUtil.isEmpty(sortKey)){
            if(1 == sort){
                query.with(Sort.by(Sort.Order.desc(sortKey)));
            }else{
                query.with(Sort.by(Sort.Order.asc(sortKey)));
            }
        }
        query.with(PageRequest.of(pageIndex,pageSize));
        return getDatastore().find(query,clazz);
    }

    @Override
    public PageResult<RedReceive> getRedReceivePageResult(ObjectId redId, int pageIndex, int pageSize) {
        PageResult<RedReceive> result = new PageResult<RedReceive>();
        Query query=createQuery("redId",redId);
        query.with(Sort.by(Sort.Order.desc("time")));
        query.with(createPageRequest(pageIndex,pageSize));
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }


}

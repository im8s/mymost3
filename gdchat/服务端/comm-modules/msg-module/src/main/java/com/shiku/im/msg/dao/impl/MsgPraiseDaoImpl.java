package com.shiku.im.msg.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.dao.MsgPraiseDao;
import com.shiku.im.msg.entity.Collect;
import com.shiku.im.msg.entity.Praise;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/6 16:29
 */
@Repository
public class MsgPraiseDaoImpl extends MongoRepository<Praise, ObjectId> implements MsgPraiseDao {
   
    @Override
    public Class<Praise> getEntityClass() {
        return Praise.class;
    }

    private final String s_praise = "s_praise";

    @Autowired
    MsgRedisRepository msgRedisRepository;



    @Override
    public void add(Praise praise) {
        getDatastore().save(praise);
    }





    /* (non-Javadoc)
     *
     */
    @SuppressWarnings("deprecation")
    @Override
    public List<Praise> find(ObjectId msgId, ObjectId praiseId, int pageIndex, int pageSize) {
        Query query=createQuery();
        if(null != praiseId)
            addToQuery(query,"praiseId",praiseId);
        else{
            addToQuery(query,"msgId",msgId);
            // 倒序查询  正序返回
			/*Collections.sort(praiseList,new Comparator<Praise>() {

				@Override
				public int compare(Praise o1, Praise o2) {
					if (o1.getTime() > o2.getTime()) {
						return 1;
					}else if(o1.getTime() == o2.getTime()){
						return 0;
					}
					return -1;
				}
			});*/
        }

        descByquery(query,"time");
        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public List<ObjectId> getPraiseIds(Integer userId){
        Query query=createQuery("userId", userId);
         List<ObjectId> msgIds =getDatastore().findDistinct(query,"msgId",Praise.class,ObjectId.class);
        return msgIds;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean exists(int userId, ObjectId msgId) {
        Query query = createQuery("userId", userId);
        addToQuery(query,"msgId",msgId);
        return exists(query);
    }


    @Override
    public void update(int userId, Map<String, Object> map) {
        Query query = createQuery("userId", userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public Praise getPraise(int userId, ObjectId msgId) {
        Query query = createQuery("userId", userId);
        addToQuery(query,"msgId",msgId);
        return findOne(query);
    }

    @Override
    public void deletePraise(int userId, ObjectId msgId) {
        Query query = createQuery("userId", userId);
        addToQuery(query,"msgId",msgId);
       deleteByQuery(query);
    }

    @Override
    public boolean existsCollect(int userId, ObjectId msgId) {
        Query query = createQuery("userId", userId);
        addToQuery(query,"msgId",msgId);
        return getDatastore().exists(query,Collect.class);
    }

    @Override
    public PageResult<Praise> praiseListMsg(ObjectId msgId, Integer page, Integer limit) {
        page = page - 1;
        PageResult<Praise> result = new PageResult<Praise>();
        Query query=createQuery("msgId", msgId);
		/*if(null == query)
			throw new ServiceException("Comment is null, msgId:"+msgId);*/
        result.setCount(count(query));
        result.setData(queryListsByQuery(query,page,limit));
        return result;
    }
}

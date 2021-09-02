package com.shiku.im.user.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.entity.UserStatusCount;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/4 9:57
 */
@Repository
public class UserStatusCountDaoImpl extends MongoRepository<UserStatusCount, ObjectId> implements UserStatusCountDao {


    @Override
    public Class<UserStatusCount> getEntityClass() {
        return UserStatusCount.class;
    }

    @Override
    public void addUserStatusCount(UserStatusCount userStatusCount) {
        getDatastore().save(userStatusCount);
    }

    @Override
    public UserStatusCount getUserStatusCount(long startTime, long endTime, int type) {
        Query query= createQuery("type",type);
        query.addCriteria(Criteria.where("time").gte(startTime).lt(endTime));
        descByquery(query,"count");
        return findOne(query);
    }
}

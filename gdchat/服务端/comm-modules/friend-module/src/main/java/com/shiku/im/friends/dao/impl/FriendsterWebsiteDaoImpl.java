package com.shiku.im.friends.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.friends.dao.FriendsterWebsiteDao;
import com.shiku.im.friends.entity.FriendsterWebsite;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class FriendsterWebsiteDaoImpl extends MongoRepository<FriendsterWebsite, ObjectId> implements FriendsterWebsiteDao {


    @Override
    public Class<FriendsterWebsite> getEntityClass() {
        return FriendsterWebsite.class;
    }

    @Override
    public FriendsterWebsite saveFriendsterWebsite(FriendsterWebsite entity) {
        entity.setId(new ObjectId());
        entity.setTime(DateUtil.getSysCurrentTimeMillis_sync());
        save(entity);
        return entity;
    }

    @Override
    public List<FriendsterWebsite> getFriendsterWebsiteList() {
        Query query = createQuery();
        query.with(Sort.by(Sort.Order.desc("time")));
        return queryListsByQuery(query);
    }

    @Override
    public PageResult<FriendsterWebsite> queryFriendsterWebsiteList(int pageIndex, int pageSize) {
        PageResult<FriendsterWebsite> result=new PageResult<>();
        Query query= createQuery();
        query.with(Sort.by(Sort.Order.desc("time")));
        result.setCount(count(query));
        result.setData(queryListsByQuery(query, pageIndex - 1, pageSize));
        return result;
    }

    @Override
    public FriendsterWebsite getFriendsterWebsite(String id) {
        Query q = createQuery("_id", new ObjectId(id));
        return findOne(q);
    }
}

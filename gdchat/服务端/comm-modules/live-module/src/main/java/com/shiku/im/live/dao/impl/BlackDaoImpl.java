package com.shiku.im.live.dao.impl;
import com.shiku.im.live.dao.BlackDao;
import com.shiku.im.live.entity.Black;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;


@Repository
public class BlackDaoImpl extends MongoRepository<Black, ObjectId> implements BlackDao {


    @Override
    public Class<Black> getEntityClass() {
        return Black.class;
    }

    @Override
    public void addBlack(Black entity) {
        getDatastore().save(entity);
    }

    @Override
    public Black getBlack(ObjectId roomId, int userId) {
        Query query = createQuery();
        if(null != roomId){
           addToQuery(query,"roomId",roomId);
        }
        if(0 != userId){
            addToQuery(query,"userId",userId);
        }
       return findOne(query);
    }

    @Override
    public void deleteBlack(ObjectId roomId) {
        Query query=createQuery("roomId",roomId);
        deleteByQuery(query);
    }
}


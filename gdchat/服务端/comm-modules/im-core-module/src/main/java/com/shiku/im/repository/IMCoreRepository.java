package com.shiku.im.repository;

import com.shiku.im.entity.ClientConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.PayConfig;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

@Repository
public class IMCoreRepository extends MongoRepository<Object,Integer>{

    @Override
    public Class<Object> getEntityClass() {
        return null;
    }

    public Config getConfig() {
        Query query=createQuery();
        query.addCriteria(Criteria.where("_id").ne(null));
        return getDatastore().findOne(query,Config.class);
    }

    public void setConfig(Config config) {

         saveEntity(config);
    }

    public void setClientConfig(ClientConfig config) {

        saveEntity(config);
    }

    public ClientConfig getClientConfig() {
        Query query=createQuery();
        query.addCriteria(Criteria.where("_id").is(10000));
        return getDatastore().findOne(query,ClientConfig.class);
    }

    public void setPayConfig(PayConfig payConfig){
        saveEntity(payConfig);
    }

    public PayConfig getPayConfig(){
        Query query = createQuery();
        query.addCriteria(Criteria.where("_id").is(10000));
        return getDatastore().findOne(query,PayConfig.class);
    }
}

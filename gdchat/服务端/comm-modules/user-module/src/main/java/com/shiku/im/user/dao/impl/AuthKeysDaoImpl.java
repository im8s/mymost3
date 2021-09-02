package com.shiku.im.user.dao.impl;

import com.mongodb.client.MongoCursor;
import com.shiku.common.core.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.AuthKeysDao;
import com.shiku.im.user.entity.AuthKeys;
import org.bson.Document;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 9:41
 */
@Repository
public class AuthKeysDaoImpl extends MongoRepository<AuthKeys,Integer> implements AuthKeysDao {

    @Override
    public Class<AuthKeys> getEntityClass() {
        return AuthKeys.class;
    }

    @Override
    public List<AuthKeys> getYopNotNull() {
        Query query = createQuery();
        query.addCriteria(Criteria.where("walletUserNo").ne(null));
        return queryListsByQuery(query);
    }

    @Override
    public void addAuthKeys(AuthKeys authKeys) {
        getDatastore().save(authKeys);
    }

    @Override
    public AuthKeys getAuthKeys(int userId) {
        return get(userId);
    }

    @Override
    public AuthKeys queryAuthKeys(int userId) {
        Query query=createQuery("_id",userId);
        query.fields().exclude("dhMsgKeyList");
        return findOne(query);
    }

    @Override
    public boolean updateAuthKeys(int userId, Map<String, Object> map) {
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        return updateAttributeByOps(userId, ops);
    }

    @Override
    public Object queryOneFieldByIdResult(String key, int userId) {
        return queryOneFieldById(key, userId);
    }

    @Override
    public Map<String, String> queryUseRSAPublicKeyList(List<Integer> userList) {
        Document query=new Document();
        query.append("_id",new Document(MongoOperator.IN,userList));

        Document fields=new Document("_id",1).append("msgRsaKeyPair",1);
       /* Query query=createQuery();
        query.addCriteria(Criteria.where("_id").in(userList));
        query.fields().include("_id").include("msgRsaKeyPair");*/
        Map<String,String> result=new HashMap<>();

        try (MongoCursor<Document> iterator = mongoTemplate.getCollection(getCollectionName(getEntityClass())).find(query).projection(fields).iterator()) {
            while (iterator.hasNext()){
                Document next = iterator.next();
                Document msgRsaKeyPair= (Document) next.get("msgRsaKeyPair");
                if(null==msgRsaKeyPair)
                    continue;
                result.put(String.valueOf(next.getInteger("_id")),msgRsaKeyPair.getString("publicKey"));
            }
        }
        return result;
    }

    @Override
    public void deleteAuthKeys(int userId) {
        Query query = createQuery("_id",userId);
        deleteByQuery(query);
    }
}

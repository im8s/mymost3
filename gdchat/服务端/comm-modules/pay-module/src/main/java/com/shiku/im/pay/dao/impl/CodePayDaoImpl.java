package com.shiku.im.pay.dao.impl;

import com.mongodb.BasicDBObject;
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.MongoCollection;
import com.shiku.im.pay.dao.CodePayDao;
import com.shiku.im.pay.entity.CodePay;
import com.shiku.im.repository.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.Iterator;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/5 17:30
 */
@Repository
public class CodePayDaoImpl extends MongoRepository<CodePay, ObjectId> implements CodePayDao {



    @Override
    public Class<CodePay> getEntityClass() {
        return CodePay.class;
    }

    @Override
    public void addCodePay(CodePay codePay) {
        getDatastore().save(codePay);
    }

    @Override
    public double queryCodePayCount(int userId) {
        Document groupFileds =new Document();
        groupFileds.put("userId", "$userId");
        // 过滤条件
        Document query =new Document();
        query.put("userId", userId);
        Document macth=new Document("$match",query);

        Document fileds = new Document("_id", groupFileds);
        fileds.put("count", new BasicDBObject("$sum","$money"));
        Document group = new Document("$group", fileds);
        MongoCollection<Document> collection = getDatastore().getCollection(getCollectionName(getEntityClass()));

        AggregateIterable<Document> out= collection.aggregate(Arrays.asList(macth,group));
        Iterator<Document> result=out.iterator();
        while (result.hasNext()){
            return  Double.valueOf(result.next().get("count").toString());
        }
        return 0;
    }

    @Override
    public double queryToDayCodePayCount(int userId) {
        Document groupFileds =new Document();
        groupFileds.put("userId", "$userId");
        // 过滤条件
        Document query =new Document();
        query.put("userId", userId);
        query.put("createTime",
                new Document(MongoOperator.GT, DateUtil.getTodayMorning().getTime()/1000)
                        .append(MongoOperator.LTE,DateUtil.currentTimeSeconds()));

        Document macth=new Document("$match",query);

        Document fileds = new Document("_id", groupFileds);
        fileds.put("count", new BasicDBObject("$sum","$money"));
        Document group = new Document("$group", fileds);
        MongoCollection<Document> collection = getDatastore().getCollection(getCollectionName(getEntityClass()));
        AggregateIterable<Document> out= collection.aggregate(Arrays.asList(macth,group));
        Iterator<Document> result=out.iterator();
        while (result.hasNext()){
            return  Double.valueOf(result.next().get("count").toString());
        }
        return 0;
    }
}

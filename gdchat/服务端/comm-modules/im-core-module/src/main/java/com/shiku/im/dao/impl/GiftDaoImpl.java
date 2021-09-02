package com.shiku.im.dao.impl;

import com.google.common.collect.Lists;
import com.mongodb.client.MapReduceIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.im.dao.GiftDao;
import com.shiku.im.entity.Gift;
import com.shiku.im.repository.MongoRepository;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class GiftDaoImpl extends MongoRepository<Gift, ObjectId> implements GiftDao {



    @Override
    public Class<Gift> getEntityClass() {
        return Gift.class;
    }

    @Override
    public void addGift(Gift gift) {
        getDatastore().save(gift);
    }

    @Override
    public Gift getGift(ObjectId giftId) {
        return get(giftId);
    }

    @Override
    public void deleteGift(ObjectId giftId) {
       deleteById(giftId);
    }

    @Override
    public List<Gift> getGiftList(String name, int pageIndex, int pageSize) {
        Query query = createQuery();

        if(!"".equals(name)){
			addToQuery(query,"name", name);
		}
        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public Map<String, Object> getGiftListMap(String name, int pageIndex, int pageSize) {
        Map<String,Object> map = new HashMap<>();
        Query query = createQuery();
        if(!"".equals(name)){
            addToQuery(query,"name", name);
        }
        map.put("total",count(query));
        map.put("data",queryListsByQuery(query,pageIndex,pageSize));
        return map;
    }

    @Override
    public List<Document> findByUser(ObjectId msgId) {
        List<Document> objList = Lists.newArrayList();

        StringBuffer sbMap = new StringBuffer();
        sbMap.append(" function() { ");
        sbMap.append(" 	emit({ ");
        sbMap.append(" 		userId : this.userId, ");
        sbMap.append(" 		nickname : this.nickname ");
        sbMap.append(" 	}, { ");
        sbMap.append(" 		price : this.price, ");
        sbMap.append(" 		count : this.count ");
        sbMap.append(" 	}); ");
        sbMap.append(" } ");

        StringBuffer sbReduce = new StringBuffer();
        sbReduce.append(" function (key, values) { ");
        sbReduce.append(" 	var result = 0; ");
        sbReduce.append(" 	for (var i = 0; i < values.length; i++) { ");
        sbReduce.append(" 		result += values[i].price * values[i].count; ");
        sbReduce.append(" 	} ");
        sbReduce.append(" 	return result; ");
        sbReduce.append(" } ");

        MongoCollection<Document> inputCollection = getDatastore().getCollection(getCollectionName(getEntityClass()));
        String map = sbMap.toString();
        String reduce = sbReduce.toString();
        Document query = new Document("msgId", msgId);

        MapReduceIterable<Document> mapReduceIterable = inputCollection
                .mapReduce(map, reduce);
        mapReduceIterable.filter(query);
        MongoCursor<Document> iterator = mapReduceIterable.iterator();

        while (iterator.hasNext()) {
            Document tObj = iterator.next();

            Document dbObj = (Document) tObj.get("_id");
            dbObj.put("money", tObj.get("value"));

            objList.add(dbObj);
        }
        iterator.close();
        return objList;
    }

    @Override
    public List<Document> findByGift(ObjectId msgId) {
        List<Document> objList = Lists.newArrayList();

        StringBuffer sbMap = new StringBuffer();
        sbMap.append(" function() { ");
        sbMap.append(" 	emit({ ");
        sbMap.append(" 		id : this.id ");
        sbMap.append(" 	}, { ");
        sbMap.append(" 		count : this.count ");
        sbMap.append(" 	}); ");
        sbMap.append(" } ");

        StringBuffer sbReduce = new StringBuffer();
        sbReduce.append(" function (key, values) { ");
        sbReduce.append(" 	var total = 0; ");
        sbReduce.append(" 	for (var i = 0; i < values.length; i++) { ");
        sbReduce.append(" 		total += values[i].count; ");
        sbReduce.append(" 	} ");
        sbReduce.append(" 	return total; ");
        sbReduce.append(" } ");

        MongoCollection<Document> inputCollection = getDatastore().getCollection(getCollectionName(getEntityClass()));
        String map = sbMap.toString();
        String reduce = sbReduce.toString();
        Document query = new Document("msgId", msgId);

        MapReduceIterable<Document> mapReduceIterable = inputCollection
                .mapReduce(map, reduce);
        mapReduceIterable.filter(query);
        MongoCursor<Document> iterator = mapReduceIterable.iterator();

        while (iterator.hasNext()) {
            Document tObj = iterator.next();

            Document dbObj = (Document) tObj.get("_id");
            dbObj.put("count", tObj.get("value"));

            objList.add(dbObj);
        }

        return objList;
    }
}

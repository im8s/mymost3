package com.shiku.co.module.dao.impl;

import com.mongodb.BasicDBObject;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.co.module.dao.RechargeDao;
import com.shiku.co.module.entity.Recharge;
import com.shiku.common.model.PageResult;
import com.shiku.common.util.StringUtil;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.repository.MongoRepository;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/12/2 15:49
 */
@Repository
public class RechargeDaoImpl extends MongoRepository<Recharge, ObjectId> implements RechargeDao {
    @Override
    public MongoTemplate getDatastore() {
        return super.getDatastore();
    }

    @Override
    public Class<Recharge> getEntityClass() {
        return Recharge.class;
    }

    @Override
    public void addRecharge(Recharge entity) {
        getDatastore().save(entity);
    }

    @Override
    public Recharge getRecharge(ObjectId id) {
        return get(id);
    }

    @Override
    public PageResult<Recharge> getRechargeList(int pageIndex, int pageSize,String keyword,String startDate,String endDate) {
        PageResult<Recharge> result = new PageResult<>();
        Query query = createQuery();
        if(0 != pageSize){
            query.with(createPageRequest(pageIndex,pageSize));
        }
        if(!StringUtil.isEmpty(keyword)){
            query.addCriteria(Criteria.where("userId").is(Integer.valueOf(keyword)));
        }
        //时间范围查询
        if(!StringUtil.isEmpty(startDate) && !StringUtil.isEmpty(endDate)) {
            long startTime = 0; //开始时间（秒）
            long endTime = 0; //结束时间（秒）,默认为当前时间
            startTime = StringUtil.isEmpty(startDate) ? 0 : DateUtil.toDate(startDate).getTime()/1000;
            endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
            long formateEndtime = DateUtil.getOnedayNextDay(endTime,1,0);
            query.addCriteria(Criteria.where("createTime").gt(startTime).lte(formateEndtime));
        }

        descByquery(query,"createTime");
        result.setData(getDatastore().find(query,getEntityClass()));
        result.setCount(count(query));
        return result;
    }

    @Override
    public Map<String,Object> queryRecharge(){
        Map<String,Object> map = new HashMap<>();
        Query query = createQuery();
        final MongoCollection<Document> collection =getDatastore().getCollection("recharge");
        List<Document> pipeline=new ArrayList<>();
        Document group=new Document("$group", new BasicDBObject("_id", "$status")
                .append("sum",new Document("$sum","$money")));
        pipeline.add(group);
        MongoCursor<Document> cursor = collection.aggregate(pipeline).iterator();
        // 总充值申请 充值成功 充值失败 申请中
        double totalRecharge = 0, successRecharge = 0, failureRecharge = 0, applyRecharge = 0;
        while (cursor.hasNext()) {
            Document dbObject = (Document) cursor.next();
            if(dbObject.get("_id").equals(1)){
                applyRecharge = (double)dbObject.get("sum");
            }else if(dbObject.get("_id").equals(2)){
                successRecharge = (double)dbObject.get("sum");
            }else if(dbObject.get("_id").equals(-1)){
                failureRecharge = (double)dbObject.get("sum");
            }
            totalRecharge = applyRecharge+successRecharge+failureRecharge;
        }
        map.put("totalRecharge",totalRecharge);
        map.put("successRecharge",successRecharge);
        map.put("failureRecharge",failureRecharge);
        map.put("applyRecharge",applyRecharge);
        return map;
    }

    @Override
    public Recharge updateRecharge(ObjectId id, Map<String, Object> map) {
        Query query = createQuery("_id",id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
       return getDatastore().findAndModify(query,ops,getEntityClass());
    }

    @Override
    public void deleteRecharge(ObjectId id) {
        deleteById(id);
    }
}

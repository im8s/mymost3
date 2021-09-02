package com.shiku.co.module.dao.impl;

import com.mongodb.BasicDBObject;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.co.module.dao.WithdrawDao;
import com.shiku.co.module.entity.Withdraw;
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
 * @date 2019/12/2 17:10
 */
@Repository
public class WithdrawDaoImpl extends MongoRepository<Withdraw, ObjectId> implements WithdrawDao {
    @Override
    public MongoTemplate getDatastore() {
        return super.getDatastore();
    }

    @Override
    public Class<Withdraw> getEntityClass() {
        return Withdraw.class;
    }

    @Override
    public void addWithdraw(Withdraw entity) {
        getDatastore().save(entity);
    }

    @Override
    public Withdraw getWithdraw(ObjectId id) {
        return get(id);
    }

    @Override
    public PageResult<Withdraw> getWithdrawList(int pageIndex, int pageSize,String keyword,String startDate,String endDate) {
        PageResult<Withdraw> result = new PageResult<>();
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
        result.setCount(count(query));
        result.setData(getDatastore().find(query,getEntityClass()));
        return result;
    }

    @Override
    public Map<String, Object> queryWithdraw() {
        Map<String,Object> map = new HashMap<>();
        Query query = createQuery();
        final MongoCollection<Document> collection =getDatastore().getCollection("withdraw");
        List<Document> pipeline=new ArrayList<>();
        Document group=new Document("$group", new BasicDBObject("_id", "$status")
                .append("sum",new Document("$sum","$money")));
        pipeline.add(group);
        MongoCursor<Document> cursor = collection.aggregate(pipeline).iterator();
        // 总充值申请 充值成功 充值失败 申请中
        double totalRecharge = 0, successRecharge = 0, failureRecharge = 0, applyRecharge = 0,ignoreCount=0;
        while (cursor.hasNext()) {
            Document dbObject = (Document) cursor.next();
            if(dbObject.get("_id").equals(1)){
                applyRecharge = (double)dbObject.get("sum");
            }else if(dbObject.get("_id").equals(2)){
                successRecharge = (double)dbObject.get("sum");
            }else if(dbObject.get("_id").equals(-1)){
                failureRecharge = (double)dbObject.get("sum");
            }else if(dbObject.get("_id").equals(-2)){
                ignoreCount = (double)dbObject.get("sum");
            }
            totalRecharge = applyRecharge+successRecharge+failureRecharge;
        }
        map.put("totalWithdraw",totalRecharge);
        map.put("successWithdraw",successRecharge);
        map.put("failureWithdraw",failureRecharge);
        map.put("applyWithdraw",applyRecharge);
        map.put("ignoreCount",ignoreCount);
        return map;
    }

    @Override
    public Withdraw updateWithdraw(ObjectId id, Map<String, Object> map) {
        Query query = createQuery("_id",id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
//        getDatastore().updateFirst(query,ops,getEntityClass());
        return getDatastore().findAndModify(query,ops,getEntityClass());
    }

    @Override
    public void deleteWithdraw(ObjectId id) {
        deleteById(id);
    }
}

package com.shiku.im.pay.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.pay.dao.TransferDao;
import com.shiku.im.pay.entity.Transfer;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import com.shiku.utils.Money;
import com.shiku.utils.StringUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.GroupOperation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Repository
public class TransferDaoImpl extends MongoRepository<Transfer, ObjectId> implements TransferDao {

    @Override
    public Class<Transfer> getEntityClass() {
        return Transfer.class;
    }

    @Override
    public void addTransfer(Transfer transfer) {
        getDatastore().save(transfer);
    }

    @Override
    public Object addTransferReturn(Transfer transfer) {
        return save(transfer);
    }

    @Override
    public Transfer getTransfer(ObjectId id) {
        return get(id);
    }

    @Override
    public void updateTransfer(ObjectId id, Map<String, Object> map) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });

        update(query,ops);
    }

    @Override
    public List<Transfer> getTransferList(int userId, int pageIndex, int pageSize) {
        Query query = createQuery("userId",userId);
        if(0 != pageSize){
            query.with(createPageRequest(pageIndex,pageSize));
        }
       descByquery(query,"createTime");
        return queryListsByQuery(query);
    }

    @Override
    public PageResult<Transfer> getTransferList(int pageIndex, int pageSize, String keyword,String startDate,String endDate) {
        PageResult<Transfer> result = new PageResult<>();
        Query query = createQuery();
        if(!StringUtil.isEmpty(keyword))
           addToQuery(query,"userId",Integer.valueOf(keyword));
        if(!StringUtil.isEmpty(startDate) && !StringUtil.isEmpty(endDate)){
            long startTime = 0; //开始时间（秒）
            long endTime = 0; //结束时间（秒）,默认为当前时间
            startTime = StringUtil.isEmpty(startDate) ? 0 : DateUtil.toDate(startDate).getTime()/1000;
            endTime = StringUtil.isEmpty(endDate) ? DateUtil.currentTimeSeconds() : DateUtil.toDate(endDate).getTime()/1000;
           query.addCriteria(Criteria.where("createTime").gt(startTime).lte(endTime));
        }
        descByquery(query,"createTime");
        result.setCount(count(query));
        result.setData(queryListsByQuery(query,pageIndex, pageSize, 1));
        return result;
    }

    @Override
    public List<Transfer> getTransferTimeOut(long currentTime, int status) {
        Query query =createQuery();
        query.addCriteria(Criteria.where("outTime").lt(currentTime));
        query.addCriteria(Criteria.where("tradeNo").is(null));
        addToQuery(query,"status",status);
        return queryListsByQuery(query);
    }

    @Override
    public void updateTransferTimeOut(long currentTime, int status, Map<String, Object> map) {
        Query query =createQuery();
        query.addCriteria(Criteria.where("outTime").lt(currentTime));
        addToQuery(query,"status",status);

        Update ops = createUpdate();
        map.forEach((key,vaule)->{
            ops.set(key,vaule);
        });

       update(query,ops);
    }

    public Transfer getTransferByYop(String orderNo){
        Query query =createQuery("tradeNo",orderNo);
        return findOne(query);
    }

    @Override
    public String queryTransferOverGroupCount(long startTime, long endTime){

        Criteria criteria = Criteria.where("status").is(1);
        String total="0.0";

        if(0<startTime||0<endTime){
            Criteria timeCriteria = Criteria.where("createTime");

            if(0<startTime){
                timeCriteria.gt(startTime);
            }
            if(0<endTime){
                timeCriteria.lt(endTime);
            }
            criteria.andOperator(timeCriteria);
        }


        /**
         * 分组
         */
        GroupOperation groupOperation = Aggregation.group().sum("money").as("total");

        Aggregation aggregation = Aggregation.newAggregation(Aggregation.match(criteria),
                groupOperation,
                Aggregation.project("total")
        );
        AggregationResults<Document> aggregate = getDatastore().aggregate(aggregation, Transfer.class, Document.class);
        Iterator<Document> iterator = aggregate.iterator();
        Document document=null;
        while (iterator.hasNext()){
            document = iterator.next();
            total = Money.fromYuan(document.getDouble("total").toString());

        }
        System.out.println("queryTransferOverGroupCount total ==> "+total);

        return total;

    }
}

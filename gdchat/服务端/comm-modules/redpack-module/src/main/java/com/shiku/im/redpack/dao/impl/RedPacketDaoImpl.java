package com.shiku.im.redpack.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.redpack.dao.RedPacketDao;
import com.shiku.im.redpack.entity.RedPacket;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import com.shiku.utils.Money;
import com.shiku.utils.StringUtils;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Sort;
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

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/8/30 14:46
 */
@Repository
public class RedPacketDaoImpl extends BaseMongoRepository<RedPacket, ObjectId> implements RedPacketDao {



    @Override
    public Class<RedPacket> getEntityClass() {
        return RedPacket.class;
    }

    @Override
    public void addRedPacket(RedPacket redPacket) {
        getDatastore().save(redPacket);
    }

    @Override
    public RedPacket getRedPacketById(ObjectId id) {
        return get(id);
    }

    @Override
    public void updateRedPacket(ObjectId id, Map<String, Object> map) {
        Query query =createQuery("_id",id);
        Update update=createUpdate();
        map.forEach((key,value)->{
            update.set(key,value);
        });
        update(query,update);
    }

    @Override
    public List<RedPacket> getRedPacketList(int userId, int pageIndex, int pageSize) {
        Query query = createQuery("userId",userId);
        query.with(createPageRequest(pageIndex,pageSize,Sort.by(Sort.Order.desc("sendTime"))));
        return queryListsByQuery(query);
    }

    @Override
    public PageResult<RedPacket> getRedPackListPageResult(String userName, String redPacketId, int pageIndex, int pageSize) {
        PageResult<RedPacket> result = new PageResult<RedPacket>();
        Query query = createQuery();
        query.with(createPageRequest(pageIndex,pageSize,Sort.by(Sort.Order.desc("sendTime"))));
        if(!StringUtil.isEmpty(userName)){
            boolean flag = NumberUtil.isNum(userName);
            if(flag&&9>=userName.length()){
                query.addCriteria(createCriteria().orOperator(Criteria.where("userId").is(Integer.valueOf(userName)),
                        Criteria.where("userName").is(userName)));
            }else {
                addToQuery(query,"userName",userName);
            }

        }

        if(!StringUtils.isEmpty(redPacketId)) {
            addToQuery(query,"_id",redPacketId);
        }
        result.setCount(count(query));
        result.setData(queryListsByQuery(query));
        return result;
    }

    @Override
    public List<RedPacket> getRedPackListTimeOut(long outTime,int status) {
        Query query = createQuery().addCriteria(Criteria.where("outTime").lt(outTime));
        //只查询发出状态的红包
        query.addCriteria(Criteria.where("over").gt(0));
        query.addCriteria(Criteria.where("status").is(status));
        query.addCriteria(Criteria.where("yopRedPacketId").is(null));

        return queryListsByQuery(query);
    }

    @Override
    public void updateRedPackListTimeOut(long outTime, int status, Map<String, Object> map) {
        Query query = createQuery().addCriteria(Criteria.where("outTime").lt(outTime));
        //只查询发出状态的红包
        query.addCriteria(Criteria.where("over").gt(0));
        query.addCriteria(Criteria.where("status").is(status));

        Update update=createUpdate();
        map.forEach((key,value)->{
            update.set(key,value);
        });
        update(query,update);
    }

    public RedPacket getRedPacketByPoy(String yopRedPacketId){
        Query query = createQuery("yopRedPacketId",yopRedPacketId);
        return findOne(query);
    }


    @Override
    public String queryRedpackOverGroupCount(long startTime, long endTime){

        Criteria criteria = Criteria.where("status").is(1);
        String total="0.0";

        if(0<startTime||0<endTime){
            Criteria timeCriteria = Criteria.where("sendTime");

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
        GroupOperation groupOperation = Aggregation.group().sum("over").as("total");

        Aggregation aggregation = Aggregation.newAggregation(Aggregation.match(criteria),
                groupOperation,
                Aggregation.project("total")
        );
        AggregationResults<Document> aggregate = getDatastore().aggregate(aggregation, RedPacket.class, Document.class);
        Iterator<Document> iterator = aggregate.iterator();
        Document document=null;
        while (iterator.hasNext()){
            document = iterator.next();
            total =  Money.fromYuan(document.getDouble("total").toString());

        }
        System.out.println("queryRedpackOverGroupCount total ==> "+total);

        return total;
    }




}

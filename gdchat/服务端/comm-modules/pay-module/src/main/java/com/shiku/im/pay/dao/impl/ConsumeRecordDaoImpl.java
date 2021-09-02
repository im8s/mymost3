package com.shiku.im.pay.dao.impl;

import com.mongodb.BasicDBObject;
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.NumberUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.pay.dao.ConsumeRecordDao;
import com.shiku.im.pay.dto.BillRecordCountDTO;
import com.shiku.im.pay.dto.ConsumRecordCountDTO;
import com.shiku.im.pay.entity.BaseConsumeRecord;
import com.shiku.im.pay.entity.ConsumeRecord;
import com.shiku.im.repository.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.constants.MoneyLogConstants;
import com.shiku.utils.Money;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.GroupOperation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class ConsumeRecordDaoImpl extends MongoRepository<BaseConsumeRecord,ObjectId> implements ConsumeRecordDao {


    @Override
    public Class<BaseConsumeRecord> getEntityClass() {
        return BaseConsumeRecord.class;
    }

    @Override
    public void addConsumRecord(BaseConsumeRecord consumeRecord) {
        getDatastore().save(consumeRecord);
    }

    @Override
    public void updateConsumeRecord(ObjectId consumeRecordId, BaseConsumeRecord consumeRecord) {

        update(consumeRecordId,consumeRecord);
    }

    @Override
    public BaseConsumeRecord getConsumeReCord(ObjectId id, Integer userId) {
        Query query =createQuery("_id",id);
        addToQuery(query,"userId",userId);

        return findOne(query);
    }

    @Override
    public BaseConsumeRecord getConsumeRecordByTradeNo(String tradeNo) {

        Query query =createQuery("tradeNo",tradeNo);
        return findOne(query);
    }

    @Override
    public BaseConsumeRecord getConsumRecord(String tradeNo, int status) {
        Query query =createQuery("tradeNo",tradeNo);
        addToQuery(query,"status",status);
        return findOne(query);
    }

    @Override
    public List<BaseConsumeRecord> getConsumRecordList(int type, int userId, int pageIndex, int pageSize) {
        Query query = createQuery("type",type);
        if(0!=userId)
           addToQuery(query,"userId", userId);

        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public PageResult<BaseConsumeRecord> getConsumRecordList(int userId, int type, String tradeNo, long startTime, long endTime, int pageIndex, int pageSize, byte state) {
        Query query = createQuery();
        if(0 == type || 1 == type){
            // 充值记录
            Criteria criteria = createCriteria().orOperator(Criteria.where("type").is(KConstants.ConsumeType.USER_RECHARGE), Criteria.where("type").is(KConstants.ConsumeType.SYSTEM_RECHARGE),Criteria.where("type").is(KConstants.ConsumeType.MANUALPAYRECHARGE));
            query.addCriteria(criteria);

        }else if(2 == type){
            // 提现记录
            Criteria criteria = createCriteria().orOperator(Criteria.where("type").is(KConstants.ConsumeType.PUT_RAISE_CASH), Criteria.where("type").is(KConstants.ConsumeType.SYSTEM_HANDCASH),Criteria.where("type").is(KConstants.ConsumeType.MANUALPAYWITHDRAW));
            query.addCriteria(criteria);

        }else if(3 == type){
            // 后台充值
            addToQuery(query,"type",KConstants.ConsumeType.SYSTEM_RECHARGE);
        }else if(4 == type){
            // APP充值
            addToQuery(query,"type",KConstants.ConsumeType.USER_RECHARGE);
        }
        descByquery(query,"time");
        if(0 != userId)
            addToQuery(query,"userId",userId);
        if(!StringUtil.isEmpty(tradeNo))
            addToQuery(query,"tradeNo",tradeNo);

        if(startTime !=0 && endTime != 0){
            query.addCriteria(Criteria.where("time").gt(startTime).lt(endTime));
        }
        PageResult<BaseConsumeRecord> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,1));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public PageResult<BaseConsumeRecord> getConsumrecordList(int userId, double money, int status, int pageIndex, int pageSize, byte state) {
        Query query =createQuery("userId",userId);
        query.addCriteria(Criteria.where("money").gt(money));
        addToQuery(query,"status",status);

        descByquery(query,"time");

        PageResult<BaseConsumeRecord> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,state));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public PageResult<BaseConsumeRecord> getConsumrecordList(int userId, int toUserId, double money, int status, int type, int pageIndex, int pageSize, byte state) {
        Query query = createQuery("status",status);
        if(0!=userId)
            addToQuery(query,"userId", userId);
        if(0!=toUserId)
            addToQuery(query,"toUserId", toUserId);

        query.addCriteria(Criteria.where("money").gt(money));
        query.addCriteria(Criteria.where("type").gt(type));
        descByquery(query,"time");
        PageResult<BaseConsumeRecord> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,state));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public PageResult<BaseConsumeRecord> getConsumRecordPayList(int userId, int type, long startTime, long endTime, int pageIndex, int pageSize, byte state) {
        Query query = createQuery();
        if(0 != type)
            addToQuery(query,"type", type);
        else{
            // // 过滤用户付款码付款和二维码付款
            Criteria criteria = createCriteria().orOperator(Criteria.where("type").is(KConstants.ConsumeType.SEND_PAYMENTCODE), Criteria.where("type").is(KConstants.ConsumeType.SEND_QRCODE));
            query.addCriteria(criteria);
        }
        if(0 != userId)
            addToQuery(query,"userId", userId);
        if(0 != startTime&& 0!= endTime){
            query.addCriteria(Criteria.where("time").gt(startTime).lte(endTime));
        }
        descByquery(query,"time");
        PageResult<BaseConsumeRecord> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,pageIndex,pageSize,state));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public PageResult<BaseConsumeRecord> queryConsumRecordList(int userId, int status, int type, long startTime, long endTime, int pageIndex, int pageSize, byte state) {
        Query query = createQuery("userId",userId);
        addToQuery(query,"status", status);
        if(0 != type)
            addToQuery(query,"type", type);
        if(0 != startTime&&0!= endTime)
            query.addCriteria(Criteria.where("time").gt(startTime).lte(endTime));
        descByquery(query,"time");
        PageResult<BaseConsumeRecord> result = new PageResult<>();
        result.setData(queryListsByQuery(query,pageIndex,pageSize,state));
        result.setCount(count(query));
        return result;
    }

    @Override
    public Map<String, Object> queryConsumRecord(int userId, int status, int type, long startTime, long endTime, int pageIndex, int pageSize, byte state) {
        final MongoCollection<Document> collection =getDatastore().getCollection("ConsumeRecord");
        List<Document> pipeline=new ArrayList<>();
        Document basicDBObject = new Document("userId",userId).append("status", status);
        if(0 != type)
			basicDBObject.append("type", type);
        if(startTime !=0 && endTime !=0){
            basicDBObject.append("time", new BasicDBObject(MongoOperator.GT,startTime)).append("time", new BasicDBObject(MongoOperator.LT,endTime));
        }
        Document match=new Document("$match", basicDBObject);
        Document group=new Document("$group", new  BasicDBObject("_id", "$type")
                .append("sum",new Document("$sum","$money")));
        pipeline.add(match);
        pipeline.add(group);
        MongoCursor<Document> cursor = collection.aggregate(pipeline).iterator();

        // 总充值、提现、转出、转入、发送红包、接收红包
        double totalTecharge = 0, totalCash = 0, totalTransfer = 0, totalAccount = 0, sendPacket = 0, receivePacket = 0;
        try {
            while (cursor.hasNext()) {
                Document dbObject = (Document) cursor.next();
                // 充值=用户充值+后台充值
                if(dbObject.get("_id").equals(1) || dbObject.get("_id").equals(3)){
                    totalTecharge = StringUtil.addDouble(totalTecharge, (double)dbObject.get("sum"));
                }
                // 提现=用户提现+手工提现
                if(dbObject.get("_id").equals(2) || dbObject.get("_id").equals(16)){
                    totalCash = StringUtil.addDouble(totalCash, (double)dbObject.get("sum"));
                }
                // 转出
                if(dbObject.get("_id").equals(7)){
                    totalTransfer = StringUtil.addDouble(totalTransfer, (double)dbObject.get("sum"));
                }
                // 转入
                if(dbObject.get("_id").equals(8)){
                    totalAccount = StringUtil.addDouble(totalAccount, (double)dbObject.get("sum"));
                }
                // 发出红包
                if(dbObject.get("_id").equals(4)){
                    sendPacket = StringUtil.addDouble(sendPacket, (double)dbObject.get("sum"));
                }
                // 接收红包
                if(dbObject.get("_id").equals(5)){
                    receivePacket = StringUtil.addDouble(receivePacket, (double)dbObject.get("sum"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            cursor.close();
        }
        Map<String,Object> map = new HashMap<>();
        map.put("totalTecharge",totalTecharge);
        map.put("totalCash",totalCash);
        map.put("totalTransfer",totalTransfer);
        map.put("totalAccount",totalAccount);
        map.put("sendPacket",sendPacket);
        map.put("receivePacket",receivePacket);

        return map;
    }

    @Override
    public void deleteConsumRecordByUserId(Integer userId) {
        Query query =createQuery("userId",userId);
        deleteByQuery(query);
    }
    @Override
    public double getUserPayMoney(int userId,int type,int status,long startTime, long endTime ){
        Document groupFileds = new Document();
        groupFileds.put("userId","$userId");

        Document map =new Document();
        map.put("userId",userId);
        map.put("type",type);
        map.put("status",status);
        map.put("time",new BasicDBObject("$gt",startTime).append("$lte",endTime));
        Document macth=new Document("$match",new Document(map));

        Document fileds = new Document("_id", groupFileds);
        fileds.put("money", new BasicDBObject("$sum","$money"));
        Document group = new Document("$group", fileds);
       
        MongoCollection<Document> collection = getDatastore().getCollection(getCollectionName(getEntityClass()));
        AggregateIterable<Document> out= collection.aggregate(Arrays.asList(macth,group));
        Iterator<Document> result=out.iterator();

        while (result.hasNext()){
            return Double.valueOf(result.next().get("money").toString());
        }
        return 0;
    }


    @Override
    public ConsumRecordCountDTO queryConsumeRecordCount(int userId, long startTime, long endTime, int pageIndex, int pageSize,
                                                        boolean needCount,boolean isNext){
        ConsumRecordCountDTO resultDto=new ConsumRecordCountDTO();
        Query query=createQuery();
        Criteria criteria = createCriteria();

        criteria.and("userId").is(userId);
        criteria.and("status").gt(KConstants.OrderStatus.CREATE).and("changeType").ne(null);
        Criteria timeCriteria = Criteria.where("time");
        if(0<startTime){
            timeCriteria.gt(startTime);
        }
        if(0<endTime){
            timeCriteria.lt(endTime);
        }
        criteria.andOperator(timeCriteria);
        if(needCount){
            /**
             * 分组
             */
            GroupOperation groupOperation = Aggregation.group("changeType").sum("money").as("total");

            Aggregation aggregation = Aggregation.newAggregation(Aggregation.match(criteria),
                    groupOperation,
                    Aggregation.project("total").and("changeType").previousOperation()
            );
            AggregationResults<Document> aggregate = getDatastore().aggregate(aggregation, ConsumeRecord.class, Document.class);
            Iterator<Document> iterator = aggregate.iterator();
            Document document=null;
            while (iterator.hasNext()){
                document = iterator.next();
                if(KConstants.MOENY_ADD==document.getInteger("changeType")){
                    resultDto.setIncome(NumberUtil.format(document.getDouble("total")));
                }else if(KConstants.MOENY_REDUCE==document.getInteger("changeType")){
                    resultDto.setExpenses(NumberUtil.format(document.getDouble("total")));
                }
            }

        }
        query.addCriteria(criteria);

        PageRequest pageRequest = createPageRequest(pageIndex, pageSize);
        query.with(pageRequest);
        if(isNext){
            descByquery(query,"time");
        }else{
            ascByquery(query,"time");
        }
        resultDto.setRecordList(queryListsByQuery(query));

        return resultDto;

    }


    @Override
    public String queryRechargeGroupCount(long startTime, long endTime){
        Criteria criteria = Criteria.where("status").is(1);
        String total=null;

         criteria.orOperator(Criteria.where("type").is(KConstants.ConsumeType.USER_RECHARGE),
                Criteria.where("type").is(KConstants.ConsumeType.MANUALPAYRECHARGE)
                        .and("manualPay_status").is(1)
        );

         /*if(0==startTime){
             startTime= DateUtil.getLastYear().getTime()/1000;
         }*/

        if(0<startTime||0<endTime){
            Criteria timeCriteria = Criteria.where("time");

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
        AggregationResults<Document> aggregate = getDatastore().aggregate(aggregation, BaseConsumeRecord.class, Document.class);
        Iterator<Document> iterator = aggregate.iterator();
        Document document=null;
        while (iterator.hasNext()){
            document = iterator.next();
            total = Money.fromYuan(document.getDouble("total").toString());

        }
        System.out.println("queryRechargeGroupCount total ==> "+ total);

        return total;

    }

    @Override
    public BillRecordCountDTO queryCashGroupCount(long startTime, long endTime){
        Criteria criteria = Criteria.where("status").is(1);
        BillRecordCountDTO billRecordCountDTO=new BillRecordCountDTO();

        criteria.orOperator(Criteria.where("type").is(KConstants.ConsumeType.PUT_RAISE_CASH),
                Criteria.where("type").is(KConstants.ConsumeType.MANUALPAYWITHDRAW)
                        .and("manualPay_status").is(1)
        );

         if(0==startTime){
             startTime= DateUtil.getLastYear().getTime()/1000;
         }

        if(0<startTime||0<endTime){
            Criteria timeCriteria = Criteria.where("time");

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
        GroupOperation groupOperation = Aggregation.group().sum("money").as("total").sum("serviceCharge").as("serviceChargeTotal");

        Aggregation aggregation = Aggregation.newAggregation(Aggregation.match(criteria),
                groupOperation,
                Aggregation.project("total","serviceChargeTotal")
        );
        AggregationResults<Document> aggregate = getDatastore().aggregate(aggregation, BaseConsumeRecord.class, Document.class);
        Iterator<Document> iterator = aggregate.iterator();
        Document document=null;
        while (iterator.hasNext()){
            document = iterator.next();

            billRecordCountDTO.setCashTotal(Money.fromYuan(document.getDouble("total").toString()));
            billRecordCountDTO.setServiceChargeTotal(Money.fromYuan(document.getDouble("serviceChargeTotal").toString()));
        }
        System.out.println("queryCashGroupCount cashTotal ==> "+ billRecordCountDTO.getCashTotal());
        System.out.println("queryCashGroupCount serviceChargeTotal ==> "+ billRecordCountDTO.getServiceChargeTotal());

        return billRecordCountDTO;

    }





    @Override
    public void initRecordChangeType() {
        //"status",2
        Query query =createQuery();
        query.addCriteria(Criteria.where("changeType").is(null).and("status").gt(0));
        long count = count(query);

        logger.info(" initRecordChangeType count ===>{} ",count);
        if(0==count){
            return;
        }
        query.fields().include("_id").include("type");

       initRecordChangeType(query,0);


    }

    private void initRecordChangeType(Query query,int page) {
        logger.info(" initRecordChangeType page ===> {}",page);

        PageRequest pageRequest = createPageRequest(0, 100);
        query.with(pageRequest);
        List<BaseConsumeRecord> baseConsumeRecords = queryListsByQuery(query);
        if(null==baseConsumeRecords||0==baseConsumeRecords.size()){
            logger.info(" initRecordChangeType end ===> ");
            return;
        }

        for (BaseConsumeRecord record : baseConsumeRecords) {
            updateChangType(record);
        }
        initRecordChangeType(query,page+1);


    }
    public void updateChangType(BaseConsumeRecord record){
        byte changType= MoneyLogConstants.MoenyAddEnum.MOENY_ADD.getType();

        switch (record.getType()){
            case KConstants.ConsumeType.PUT_RAISE_CASH:
            case KConstants.ConsumeType.SEND_REDPACKET:
            case KConstants.ConsumeType.SEND_TRANSFER:
            case KConstants.ConsumeType.SEND_PAYMENTCODE:
            case KConstants.ConsumeType.SEND_QRCODE:
            case KConstants.ConsumeType.LIVE_GIVE:
            case KConstants.ConsumeType.SYSTEM_HANDCASH:
            case KConstants.ConsumeType.SDKTRANSFR_PAY:
            case KConstants.ConsumeType.MANUALPAYWITHDRAW:
            case 62:
             changType=MoneyLogConstants.MoenyAddEnum.MOENY_REDUCE.getType();
                break;

            default:
                break;

        }

        updateAttribute(record.getId(),"changeType",changType);
    }
}

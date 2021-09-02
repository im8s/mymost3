package com.shiku.im.dao.impl;

import com.google.common.collect.Maps;
import com.shiku.common.model.PageResult;
import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.room.dao.RoomMemberDao;
import com.shiku.im.room.entity.Room;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class RoomMemberDaoImpl extends MongoRepository<Room.Member, ObjectId> implements RoomMemberDao {


    @Autowired(required = false)
    @Qualifier(value = "mongoTemplateRoomMember")
    protected MongoTemplate mongoTemplateRoomMember;


    @Override
    public MongoTemplate getDatastore() {
        return mongoTemplateRoomMember;
    }

    private static final String  MEMBER_DBNAME = "shiku_room_member";

    @Override
    public Class<Room.Member> getEntityClass() {
        return Room.Member.class;
    }

    @Override
    public String getCollectionName(ObjectId id) {
        if (null == id) {
            logger.info(" ====  getCollectionName ObjectId is null  ====");
            throw new ServiceException("ObjectId  is  null !");
        } else {
            int remainder = 0;
            int counter = id.getCounter();

            remainder = counter / KConstants.DB_REMAINDER.MEMBER;
            return String.valueOf(remainder);
        }
    }
    @Override
    public void addMember(Room.Member entity) {
        getDatastore().save(entity,getCollectionName(entity.getRoomId()));
    }

    @Override
    public void addMemberList(List<Room.Member> memberList) {
        if (0 == memberList.size()) {
            return;
        }

        getDatastore().insert(memberList,getCollectionName(memberList.get(0).getRoomId()));
    }

    @Override
    public Room.Member getMember(ObjectId roomId, int userId) {
        Query query =createQuery("roomId",roomId);
        addToQuery(query,"userId",userId);
        return findOne(query,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberList(ObjectId roomId,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        descByquery(query,"createTime");
        if(0!= pageSize)
             query.with(createPageRequest(pageIndex,pageSize,1));

        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public PageResult<Room.Member> getMemberListResult(ObjectId roomId, int pageIndex, int pageSize) {
        Query query = createQuery("roomId",roomId);
        descByquery(query,"createTime");
        //分页
        List<Room.Member> pageData=queryListsByQuery(query,pageIndex,pageSize,1,getCollectionName(roomId));
        return new PageResult<Room.Member>(pageData,count(query,getCollectionName(roomId)));
    }

    @Override
    public List<Room.Member> getMemberListLessThanOrEq(ObjectId roomId, int role,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        query.addCriteria(Criteria.where("role").lte(role));
        ascByquery(query,"role");
        ascByquery(query,"createTime");
        if(0 != pageSize)
            query.with(createPageRequest(pageIndex,pageSize));
        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberListLessThan(ObjectId roomId, int role, int pageIndex, int pageSize) {
        Query query = createQuery("roomId",roomId);
        query.addCriteria(Criteria.where("role").lt(role));
        ascByquery(query,"role");
        ascByquery(query,"createTime");
        query.with(createPageRequest(pageIndex,pageSize));
        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberListGreaterThan(ObjectId roomId, int role,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        query.addCriteria(Criteria.where("role").gt(role));
        if(0 != pageSize){
            query.with(createPageRequest(pageIndex,pageSize));
        }

        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberListByTime(ObjectId roomId, int role, long createTime,int pageSize) {

        Query query = createQuery("roomId",roomId);
//        Criteria criteria = Criteria.where("role").lte(role);
        Criteria criteria = Criteria.where("role").gte(KConstants.Room_Role.ADMIN);

        query.addCriteria(Criteria.where("createTime").gte(createTime));

        if(KConstants.Room_Role.CREATOR != role){
            criteria.ne(4);
        }
        query.addCriteria(criteria);
        ascByquery(query,"createTime");
		return queryListsByQuery(query,0,pageSize,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberListByNickname(ObjectId roomId, String nickName) {
        Query query = createQuery("roomId",roomId);
        query.addCriteria(containsIgnoreCase("nickname",nickName));
        ascByquery(query,"createTime");
        ascByquery(query,"role");
        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public List<Room.Member> getMemberListOrder(ObjectId roomId) {
        Query query = createQuery("roomId",roomId);
        ascByquery(query,"createTime");
        ascByquery(query,"role");
        return queryListsByQuery(query,getCollectionName(roomId));
    }

    @Override
    public Map<String,Object> getMemberListOr(ObjectId roomId, int role, int userId,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        Criteria criteria = createCriteria().orOperator(Criteria.where("role").lt(role), Criteria.where("userId").is(userId));
        query.addCriteria(criteria);
        ascByquery(query,"role");
        ascByquery(query,"createTime");
        query.with(createPageRequest(pageIndex,pageSize));
        List<Room.Member> members = queryListsByQuery(query);
        Map<String,Object> membersMap = Maps.newConcurrentMap();
        membersMap.put("count",count(query));
        membersMap.put("members",members);
        return membersMap;
    }

    @Override
    public List<Room.Member> getMemberListAdminRole(ObjectId roomId, int role,int pageSize) {
        Query query = createQuery("roomId",roomId);
        Criteria criteria = Criteria.where("role").gt(KConstants.Room_Role.ADMIN);


        if(KConstants.Room_Role.CREATOR != role)
            criteria.ne(KConstants.Room_Role.INVISIBLE);
        query.addCriteria(criteria);
        ascByquery(query,"createTime");
        return queryListsByQuery(query,0,pageSize,getCollectionName(roomId));
    }







    @Override
    public List<Integer> getMemberUserIdList(ObjectId roomId,int role) {
        Query query = createQuery("roomId",roomId);
        if(role != 0)
            addToQuery(query,"role",role);
        List<Integer> memberIdList= getDatastore().findDistinct(query,"userId",getCollectionName(roomId),Integer.class);
        return  memberIdList;
    }

    @Override
    public Object getMemberOneFile(ObjectId roomId, int userId, int offlineNoPushMsg) {
        Document query = new Document("roomId",roomId);
        query.append("userId", userId);
        query.append("offlineNoPushMsg", 1);
        Object field = queryOneField(getCollectionName(roomId),"offlineNoPushMsg",query);
        return field;
    }



    @Override
    public Object findMemberRole(ObjectId roomId, int userId) {
        Object role = queryOneField(getCollectionName(roomId), "role",
                new Document("roomId", roomId).append("userId", userId));
        return role;
    }

    @Override
    public void deleteRoomMember(ObjectId roomId,Integer userId) {
        Query query = createQuery("roomId",roomId);
        if(null != userId)
            addToQuery(query,"userId",userId);
       deleteByQuery(query,getCollectionName(roomId));
    }

    @Override
    public void updateRoomMember(ObjectId roomId, long talkTime) {
        Query query = createQuery("roomId",roomId);
        Update ops = createUpdate();
        ops.set("talkTime", talkTime);
        update(query,ops,getCollectionName(roomId));
    }

    @Override
    public void updateRoomMemberRole(ObjectId roomId, int userId, int role) {
        Query query = createQuery("roomId",roomId);
        addToQuery(query,"userId",userId);
        Update ops = createUpdate();
        ops.set("role", role);
        update(query,ops,getCollectionName(roomId));
    }

    @Override
    public void updateRoomMember(ObjectId roomId, int userId, Map<String, Object> map) {
        Query query = createQuery();
        if(null != roomId){
            addToQuery(query,"roomId",roomId);
        }
        if(0 != userId){
            addToQuery(query,"userId",userId);
        }

        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops,getCollectionName(roomId));
    }

    @Override
    public void updateRoomMemberAttribute(ObjectId roomId, int userId, String key, Object value) {
        Query query = createQuery();
        if(null != roomId){
            addToQuery(query,"roomId",roomId);
        }
        if(0 != userId){
            addToQuery(query,"userId",userId);
        }

        Update ops = createUpdate().set(key,value);
        if (null != roomId) {
            update(query,ops,getCollectionName(roomId));
        }else{
            getDatastore().getCollectionNames().forEach(name->{
                update(query,ops,name);
            });
        }

    }

    @Override
    public long getMemberNumGreaterThanOrEq(ObjectId roomId, byte role,int pageIndex,int pageSize) {
        Query query = createQuery("roomId",roomId);
        if(0 != pageIndex && 0!=pageSize){
           query.with(createPageRequest(pageIndex,pageSize));
        }
        query.addCriteria(Criteria.where("role").gte(role));
        return count(query,getCollectionName(roomId));
    }

    @Override
    public long getMemberNumLessThan(ObjectId roomId, byte role,int userId) {
        Query query = createQuery("roomId",roomId);
        Criteria criteria = createCriteria().orOperator(Criteria.where("role").lt(KConstants.Room_Role.INVISIBLE), Criteria.where("userId").is(userId));
        query.addCriteria(criteria);
        return count(query,getCollectionName(roomId));
    }
}

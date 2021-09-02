package com.shiku.im.room.dao.impl;

import com.alibaba.fastjson.JSON;
import com.mongodb.BasicDBObject;
import com.mongodb.client.MapReduceIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.shiku.im.comm.constants.MsgType;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.room.dao.RoomDao;
import com.shiku.im.room.entity.Room;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.utils.StringUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class RoomDaoImpl extends MongoRepository<Room, ObjectId> implements RoomDao {


    @Autowired(required = false)
    @Qualifier(value = "mongoTemplateForRoom")
    protected MongoTemplate dsForRoom;



    @Autowired
    IMessageRepository messageRepository;
    @Override
    public MongoTemplate getDatastore() {
        return dsForRoom;
    }
    public final  String MUCMSG="mucmsg_";

    @Override
    public Class<Room> getEntityClass() {
        return Room.class;
    }

    @Override
    public void addRoom(Room room) {
        getDatastore().save(room);
    }



    @Override
    public Room getRoom(String roomname, ObjectId roomId) {
        Query query =createQuery("name",roomname);
        if(null!=roomId)
            addToQuery(query,"_id",roomId);
        return findOne(query);
    }



    @Override
    public long getAllRoomNums() {
        try {
            return getDatastore().getCollection(Room.getDBName()).countDocuments();
        }catch (Exception e){
            return 0;
        }

    }

    @Override
    public void updateRoomUserSize(ObjectId roomId, int userSize) {
       Query query=createQuery(roomId);

        Update update=createUpdate().inc("userSize", userSize);
        update(query,update);
    }

    @Override
    public void updateRoom(ObjectId roomId, Map<String, Object> map) {
        Query query = createQuery(roomId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public void updateRoomByUserId(int userId, Map<String, Object> map) {
        Query query = createQuery("userId",userId);
        Update ops =createUpdate();
        map.forEach((key,vaule)->{
            ops.set(key,vaule);
        });
        update(query,ops);
    }

    @Override
    public void deleteRoom(ObjectId roomId) {
       deleteById(roomId);
    }

    @Override
    public Integer getCreateUserId(ObjectId roomId) {
        return (Integer) queryOneField("userId", new Document("_id", roomId));
    }


    @Override
    public Integer queryRoomStatus(ObjectId roomId) {
        return (Integer) queryOneFieldById("s",roomId);
    }


    @Override
    public Integer getRoomStatus(ObjectId roomId) {
        return (Integer) queryOneField("s", new Document("_id", roomId));
    }



    @Override
    public List<Room> getRoomList(List<ObjectId> list, int s, int pageIndex, int pageSize) {
        // 关闭端到端版本后不返回端到端的私密群组
        Query query = createQuery();
        byte isOpenSecureChat = SKBeanUtils.getImCoreService().getClientConfig().getIsOpenSecureChat();
        if (0 == isOpenSecureChat) {
            query.addCriteria(Criteria.where("isSecretGroup").ne(1));
        }
        query.addCriteria(Criteria.where("_id").in(list));
        if (0 != s)
            addToQuery(query, "s", s);
        if (0 != pageSize)
            query.with(createPageRequest(pageIndex, pageSize));
        descByquery(query, "_id");
        return queryListsByQuery(query);
    }

    @Override
    public List<Room> getRoomListOrName(int pageIndex, int pageSize, String roomName) {
        Query query = createQuery("isLook", 0);
        if (!StringUtil.isEmpty(roomName)){
           query.addCriteria(containsIgnoreCase("name",roomName));
        }
        query.addCriteria(Criteria.where("isSecretGroup").ne(1));
        descByquery(query,"_id");
        List<Room> roomList = queryListsByQuery(query,pageIndex,pageSize);
        return roomList;
    }

    @Override
    public List<Object> getAddRoomsCount(long startTime, long endTime, String mapStr, String reduce) {
        List<Object> countData = new ArrayList<>();
        Document queryTime = new Document("$ne",null);

        if(startTime!=0 && endTime!=0){
            queryTime.append("$gt", startTime);
            queryTime.append("$lt", endTime);
        }
        BasicDBObject query = new BasicDBObject("createTime",queryTime);

        //获得用户集合对象
        MongoCollection<Document> collection = getDatastore().getCollection(Room.getDBName());

        MapReduceIterable<Document> mapReduceOutput = collection.mapReduce(mapStr,reduce);
        MongoCursor<Document> iterator = mapReduceOutput.iterator();
        Map<String,Double> map = new HashMap<String,Double>();
        while (iterator.hasNext()) {
            Document obj =  iterator.next();

            map.put((String)obj.get("_id"),(Double)obj.get("value"));
            countData.add(JSON.toJSON(map));
            map.clear();
            //System.out.println(JSON.toJSON(obj));

        }
        return countData;
    }

    @Override
    public List<String> queryRoomHistoryFileType(String roomJid) {
        Query query=createQuery();
        query.addCriteria(Criteria.where("contentType").in(MsgType.FileTypeArr));
        return getDatastore().findDistinct(query,"content",MUCMSG+roomJid,String.class);
    }

    // 删除群组聊天记录
    @Override
    public void dropRoomChatHistory(String roomJid) {
        messageRepository.dropRoomChatHistory(roomJid);
    }









}

package com.shiku.im.room.dao.impl;

import com.shiku.im.repository.MongoRepository;
import com.shiku.im.room.dao.RoomCoreDao;
import com.shiku.im.room.entity.Room;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class RoomCoreDaoImpl extends MongoRepository<Room, ObjectId> implements RoomCoreDao {

    public static final String  SHIKU_ROOMJIDS_USERID = "shiku_roomJids_userId";

    @Override
    public Class<Room> getEntityClass() {
        return Room.class;
    }

    @Autowired(required = false)
    @Qualifier(value = "mongoTemplateForRoom")
    protected MongoTemplate dsForRoom;
    @Override
    public MongoTemplate getDatastore() {
        return dsForRoom;
    }

    @Override
    public Room getRoomById(ObjectId roomId) {
        return queryOneById(roomId);
    }



    @Override
    public Room getRoomByJid(String roomJid) {
        return findOne("jid",roomJid);
    }

    @Override
    public ObjectId getRoomId(String jid) {
        return (ObjectId) queryOneField("_id", new Document("jid", jid));
    }

    @Override
    public String queryRoomJid(ObjectId roomId) {
        return (String) queryOneFieldById("jid",roomId);
    }

    @Override
    public String getRoomNameByJid(String jid) {
        Object oneField = queryOneField("name", new Document("jid", jid));
        return  oneField !=null?(String) oneField :null;
    }

    @Override
    public String getRoomNameByRoomId(ObjectId roomId) {
        return (String) queryOneField("name", new Document("_id", roomId));
    }

    @Override
    public List<String> queryUserRoomsJidList(List<ObjectId> list) {
        Query query=createQuery();
        query.addCriteria(Criteria.where("_id").in(list));

        return getDatastore().findDistinct(query,"jid",getEntityClass(),String.class);
    }



}

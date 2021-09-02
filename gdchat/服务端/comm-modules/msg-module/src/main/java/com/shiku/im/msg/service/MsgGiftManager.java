package com.shiku.im.msg.service;

import com.mongodb.DBObject;
import com.shiku.im.entity.Gift;
import com.shiku.im.entity.Givegift;
import com.shiku.im.msg.model.AddGiftParam;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.List;

public interface MsgGiftManager {

    List<ObjectId> add(Integer userId, ObjectId msgId, List<AddGiftParam> paramList);

    List<Gift> getGiftList();

    List<Givegift> find(ObjectId msgId, ObjectId giftId, int pageIndex, int pageSize);

    List<Document> findByUser(ObjectId msgId);

    List<Document> findByGift(ObjectId msgId);
}

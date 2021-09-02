package com.shiku.im.pay.dao;

import com.shiku.im.pay.entity.PayOrder;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface PayOrderDao extends IMongoDAO<PayOrder, ObjectId> {

    void addPayOrder(PayOrder payOrder);

    PayOrder getPayOrder(ObjectId prepayId,String appId);
}

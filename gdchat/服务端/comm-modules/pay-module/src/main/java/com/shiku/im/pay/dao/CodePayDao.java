package com.shiku.im.pay.dao;

import com.shiku.im.pay.entity.CodePay;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface CodePayDao extends IMongoDAO<CodePay, ObjectId> {

    void addCodePay(CodePay codePay);

    double queryCodePayCount(int userId);

    double queryToDayCodePayCount(int userId);
}

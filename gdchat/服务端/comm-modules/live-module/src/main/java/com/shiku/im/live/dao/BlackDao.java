package com.shiku.im.live.dao;

import com.shiku.im.live.entity.Black;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface BlackDao extends IMongoDAO<Black, ObjectId> {

    void addBlack(Black entity);

    Black getBlack(ObjectId roomId, int userId);

    void deleteBlack(ObjectId roomId);


}

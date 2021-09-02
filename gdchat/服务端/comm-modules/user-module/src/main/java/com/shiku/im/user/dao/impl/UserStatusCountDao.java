package com.shiku.im.user.dao.impl;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.UserStatusCount;
import org.bson.types.ObjectId;

public interface UserStatusCountDao extends IMongoDAO<UserStatusCount, ObjectId> {

    void addUserStatusCount(UserStatusCount userStatusCount);

    UserStatusCount getUserStatusCount(long startTime,long endTime,int type);
}

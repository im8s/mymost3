package com.shiku.im.friends.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.friends.entity.FriendsterWebsite;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;

public interface FriendsterWebsiteDao extends IMongoDAO<FriendsterWebsite, ObjectId> {
    FriendsterWebsite saveFriendsterWebsite(FriendsterWebsite entity);

    List<FriendsterWebsite> getFriendsterWebsiteList();

    PageResult<FriendsterWebsite> queryFriendsterWebsiteList(int pageIndex, int pageSize);

    FriendsterWebsite getFriendsterWebsite(String id);
}

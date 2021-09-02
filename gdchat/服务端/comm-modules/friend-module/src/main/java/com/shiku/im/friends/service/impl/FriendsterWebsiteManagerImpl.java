package com.shiku.im.friends.service.impl;


import com.shiku.common.model.PageResult;
import com.shiku.im.friends.dao.impl.FriendsterWebsiteDaoImpl;
import com.shiku.im.friends.entity.FriendsterWebsite;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FriendsterWebsiteManagerImpl {

    @Autowired
    private FriendsterWebsiteDaoImpl friendsterWebsiteDao;

    public FriendsterWebsite saveFriendsterWebsite(FriendsterWebsite entity) {
        return friendsterWebsiteDao.saveFriendsterWebsite(entity);
    }

    public List<FriendsterWebsite> getFriendsterWebsiteList() {
        return friendsterWebsiteDao.getFriendsterWebsiteList();
    }

    public PageResult<FriendsterWebsite> queryFriendsterWebsiteList(int pageIndex, int pageSize) {
        return friendsterWebsiteDao.queryFriendsterWebsiteList(pageIndex, pageSize);
    }

    public FriendsterWebsite getFriendsterWebsite(String id) {
        return friendsterWebsiteDao.getFriendsterWebsite(id);
    }

    public void deleteById(ObjectId id) {
        friendsterWebsiteDao.deleteById(id);
    }
}

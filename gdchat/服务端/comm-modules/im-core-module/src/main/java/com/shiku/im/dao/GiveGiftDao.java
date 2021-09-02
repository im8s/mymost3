package com.shiku.im.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.entity.Givegift;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;

public interface GiveGiftDao extends IMongoDAO<Givegift, ObjectId> {

    void addGiveGift(Givegift givegift);

    void addGiveGiftList(List<Givegift> list);

    List<Givegift> getGiveGiftList(int userId, int toUserId, int pageIndex, int pageSize, int type);

    List<Givegift> getGiveGiftList(long startTime, long endTime, int pageIndex, int pageSize, int type);

    PageResult<Givegift> getGivegift(int userId, String startDate, String endDate, Integer page, Integer limit);

    List<Givegift> find(ObjectId msgId, ObjectId giftId, int pageIndex, int pageSize);

}

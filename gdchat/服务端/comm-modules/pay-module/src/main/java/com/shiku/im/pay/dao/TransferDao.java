package com.shiku.im.pay.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.pay.entity.Transfer;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface TransferDao extends IMongoDAO<Transfer, ObjectId> {

    void addTransfer(Transfer transfer);

    Object addTransferReturn(Transfer transfer);

    Transfer getTransfer(ObjectId id);

    void updateTransfer(ObjectId id, Map<String,Object> map);

    List<Transfer> getTransferList(int userId,int pageIndex,int pageSize);

    PageResult<Transfer> getTransferList(int pageIndex, int pageSize, String keyword, String startDate, String endDate);

    List<Transfer> getTransferTimeOut(long currentTime,int status);

    void updateTransferTimeOut(long currentTime,int status,Map<String,Object> map);

    public Transfer getTransferByYop(String orderNo);

    String queryTransferOverGroupCount(long startTime, long endTime);
}

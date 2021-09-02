package com.shiku.im.pay.dao;

import com.shiku.im.pay.entity.TransferReceive;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;

/**
 * @Description: TODO(转账收款)
 * 
 * @date 2019年8月26日 下午7:46:57
 * @version V1.0
 */
public interface TransferReceiveDao extends IMongoDAO<TransferReceive, ObjectId> {

    void addTransferReceive(TransferReceive entity);

    List<TransferReceive> getTransferReceiveList(int userId,int pageIndex,int pageSize);

}

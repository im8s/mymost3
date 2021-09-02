package com.shiku.im.msg.dao.impl;

import com.shiku.im.msg.dao.MsgForwardAmountDao;
import com.shiku.im.msg.entity.ForwardAmount;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/20 17:11
 */
@Repository
public class MsgForwardAmountDaoImpl extends MongoRepository<ForwardAmount, ObjectId> implements MsgForwardAmountDao {

   

    @Override
    public Class<ForwardAmount> getEntityClass() {
        return ForwardAmount.class;
    }

    @Override
	public void addForwardAmount(ForwardAmount forwardAmount) {

		// 持久化转发详情
		getDatastore().save(forwardAmount);

	}


	@Override
	public boolean exists(int userId, String msgId) {
		Query query = createQuery("msgId",msgId);
		addToQuery(query,"userId",userId);
		return exists(query);
	}

	@Override
	public List<ForwardAmount> find(ObjectId msgId, ObjectId forwardId, int pageIndex, int pageSize) {
		Query query=createQuery();
		if(null != forwardId){
			addToQuery(query,"_id",forwardId);
		}else{
			addToQuery(query,"msgId",msgId);
		}
		descByquery(query,"time");


		return queryListsByQuery(query,pageIndex,pageSize);
	}
}

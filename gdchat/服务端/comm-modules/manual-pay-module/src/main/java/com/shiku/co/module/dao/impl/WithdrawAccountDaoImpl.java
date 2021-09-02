package com.shiku.co.module.dao.impl;

import com.shiku.co.module.dao.WithdrawAccountDao;
import com.shiku.co.module.entity.WithdrawAccount;
import com.shiku.common.model.PageResult;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/12/2 17:13
 */
@Repository
public class WithdrawAccountDaoImpl extends MongoRepository<WithdrawAccount, ObjectId> implements WithdrawAccountDao {
    @Override
    public MongoTemplate getDatastore() {
        return super.getDatastore();
    }

    @Override
    public Class<WithdrawAccount> getEntityClass() {
        return WithdrawAccount.class;
    }

    @Override
    public void addWithdrawAccount(WithdrawAccount entity) {
        getDatastore().save(entity);
    }

    @Override
    public void deleteWithdrawAccount(ObjectId id) {
        deleteById(id);
    }

    @Override
    public void updateWithdrawAccount(ObjectId id, Map<String, Object> map) {
        Query query = createQuery("_id",id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        getDatastore().updateFirst(query,ops,getEntityClass());
    }

    @Override
    public PageResult<WithdrawAccount> getWithdrawAccountList(int userId,int pageIndex, int pageSize) {
        PageResult<WithdrawAccount> result = new PageResult<>();
        Query query = createQuery("userId",userId);
        if(0!= pageSize){
            query.with(createPageRequest(pageIndex,pageSize));
        }
        addToQuery(query,"status",1);
        descByquery(query,"createTime");
        result.setData(getDatastore().find(query,getEntityClass()));
        result.setCount(count(query));
        return result;
    }

    @Override
    public WithdrawAccount getWithdrawAccount(ObjectId id) {
        return get(id);
    }
}

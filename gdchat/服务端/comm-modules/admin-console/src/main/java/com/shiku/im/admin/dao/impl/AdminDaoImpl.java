package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.AdminDao;
import com.shiku.im.admin.entity.Admin;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 14:38
 */
@Repository
public class AdminDaoImpl extends MongoRepository<Admin, ObjectId> implements AdminDao {
    @Override
    public MongoTemplate getDatastore() {
        return super.getDatastore();
    }

    @Override
    public Class<Admin> getEntityClass() {
        return Admin.class;
    }

    @Override
    public void addAdmin(Admin admin) {
        getDatastore().save(admin);
    }

    @Override
    public Admin getAdminByAccount(String account) {
        return  queryOne("account", account);
    }

    @Override
    public Admin getAdminById(ObjectId adminId) {
        return get(adminId);
    }

    @Override
    public PageResult<Admin> getAdminList(String keyWorld, ObjectId adminId, int pageIndex, int pageSize) {
        PageResult<Admin> result = new PageResult<Admin>();

        Query query = createQuery();
        query.addCriteria(Criteria.where("_id").ne(adminId));

         //排除自己
        if (!StringUtil.isEmpty(keyWorld)) {
            query.addCriteria(Criteria.where("account").regex("account",keyWorld));
        }
        query.with(Sort.by(Sort.Order.desc("createTime")));
        query.with(createPageRequest(pageIndex,pageSize));
        result.setData(queryListsByQuery(query));
        result.setCount(count(query));

        return result;
    }

    @Override
    public void deleteAdmin(ObjectId id) {

        deleteByQuery(createQuery("_id",id));
    }

    @Override
    public boolean updateAdminPassword(ObjectId adminId, String newPwd) {
        Admin admin =queryOne("_id",adminId);
        admin.setPassword(newPwd);
        if(getDatastore().save(admin)!=null)
            return true;
        return false;
    }

    @Override
    public Admin updateAdmin(ObjectId adminId, Map<String, Object> map) {
        Query query = createQuery("_id",adminId);
        Update ops =createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        return getDatastore().findAndModify(query,ops,getEntityClass());
    }
}

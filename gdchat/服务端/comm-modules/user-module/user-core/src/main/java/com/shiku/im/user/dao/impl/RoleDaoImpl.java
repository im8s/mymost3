package com.shiku.im.user.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.RoleDao;
import com.shiku.im.user.entity.Role;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Repository
public class RoleDaoImpl extends MongoRepository<Role, ObjectId> implements RoleDao {


    @Override
    public Class<Role> getEntityClass() {
        return Role.class;
    }

    @Override
    public Role getUserRoleByUserId(Integer userId) {
        return findOne("userId", userId);
    }

    @Override
    public Role getUserRole(Integer userId, String phone, Integer type) {
        Query query = createQuery();
        if(0 != userId)
           addToQuery(query,"userId", userId);
        if(!StringUtil.isEmpty(phone))
           addToQuery(query,"phone", phone);
        if(null != type && 5 == type){
            int num=type+1;
            query.addCriteria(Criteria.where("role").in(Arrays.asList(type,num,1,4,7)));

        }
        return findOne(query);
    }

    @Override
    public List<Role> getUserRoleList(Integer userId, String phone, Integer type) {
        Query query = createQuery();
        if(0 != userId)
            addToQuery(query,"userId", userId);
        if(!StringUtil.isEmpty(phone))
            addToQuery(query,"phone", phone);
        if(null != type)
            addToQuery(query,"role", type);
        return queryListsByQuery(query);
    }

    @Override
    public PageResult<Role> getAdminRoleList(String keyWorld, int page, int limit, Integer type, Integer userId) {
        Query query =createQuery();
        if(0 == type){
            query.addCriteria(Criteria.where("role").in(Arrays.asList(5,6)));
            query.addCriteria(Criteria.where("userId").ne(userId)); //排除自己
        }else if(4 == type)
            addToQuery(query,"role",  4);// 客服
        else if(7 == type)
            addToQuery(query,"role",  7);// 财务
        else if(3 == type)
            addToQuery(query,"role",  3);// 机器人
        else if(1 == type)
            addToQuery(query,"role", 1);// 游客
        else if(2 == type)
            addToQuery(query,"role",  2);// 公众号
        if (!StringUtil.isEmpty(keyWorld)) {
            query.addCriteria(containsIgnoreCase("phone",keyWorld));
        }
        descByquery(query,"createTime");
        PageResult<Role> pageResult = new PageResult<>();
        pageResult.setData(queryListsByQuery(query,page,limit,1));
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public void setAdminRole(String telePhone, String phone, byte role, Integer type) {

    }

    @Override
    public void deleteAdminRole(Integer userId, Integer type) {
        Query query = createQuery("userId", userId);
        addToQuery(query,"role",userId);
        deleteByQuery(query);
    }

    @Override
    public Role updateRole(Role role) {
        Query query = createQuery("userId", role.getUserId());
        addToQuery(query,"role",role.getRole());
        Update ops = createUpdate();
        if(role.getRole() != 0) {
            ops.set("role", role.getRole());
        }

        if(role.getStatus() != 0) {
            ops.set("status", role.getStatus());
        }

        if(0 != role.getLastLoginTime())
            ops.set("lastLoginTime", role.getLastLoginTime());
        if(!StringUtil.isEmpty(role.getPromotionUrl())){
            ops.set("promotionUrl", role.getPromotionUrl());
        }
        return getDatastore().findAndModify(query, ops,getEntityClass());
    }

    @Override
    public void deleteRole(Integer userId) {
      deleteByAttribute("userId",userId);
    }

    @Override
    public void addRole(Role role) {
        getDatastore().save(role);
    }

    @Override
    public Role updateRole(int userId, byte role, Map<String, Object> map) {
        Query query =  createQuery("userId", userId);
        addToQuery(query,"role",role);
		Update ops = createUpdate();
		map.forEach((key,value)->{
		    ops.set(key,value);
        });
        return getDatastore().findAndModify(query,ops,getEntityClass());
    }
}

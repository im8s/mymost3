package com.shiku.im.user.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.Role;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface RoleDao extends IMongoDAO<Role, ObjectId> {

    Role getUserRoleByUserId(Integer userId);

    Role getUserRole(Integer userId,String phone,Integer type);

    List<Role> getUserRoleList(Integer userId,String phone,Integer type);

    PageResult<Role> getAdminRoleList(String keyWorld, int page, int limit, Integer type, Integer userId);

    void setAdminRole(String telePhone, String phone, byte role, Integer type);

    void deleteAdminRole(Integer userId,Integer type);

    Role updateRole(Role role);

    Role updateRole(int userId, byte role, Map<String,Object> map);

    void deleteRole(Integer userId);

    void addRole(Role role);
}

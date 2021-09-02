package com.shiku.im.admin.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.entity.Admin;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.Map;

public interface AdminDao extends IMongoDAO<Admin, ObjectId> {

    void addAdmin(Admin admin);

    Admin getAdminByAccount(String account);

    Admin getAdminById(ObjectId adminId);

    PageResult<Admin> getAdminList(String keyWorld, ObjectId adminId, int pageIndex, int pageSize);

    void deleteAdmin(ObjectId id);

    boolean updateAdminPassword(ObjectId adminId,String newPwd);

    Admin updateAdmin(ObjectId adminId, Map<String,Object> map);
}

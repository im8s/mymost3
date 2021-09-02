package com.shiku.im.user.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.InviteCode;
import org.bson.types.ObjectId;

public interface InviteCodeDao extends IMongoDAO<InviteCode, ObjectId> {

    void addInviteCode(InviteCode inviteCode);

    InviteCode findUserInviteCode(int userId);

    PageResult<InviteCode> getInviteCodeList(int userId, String keyworld, short status, int pageIndex, int pageSize);

    boolean deleteInviteCode(int userId,ObjectId inviteCodeId);

    InviteCode findInviteCodeByCode(String inviteCode);
}

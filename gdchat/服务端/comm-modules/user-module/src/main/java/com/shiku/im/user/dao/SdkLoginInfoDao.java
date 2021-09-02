package com.shiku.im.user.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.model.SdkLoginInfo;
import org.bson.types.ObjectId;

import java.util.List;

public interface SdkLoginInfoDao extends IMongoDAO<SdkLoginInfo,ObjectId> {

    SdkLoginInfo addSdkLoginInfo(int type, Integer userId, String loginInfo);

    void deleteSdkLoginInfo(int type,Integer userId);

    List<SdkLoginInfo> querySdkLoginInfoByUserId(Integer userId);

    SdkLoginInfo findSdkLoginInfo(int type, String loginInfo);

    SdkLoginInfo getSdkLoginInfo(int type,Integer userId);

    PageResult<SdkLoginInfo> getSdkLoginInfoList(int pageIndex, int pageSize, String keyword);

    void deleteSdkLoginInfo(ObjectId id);

    void deleteSdkLoginInfoByUserId(int userId);
}

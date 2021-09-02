package com.shiku.im.open.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface SkOpenAppDao extends IMongoDAO<SkOpenApp, ObjectId> {

    void addSkOpenApp(SkOpenApp skOpenApp);

    SkOpenApp getSkOpenApp(ObjectId id);

    SkOpenApp getSkOpenApp(String appId);

    SkOpenApp getSkOpenApp(String appName,byte appType);

    PageResult<SkOpenApp> getSkOpenAppList(int status, int type, int pageIndex, int limit, String keyword);

    void deleteSkOpenApp(ObjectId id,String accountId);

    List<SkOpenApp> getSkOpenAppList(String accountId,int appType,int pageIndex,int pageSize);

    void updateSkOpenApp(ObjectId id,String accountId, Map<String,Object> map);

    SkOpenApp findByAppIdAndSecret(String appId,String secret);
}

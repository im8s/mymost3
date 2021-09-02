package com.shiku.im.open.dao.impl;

import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.open.dao.HelperDao;
import com.shiku.im.open.entity.GroupHelper;
import com.shiku.im.open.entity.Helper;
import com.shiku.im.open.opensdk.entity.SkOpenApp;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class HelperDaoImpl extends MongoRepository<Helper, ObjectId> implements HelperDao {

    @Override
    public Class<Helper> getEntityClass() {
        return Helper.class;
    }

    @Override
    public Helper getHelper(ObjectId id) {
        return get(id);
    }

    @Override
    public List<Helper> getHelperList(String openAppId,int pageIndex,int pageSize) {
       Query query = createQuery();
        if(!StringUtil.isEmpty(openAppId)){
            addToQuery(query,"openAppId",openAppId);
        }
        if(pageSize!=0){
             query.with(createPageRequest(pageIndex,pageSize));
        }
        return queryListsByQuery(query);
    }

    @Override
    public void deleteHelper(String openAppId) {
       Query query = createQuery("openAppId",openAppId);
       deleteByQuery(query);
    }

    @Override
    public void updateHelper(Helper entity) {
        Query query = createQuery(entity.getId());
        Update ops =createUpdate();
        if(!StringUtil.isEmpty(entity.getName())){
            ops.set("name", entity.getName());
        }
        if(!StringUtil.isEmpty(entity.getDesc())){
            ops.set("desc", entity.getDesc());
        }
        if(!StringUtil.isEmpty(entity.getDeveloper())){
            ops.set("developer", entity.getDeveloper());
        }
        if(!StringUtil.isEmpty(entity.getIconUrl())){
            ops.set("iconUrl", entity.getIconUrl());
        }
        if(!StringUtil.isEmpty(entity.getLink())){
            ops.set("link", entity.getLink());
        }
        if(!StringUtil.isEmpty(entity.getAppPackName())){
            ops.set("appPackName", entity.getAppPackName());
        }
        if(!StringUtil.isEmpty(entity.getCallBackClassName())){
            ops.set("callBackClassName", entity.getCallBackClassName());
        }
        if(null!=entity.getOther()){
            ops.set("other", entity.getOther());
        }
        ops.set("type", entity.getType());
        update(query,ops);
    }

    @Override
    public void deleteHelper(Integer userId, ObjectId id) {
        Query query = createQuery(id);
        Helper helper = findOne(query);
            Query queryOpenApp = createQuery("_id",new ObjectId(helper.getOpenAppId()));
        SkOpenApp one = getDatastore().findOne(queryOpenApp,SkOpenApp.class);
        if(one!=null){
                // 判断是否为本人操作
                if(Integer.valueOf(one.getAccountId()).equals(userId)){

                    Query groupHelQuery = createQuery("helperId",helper.getId().toString());
                    getDatastore().remove(groupHelQuery, GroupHelper.class);

                    deleteByQuery(query);
                }else{
                    throw new ServiceException("应用不存在，删除失败");
                }

        }else {
            throw new ServiceException("群助手不存在，删除失败");
        }
    }
}

package com.shiku.im.company.dao.impl;

import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.company.dao.CommonTextDao;
import com.shiku.im.company.entity.CommonText;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/6 14:35
 */
@Repository
public class CommonTextDaoImpl extends MongoRepository<CommonText, ObjectId> implements CommonTextDao {


    @Override
    public Class<CommonText> getEntityClass() {
        return CommonText.class;
    }

    @Override
    public CommonText addCommonText(CommonText commonText) {
        commonText.setCreateTime(DateUtil.currentTimeSeconds());//创建时间
        commonText.setCreateUserId(ReqUtil.getUserId());//创建人
        commonText.setModifyUserId(ReqUtil.getUserId());//修改人
        getDatastore().save(commonText);
        return commonText;
    }

    @Override
    public boolean deleteCommonText(String commonTextId) {
        ObjectId commonTextIds = new ObjectId(commonTextId);

        deleteById(commonTextIds);
        return true;
    }

    @Override
    public List<CommonText> commonTextGetByCommpanyId(String companyId, int pageIndex, int pageSize) {
        ObjectId companyIds = new ObjectId(companyId);
        Query query = createQuery("companyId", companyIds);
        
        //根据创建时间倒叙
        List<CommonText> commonTextList = queryListsByQuery(query,
                pageIndex,pageSize);

        return commonTextList;
    }

    @Override
    public List<CommonText> commonTextGetByUserId(int userId, int page, int limit) {
        Query query =createQuery("companyId", "0");
        addToQuery(query,"createUserId", userId);
        //根据创建时间倒叙
        List<CommonText> commonTextList = queryListsByQuery(query,page,limit);
        return commonTextList;
    }

    @Override
    public CommonText commonTextModify(CommonText commonText) {
        if (!StringUtil.isEmpty(commonText.getId().toString())) {
            //根据常用语id来查询出数据
            Query query = createQuery("_id",commonText.getId());
            //修改
            Update update = createUpdate();
            //赋值
            if (null!=commonText.getContent()) {
                update.set("content", commonText.getContent());
            }
            update.set("modifyUserId", ReqUtil.getUserId());
            update.set("createTime", DateUtil.currentTimeSeconds());

            update(query,update);
        }
        return commonText;
    }
}

package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.ErrorMessageDao;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.model.ErrorMessage;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 11:32
 */
@Repository
public class ErrorMessageDaoImpl extends MongoRepository<ErrorMessage, ObjectId> implements ErrorMessageDao {

    @Override
    public Class<ErrorMessage> getEntityClass() {
        return ErrorMessage.class;
    }

    @Override
    public void addErrorMessage(ErrorMessage errorMessage) {
        getDatastore().save(errorMessage);
    }

    @Override
    public PageResult getErrorMessageList(String keyword, int pageIndex, int pageSize) {
        PageResult pageResult = new PageResult();
        Query query=createQuery();
        if(!StringUtil.isEmpty(keyword)){
            addToQuery(query,"code", keyword);
        }
        List<ErrorMessage> errorMessages =queryListsByQuery(query,pageIndex,pageSize);
        pageResult.setData(errorMessages);
        pageResult.setCount(count(query));
        return pageResult;
    }

    @Override
    public void deleteErrorMessage(String code) {
        Query query=createQuery("code", code);
       deleteByQuery(query);
    }

    @Override
    public ErrorMessage getErrorMessage(String code) {
        return queryOne("code",code);
    }

    @Override
    public ErrorMessage getErrorMessage(ObjectId id) {
        return get(id);
    }

    @Override
    public ErrorMessage updateErrorMessage(ObjectId id, ErrorMessage errorMessage) {

        Update ops = createUpdate();

        Query qCode=createQuery("code", errorMessage.getCode());
        qCode.addCriteria(Criteria.where("_id").ne(errorMessage.getId()));
        if(null!=findOne(qCode)){
            throw new ServiceException("当前code已被注册");
        }
        Query query=createQuery("_id",id);
        logger.info(errorMessage.toString());
        ErrorMessage dbMsb = findOne(query);
        if(null==dbMsb)
            throw new ServiceException("数据不存在！");
        if(StringUtil.isEmpty(errorMessage.getCode())){
            ops.set("code",errorMessage.getCode());
        }
        if(null!=errorMessage.getType()){
            ops.set("type", errorMessage.getType());
        }
        if(StringUtil.isEmpty(errorMessage.getCode())){
            ops.set("code",errorMessage.getCode());
        }
        if(StringUtil.isEmpty(errorMessage.getZh())){
            ops.set("zh",errorMessage.getZh());
        }
        if(StringUtil.isEmpty(errorMessage.getEn())){
            ops.set("en",errorMessage.getEn());
        }
        if(StringUtil.isEmpty(errorMessage.getBig5())){
            ops.set("big5",errorMessage.getBig5());
        }
        return getDatastore().findAndModify(query, ops,getEntityClass());
    }
}

package com.shiku.im.admin.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.admin.dao.MsgInferceptDAO;
import com.shiku.im.admin.entity.KeyWord;
import com.shiku.im.admin.entity.MsgIntercept;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class MsgInferceptDaoImpl extends MongoRepository<MsgIntercept, ObjectId> implements MsgInferceptDAO {

    @Override
    public Class<MsgIntercept> getEntityClass() {
        return MsgIntercept.class;
    }

    // 新增关键词
    @Override
    public void saveKeyword(KeyWord keyWord){
        getDatastore().save(keyWord);
    }

    // 更新关键词
    @Override
    public void updateKeyword(String word, ObjectId id){
        Query query =createQuery(id);
        Update ops = createUpdate();
        ops.set("word", word);
        ops.set("createTime", DateUtil.currentTimeSeconds());
        update(query, ops);
    }

    // 删除关键词
    @Override
    public void deleteKeyword(ObjectId id){
        Query query = createQuery(id);
        getDatastore().remove(query,KeyWord.class);
        //deleteById(id);
    }

    // 查询关键词列表
    @Override
    public List<KeyWord> queryKeywordList(String word, int pageIndex, int pageSize){
        Query query = createQuery();
        if (!StringUtil.isEmpty(word)) {
            addToQuery(query,"word", word);
        }
        descByquery(query,"createTime");

        return getDatastore().find(query,KeyWord.class);
    }

    // 查询拦截消息列表
    @Override
    public List<MsgIntercept> queryMsgInerceptList(Integer userId, String toUserId, int pageIndex, int pageSize, int type, String content){
        Query query = createQuery();
        if(!StringUtil.isEmpty(content)){
            addToQuery(query,"content", content);
        }
        if(null != userId){
            addToQuery(query,"sender", userId);
        }
        if(type==0){
            if(!StringUtil.isEmpty(toUserId)){
                addToQuery(query,"receiver", Integer.valueOf(toUserId));
            }
            addToQuery(query,"roomJid",null);
        }else if(type==1){
            if(!StringUtil.isEmpty(toUserId)){
                addToQuery(query,"roomJid", toUserId);
            }
            query.addCriteria(Criteria.where("roomJid").ne(null));
        }
        return getDatastore().find(query,MsgIntercept.class);
    }

    // 删除拦截消息
    @Override
    public void deleteMsgIntercept(ObjectId id){
        Query query = createQuery(id);
        getDatastore().remove(query,MsgIntercept.class);
    }

    @Override
    public PageResult<KeyWord> queryKeywordPageResult(String word, int page, int limit) {
        PageResult<KeyWord> result = new PageResult<KeyWord>();
        Query query = createQuery();
        if (!StringUtil.isEmpty(word)) {
            addToQuery(query,"word", word);
        }
        descByquery(query,"createTime");
        result.setCount(getDatastore().count(query,KeyWord.class));
        query.with(createPageRequest(page, limit, 1));
        result.setData(getDatastore().find(query,KeyWord.class));
        return result;
    }

    @Override
    public PageResult<MsgIntercept> webQueryMsgInterceptList(Integer userId, String toUserId, int pageIndex, int pageSize, int type, String content) {
        PageResult<MsgIntercept> data = new PageResult<>();
        Query query = createQuery();

        //时间降序排序
        query.with(Sort.by(Sort.Order.desc("createTime")));

        if(!StringUtil.isEmpty(content)){
//            addToQuery(query,"content", content);
            query.addCriteria(
                    new Criteria().orOperator(Criteria.where("content").regex(content)));
        }
        if(null != userId){
            addToQuery(query,"sender", userId);
        }
        if(type==0){
            if(!StringUtil.isEmpty(toUserId)){
                addToQuery(query,"receiver", Integer.valueOf(toUserId));
            }
            addToQuery(query,"roomJid",null);
        }else if(type==1){
            if(!StringUtil.isEmpty(toUserId)){
                addToQuery(query,"roomJid", toUserId);
            }
            query.addCriteria(Criteria.where("roomJid").ne(null));
        }
        getDatastore().find(query,MsgIntercept.class);
        data.setData(queryListsByQuery(query,pageIndex,pageSize,1));
        data.setCount(count(query));
        return data;
    }
}

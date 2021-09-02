package com.shiku.im.msg.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.dao.MusicDao;
import com.shiku.im.msg.entity.MusicInfo;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/2 17:55
 */
@Repository
public class MusicDaoImpl extends MongoRepository<MusicInfo, ObjectId> implements MusicDao {


    @Override
    public Class<MusicInfo> getEntityClass() {
        return MusicInfo.class;
    }

    @Override
    public void addMusicInfo(MusicInfo musicInfo) {
        getDatastore().save(musicInfo);
    }

    @Override
    public void deleteMusicInfo(ObjectId id) {
       deleteById(id);
    }

    @Override
    public MusicInfo getMusicInfoById(ObjectId id) {
        return get(id);
    }

    @Override
    public List<MusicInfo> getMusicInfoList(int pageIndex, int pageSize, String keyword) {
        Query query = createQuery();
        if(!StringUtil.isEmpty(keyword)){
            Criteria criteria = createCriteria().orOperator(contains("name", keyword), contains("nikeName", keyword));
            query.addCriteria(criteria);
        }
        descByquery(query,"useCount");
        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public void updateMusicInfo(ObjectId id, Map<String, Object> map) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });

        update(query,ops);
    }

    @Override
    public PageResult<MusicInfo> getMusicInfo(int pageIndex, int pageSize, String keyword) {
        PageResult<MusicInfo> result=new PageResult<>();
        Query query=createQuery();
        if(!StringUtil.isEmpty(keyword)){
            Criteria criteria = createCriteria().orOperator(contains("name", keyword), contains("nikeName", keyword));
            query.addCriteria(criteria);
        }

        descByquery(query,"useCount");
        result.setCount(count(query));
        result.setData(queryListsByQuery(query,pageIndex,pageSize,1));
        return result;
    }
}

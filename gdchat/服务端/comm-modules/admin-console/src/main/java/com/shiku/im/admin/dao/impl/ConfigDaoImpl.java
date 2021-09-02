package com.shiku.im.admin.dao.impl;

import com.shiku.im.admin.dao.ConfigDao;
import com.shiku.im.entity.Config;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.utils.SKBeanUtils;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;


/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 12:30
 */
@Repository
public class ConfigDaoImpl extends MongoRepository<Config, Long> implements ConfigDao {

    @Override
    public Class<Config> getEntityClass() {
        return Config.class;
    }

    @Override
    public Config getConfig() {
        Query query=createQuery();
        query.addCriteria(Criteria.where("_id").ne(null));
        return findOne(query);
    }

    @Override
    public void updateConfig(int isOpenPrivacyPosition){
        Query query=createQuery().addCriteria(Criteria.where("_id").ne(null));
        Update ops = createUpdate();
        ops.set("isOpenPrivacyPosition", isOpenPrivacyPosition);
        Config config;
        FindAndModifyOptions find = new FindAndModifyOptions();
        config = getDatastore().findAndModify(query, ops,new FindAndModifyOptions().returnNew(true),getEntityClass());
        SKBeanUtils.getImCoreService().setConfig(config);
    }

    @Override
    public void addConfig(Config config) {
        getDatastore().save(config);
    }
}

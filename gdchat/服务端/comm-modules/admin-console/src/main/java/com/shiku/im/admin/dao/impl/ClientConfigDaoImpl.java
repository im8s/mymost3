package com.shiku.im.admin.dao.impl;

import com.shiku.im.admin.dao.ClientConfigDao;
import com.shiku.im.entity.ClientConfig;
import com.shiku.im.repository.MongoRepository;
import org.springframework.stereotype.Repository;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/3 12:33
 */
@Repository
public class ClientConfigDaoImpl extends MongoRepository<ClientConfig, Long> implements ClientConfigDao {


    @Override
    public Class<ClientConfig> getEntityClass() {
        return ClientConfig.class;
    }

    @Override
    public void addClientConfig(ClientConfig clientConfig) {
        getDatastore().save(clientConfig);
    }

    @Override
    public ClientConfig getClientConfig(long id) {
       return get(id);
    }
}

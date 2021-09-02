package com.shiku.im.admin.dao;


import com.shiku.im.entity.ClientConfig;
import com.shiku.im.repository.IMongoDAO;

public interface ClientConfigDao extends IMongoDAO<ClientConfig, Long> {

    void addClientConfig(ClientConfig clientConfig);

    ClientConfig getClientConfig(long id);

}

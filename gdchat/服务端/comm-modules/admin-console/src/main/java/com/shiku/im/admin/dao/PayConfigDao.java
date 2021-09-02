package com.shiku.im.admin.dao;

import com.shiku.im.entity.PayConfig;
import com.shiku.im.repository.IMongoDAO;

public interface PayConfigDao extends IMongoDAO<PayConfig,Long> {

    PayConfig getPayConfig();

    void addPayConfig(PayConfig payConfig);
}

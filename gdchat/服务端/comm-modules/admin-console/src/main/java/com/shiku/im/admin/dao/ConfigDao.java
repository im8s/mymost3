package com.shiku.im.admin.dao;


import com.shiku.im.entity.Config;
import com.shiku.im.repository.IMongoDAO;

public interface ConfigDao extends IMongoDAO<Config, Long> {

    Config getConfig();

    void addConfig(Config config);

    void updateConfig(int isOpenPrivacyPosition);
}

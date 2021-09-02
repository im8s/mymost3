package com.shiku.im.user.dao;

import com.shiku.im.repository.IMongoDAO;
import com.shiku.im.user.entity.AuthKeys;

import java.util.List;
import java.util.Map;

public interface AuthKeysDao extends IMongoDAO<AuthKeys, Integer> {

    void addAuthKeys(AuthKeys authKeys);

    AuthKeys getAuthKeys(int userId);

    AuthKeys queryAuthKeys(int userId);

    boolean updateAuthKeys(int userId, Map<String,Object> map);

    Object queryOneFieldByIdResult(String key,int userId);

    Map<String,String> queryUseRSAPublicKeyList(List<Integer> userList);

    void deleteAuthKeys(int userId);

    List<AuthKeys> getYopNotNull();

}

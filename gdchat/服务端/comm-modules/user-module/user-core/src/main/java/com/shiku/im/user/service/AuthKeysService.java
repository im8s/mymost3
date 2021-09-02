package com.shiku.im.user.service;

import com.shiku.im.user.entity.AuthKeys;

import java.util.List;
import java.util.Map;

public interface AuthKeysService {

    List<AuthKeys> getYopNotNull();

    AuthKeys getAuthKeys(int userId);

    String getPayPublicKey(int userId);

    void cleanTransactionSignCode(int userId, String codeId);

    String queryTransactionSignCode(int userId, String codeId);


    void deleteAuthKeys(int userId);

    public void save(AuthKeys authKeys);

    public void update(int userId, Map<String,Object> map);

    String getPayPassword(Integer userId);
}

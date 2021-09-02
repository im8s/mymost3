package com.shiku.im.user.service;

import com.shiku.im.user.entity.User;
import com.shiku.im.user.model.KSession;
import com.shiku.im.user.model.UserExample;

public interface UserHandler {

    void registerToIM(String userId,String pwd);

    void registerHandler(String userId,String pwd,String nickname);

    void registerBeforeHandler(int userId,UserExample example);

    void registerAfterHandler(int userId,UserExample example);

    void changePasswordHandler(User user, String oldPwd, String newPwd);

    void updateNickNameHandler(int userId, String newNickName);

    void deleteUserHandler(int adminUserId,int userId);

    void userOnlineHandler(int userId);

    void refreshUserSessionHandler(int userId, KSession session);

    void clearUserSessionHandler(String accessToken);


    void publishEvent(Object event);
}

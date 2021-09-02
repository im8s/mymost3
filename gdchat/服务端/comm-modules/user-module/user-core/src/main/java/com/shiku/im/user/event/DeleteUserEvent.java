package com.shiku.im.user.event;

import lombok.Getter;
import lombok.Setter;


/**
 * 删除用户事件
 */
@Setter
@Getter
public class DeleteUserEvent {


    public DeleteUserEvent(int adminUserId,int userId) {
        this.adminUserId=adminUserId;
        this.userId = userId;
    }
    public int adminUserId;
    private int userId;
}

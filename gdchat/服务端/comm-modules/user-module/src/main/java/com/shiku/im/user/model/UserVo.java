package com.shiku.im.user.model;

import com.shiku.im.company.entity.Company;
import com.shiku.im.friends.entity.Friends;
import com.shiku.im.user.entity.User;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Setter
@Getter
public class UserVo extends User {



    // 朋友圈访问权限，不看他
    
    private boolean notSeeHim;

    // 朋友圈访问权限，不让他看
    private  boolean notLetSeeHim;

    private Company company;// 所属公司

    private Friends friends;// 好友关系
    // 第三方帐号列表
    private  List<ThridPartyAccount> accounts;

    // 关注列表
    private  List<Friends> attList;
    // 好友列表
    private  List<Friends> friendsList;

    
    private String model;// 登录设备
    
    private long showLastLoginTime;// 最后上线时间


    /**
     * 不是 本人 调用  设置 返回字段
     * @param ReqUserId  请求者UserId
     */
    public void buildNoSelfUserVo(int ReqUserId) {
        this.setPassword(null);
        this.setOpenid(null);
        this.setAliUserId(null);
        this.setAttCount(0);
        this.setFansCount(0);
        this.setFriendsCount(0);
        this.setMsgNum(0);
        this.setUserKey(null);
        this.setLoginLog(null);
        this.setOfflineNoPushMsg(null);
        this.setPayPassword(null);
        this.setTotalRecharge(0.0);
        this.setTotalConsume(0.0);
        //获取他人的用户信息,只返回对应用户的公钥,不返回私钥
        this.setDhMsgPrivateKey(null);
        this.setRsaMsgPrivateKey(null);

        //用户与请求者为好友关系
        if(this.getFriends()!=null && Friends.Status.Friends==this.getFriends().getStatus()) {
            this.getFriends().setDhMsgPublicKey(this.getDhMsgPublicKey());
            this.getFriends().setRsaMsgPublicKey(this.getRsaMsgPublicKey());
        }

        this.setDhMsgPublicKey(null);
        this.setRsaMsgPublicKey(null);
    }


}

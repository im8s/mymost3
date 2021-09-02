package com.shiku.im.user.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.shiku.commons.thread.Callback;
import com.shiku.commons.thread.ThreadUtils;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.model.MessageBean;
import com.shiku.im.comm.utils.DateUtil;
import com.shiku.im.comm.utils.RandomUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.company.service.CompanyManager;
import com.shiku.im.config.AppConfig;
import com.shiku.im.friends.service.impl.AddressBookManagerImpl;
import com.shiku.im.friends.service.impl.FriendGroupManagerImpl;
import com.shiku.im.friends.service.impl.FriendsManagerImpl;
import com.shiku.im.message.IMessageRepository;
import com.shiku.im.message.MessageService;
import com.shiku.im.room.dao.RoomDao;
import com.shiku.im.room.dao.RoomNoticeDao;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.RoomManager;
import com.shiku.im.user.dao.InviteCodeDao;
import com.shiku.im.user.entity.InviteCode;
import com.shiku.im.user.entity.Role;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.event.DeleteUserEvent;
import com.shiku.im.user.event.UserChageNameEvent;
import com.shiku.im.user.model.KSession;import com.shiku.im.user.model.UserExample;
import com.shiku.im.user.service.impl.RoleManagerImpl;
import com.shiku.im.utils.SKBeanUtils;
import jodd.util.ThreadUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;

import java.util.ArrayList;
import java.util.List;


public abstract class AbstractUserHandlerImpl implements UserHandler {

    @Autowired
    protected IMessageRepository messageRepository;

    @Autowired
    protected InviteCodeDao inviteCodeDao;

    @Autowired
    protected RoleManagerImpl roleManager;

    @Autowired
    protected FriendsManagerImpl friendsManager;

    @Autowired
    protected RoomManager roomManager;

    @Autowired
    protected RoomDao roomDao;


    @Autowired
    protected CompanyManager companyManager;


    @Autowired
    protected AddressBookManagerImpl addressBookManager;



    @Autowired
    protected FriendGroupManagerImpl friendGroupManager;

    @Autowired
    protected UserCoreService userCoreService;

    @Autowired
    @Lazy
    protected MessageService messageService;

    @Autowired
    protected AppConfig appConfig;



    @Override
    public void registerHandler(String userId, String pwd, String nickname) {

    }

    @Override
    public void registerBeforeHandler(int userId, UserExample example) {
        // 核验邀请码,及相关操作
        checkInviteCode(example,userId);
    }

    @Override
    public void registerAfterHandler(int userId, UserExample example){

        friendsManager.addFriends(userId, 10000);
        // 默认成为好友
        defaultTelephones(example, userId);
        // 调用组织架构功能示例方法
        companyManager.autoJoinCompany(userId);
        // 自动创建 好友标签
        friendGroupManager.autoCreateGroup(userId);
        if(example.getUserType()!=null){
            if(example.getUserType()==3){
                roomManager.join(userId, new ObjectId("5a2606854adfdc0cd071485e"),3);
            }
        }
        //更新通讯录好友
        long time = DateUtil.currentTimeSeconds();
        addressBookManager.notifyBook(example.getTelephone(), userId, example.getNickname(),time);
        // 清除redis中没有系统号的表

        // 维护公众号角色
        if (example.getUserType()!=null && example.getUserType() == 2) {
            Role role = new Role(userId, example.getTelephone(), (byte)2, (byte)1, 0);
            roleManager.getRoleDao().addRole(role);
            roleManager.updateFriend(userId, 2);
        }
    }


    @Override
    public void registerToIM(String userId, String pwd) {
        messageRepository.registerAndXmppVersion(userId,pwd);
    }

    @Override
    public void changePasswordHandler(User user, String oldPwd, String newPwd) {
        messageRepository.changePassword(user.getUserId()+"", user.getPassword(), newPwd);
    }

    /** @Description:（注册默认成为好友）
     * @param example
     * @param userId
     **/
    private void defaultTelephones(UserExample example, Integer userId) {
        List<Integer> idList = null;
        Room createRoom = null;
        JSONObject userKeys = null;

        //获取开关
        byte registerCreateRoom = appConfig.getRegisterCreateRoom();
        if (1==registerCreateRoom){
            //创建群
            createRoom = new Room();
            //设置群昵称
            createRoom.setName(example.getNickname()+"的群组");
            //设置群成员
            idList = new ArrayList<>();
            //设置userKeys
            userKeys =  JSON.parseObject("");
        }

        // 注册默认成为好友
        String telephones =SKBeanUtils.getSystemConfig().getDefaultTelephones();
        //log.info(" config defaultTelephones : " + telephones);

        //默认和邀请者成为好友
        if (null != example.getInvitedUserId()) {
            friendsManager.addFriends(userId, example.getInvitedUserId());
        }

        if (!StringUtil.isEmpty(telephones)) {
            String[] phones = StringUtil.getStringList(telephones);
            for (int i = 0; i < phones.length; i++) {
                try {
                    System.out.println("defaule: "+new StringBuffer().append(phones[i]).toString());
                    User user = userCoreService.getUser(new StringBuffer().append(phones[i]).toString());
                    if(null == user)
                        continue;
                    //friendsManager.followUser(userId, user.getUserId(),0);
                    friendsManager.addFriends(userId, user.getUserId());// 过滤好友验证直接成为好友

                    //加入成员
                    if (1==registerCreateRoom && null != user){
                        idList.add(user.getUserId());
                    }
                } catch (Exception e) {
                    continue;
                }
            }
            //创建群
            if (1==registerCreateRoom){
                String roomNotice =SKBeanUtils.getImCoreService().getConfig().getRoomNotice();
                /**
                 * 默认建群公告提示
                 */
                if(!StringUtil.isEmpty(roomNotice)){
                    createRoom.setId(ObjectId.get());
                    Room.Notice notice=new Room.Notice();
                    notice.setText(roomNotice);
                    notice.setTime(DateUtil.currentTimeSeconds());
                    notice.setUserId(idList.get(0));
                    notice.setNickname(userCoreService.getNickName(idList.get(0)));
                    notice.setId(ObjectId.get());
                    notice.setRoomId(createRoom.getId());
                    createRoom.setJid(StringUtil.randomUUID());
                    createRoom.setNotice(notice);

                    roomManager.add(userCoreService.getUser(userId), createRoom, idList,userKeys);
                    final List<Integer> list = idList;
                    final Room room = createRoom;
                    ThreadUtils.executeInThread(new Callback() {
                        @Override
                        public void execute(Object obj) {
                            sendNoticeMessageToGroup(list,notice,room.getJid());
                        }
                    },5);
                }else {
                    roomManager.add(userCoreService.getUser(userId), createRoom, idList,userKeys);
                }

            }
        }
    }

    @Autowired
    private RoomNoticeDao roomNoticeDao;
    private void sendNoticeMessageToGroup(List<Integer> idList,Room.Notice notice,String jid){
        if(null==idList||idList.size()==0){
           return;
        }
        Integer sendUserId = idList.get(0);

        roomNoticeDao.addNotice(notice);
        try {
            roomManager.updateNotice(notice.getRoomId(),notice.getId(),notice.getText(),sendUserId);
        }catch (Exception e){
            e.printStackTrace();
        }


        ThreadUtils.executeInThread(new Callback() {
            @Override
            public void execute(Object obj) {
                MessageBean messageBean = new MessageBean();
                messageBean.setType(1);
                messageBean.setFromUserId(sendUserId.toString());
                messageBean.setFromUserName(userCoreService.getNickName(sendUserId));
                messageBean.setContent(notice.getText());
//        messageBean.setObjectId(jid);
                messageBean.setMessageId(StringUtil.randomUUID());
                messageBean.setTo(jid);
                messageBean.setToUserId(jid);
                messageService.sendMsgToGroupByJid(jid,messageBean);
            }
        },1);
     }

    @Override
    public void updateNickNameHandler(int userId, String newNickName) {
        this.publishEvent(new UserChageNameEvent(userId,newNickName));

    }
    @Override
    public void userOnlineHandler(int userId) {

    }

    @Override
    public void refreshUserSessionHandler(int userId, KSession session) {

    }

    @Override
    public void clearUserSessionHandler(String accessToken) {

    }

    @Override
    public void deleteUserHandler(int adminUserId,int userId) {
        this.publishEvent(new DeleteUserEvent(adminUserId,userId));
        // 删除用户关系
        friendsManager.deleteFansAndFriends(userId);
        // 删除通讯录好友
        addressBookManager.delete(null, null, userId);
        // 删除用户的角色信息
        roleManager.deleteAllRoles(userId);
        // 删除用户组织架构相关信息
        companyManager.delCompany(userId);

    }

    /**
     * 检查注册邀请码的及相关处理
     * @return
     */
    private void checkInviteCode(UserExample example,int userId){

        //获取系统当前的邀请码模式 0:关闭   1:开启一对一邀请(一码一用)    2:开启一对多邀请(一码多用)
        int inviteCodeMode = SKBeanUtils.getImCoreService().getConfig().getRegisterInviteCode();

        if(inviteCodeMode==0) { //关闭
            return;
        }

        InviteCode inviteCode = inviteCodeDao.findInviteCodeByCode(example.getInviteCode());
        if (null != inviteCode && 0 != inviteCode.getUserId()) {
            //设置来自邀请者的uid
            example.setInvitedUserId(inviteCode.getUserId());
        }

        boolean isNeedUpdateInvateCode = false; //是否需要更新邀请码数据

        if(inviteCodeMode==1) { //开启一对一邀请
            //该模式下邀请码为必填项
            if(StringUtil.isEmpty(example.getInviteCode())) {
                throw new ServiceException("请填写邀请码");
            }
            //检查用户填写的邀请码的合法性
            if(inviteCode==null || !(inviteCode.getTotalTimes()==1 && inviteCode.getStatus()==0) ){ //status = 0; //状态值 0,为初始状态未使用   1:已使用  -1 禁用
                throw new ServiceException("邀请码无效或已被使用");
            }
            isNeedUpdateInvateCode = true;
            //给注册用户生成一个自己的一对一邀请码
            String inviteCodeStr = RandomUtil.idToSerialCode(DateUtil.currentTimeSeconds()+ userCoreService.createInviteCodeNo(1)+1); //生成邀请码
            inviteCodeDao.addInviteCode(new InviteCode(userId, inviteCodeStr, System.currentTimeMillis(), 1));
            example.setMyInviteCode(inviteCodeStr);

        }else if(inviteCodeMode==2) { //开启一对多邀请

            //该模式下邀请码为选填项,不强制要求填写


            if (example.getInviteCode() != null ){
                if(example.getInviteCode().equals("")){
                }else{
                    //检查用户填写的邀请码的合法性
                    if(inviteCode==null || inviteCode.getStatus()==-1 ){ //status = 0; //状态值 0,为初始状态未使用   1:已使用  -1 禁用
                        throw new ServiceException("邀请码无效或已被使用");
                    }
                }

            }

            //检查用户填写的邀请码的合法性
            if(inviteCode!=null && inviteCode.getTotalTimes()!=1 ){ //邀请码合法
                isNeedUpdateInvateCode = true;
            }


        }
        //更新邀请码数据
        if(isNeedUpdateInvateCode) {
            //将邀请码的使用次数加1
            inviteCode.setUsedTimes(inviteCode.getUsedTimes()+1);
            inviteCode.setStatus((short)1);
            inviteCode.setLastuseTime(System.currentTimeMillis());
            inviteCodeDao.addInviteCode(inviteCode);
        }



    }

}

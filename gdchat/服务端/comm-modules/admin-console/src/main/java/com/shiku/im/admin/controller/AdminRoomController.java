package com.shiku.im.admin.controller;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.room.entity.Room;
import com.shiku.im.room.service.impl.RoomManagerImplForIM;
import com.shiku.im.user.service.impl.RoleManagerImpl;
import com.shiku.im.vo.JSONMessage;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.annotations.ApiIgnore;

/**
 * 群组操作
 */
@ApiIgnore
@RestController
@RequestMapping("/console/room")
public class AdminRoomController {

    @Autowired
    private RoomManagerImplForIM roomManager;

    @Autowired
    private RoleManagerImpl roleManager;

    /**
     * 设置/取消管理员
     *
     * @param roomId:群组id
     * @param touserId:目标用户id
     * @param type:角色值 2=管理员、3=成员
     * @return
     */
    @RequestMapping("/set/admin")
    public JSONMessage setAdmin(@RequestParam String roomId, @RequestParam int touserId, @RequestParam int type) {
        try {
            // 权限校验
            byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
            if (role != KConstants.Admin_Role.SUPER_ADMIN) {
                return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
            }
            ObjectId roomObjId = new ObjectId(roomId);
            Room room = roomManager.getRoom(roomObjId);
            if (null == room) {
                return JSONMessage.failureByErrCode(KConstants.ResultCode.NotRoom);
            }
            int ownerUid = room.getUserId();
            if (touserId == ownerUid)
                return JSONMessage.failureByErrCode(KConstants.ResultCode.RoomOwnerNotSetAdmin);
            roomManager.setAdmin(roomObjId, touserId, type, ReqUtil.getUserId());
        } catch (ServiceException e) {
            return JSONMessage.failure(e.getMessage());
        }
        return JSONMessage.success();
    }

    /**
     * 转让群主
     *
     * @param roomId:群组Id
     * @param toUserId:目标用户id
     * @return
     */
    @RequestMapping("/transfer")
    public JSONMessage transfer(@RequestParam String roomId,@RequestParam(defaultValue="0") Integer toUserId) {
        // 权限校验
        byte role = (byte) roleManager.getUserRoleByUserId(ReqUtil.getUserId());
        if (role != KConstants.Admin_Role.SUPER_ADMIN) {
            return JSONMessage.failureByErrCode(KConstants.ResultCode.NO_PERMISSION);
        }

        if(0==toUserId)
            return JSONMessage.failureByErrCode(KConstants.ResultCode.SpecifyNewOwner);
        ObjectId roomObjId=null;
        try {
            roomObjId=new ObjectId(roomId);
        }catch (Exception e){
            return JSONMessage.failureByErrCode(KConstants.ResultCode.ParamsAuthFail);
        }
        Room room = roomManager.getRoom(roomObjId);
        if(null==room)
            return JSONMessage.failureByErrCode(KConstants.ResultCode.NotRoom);
        if(room.getS() == -1)
            return JSONMessage.failureByErrCode(KConstants.ResultCode.RoomIsLock);
        else if(toUserId.equals(room.getUserId()))
            return JSONMessage.failureByErrCode(KConstants.ResultCode.NotTransferToSelf);
        else if (null==roomManager.getMember(roomObjId, toUserId)) {
            return JSONMessage.failureByErrCode(KConstants.ResultCode.NotGroupMember);
        }
        try {
            roomManager.transfer(room, toUserId);
        }catch (Exception e){
            return JSONMessage.failureByException(e);
        }
        return JSONMessage.success();
    }

}

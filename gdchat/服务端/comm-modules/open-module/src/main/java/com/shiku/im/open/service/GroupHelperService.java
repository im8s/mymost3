package com.shiku.im.open.service;

import com.shiku.im.comm.constants.KConstants;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.open.dao.GroupHelperDao;
import com.shiku.im.open.dao.HelperDao;
import com.shiku.im.open.entity.GroupHelper;
import com.shiku.im.open.entity.Helper;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GroupHelperService {

    @Autowired
	private GroupHelperDao groupHelperDao;
	@Autowired
	private HelperDao helperDao;

    /**
     * 添加群助手
     * @param entity
     * @return
     */
    public Object addGroupHelper(String helperId,String roomId,String roomJid,Integer userId){


        if(null!=groupHelperDao.queryGroupHelper(roomId,helperId)){
            throw new ServiceException(KConstants.ResultCode.GroupHelperExist);
        }
        if(null==helperDao.getHelper(new ObjectId(helperId))){
            throw new ServiceException(KConstants.ResultCode.GroupHelperNotExist, ReqUtil.getRequestLanguage());
        }
        GroupHelper entity = new GroupHelper();
        entity.setHelperId(helperId);
        entity.setRoomId(roomId);
        entity.setRoomJid(roomJid);
        entity.setUserId(userId);
        if(null==entity.getId())
            entity.setId(ObjectId.get());
        groupHelperDao.save(entity);
        entity.setHelper(helperDao.getHelper(new ObjectId(helperId)));
        return entity;
    }

    /**
     * 添加自动回复关键字
     * @param roomId
     * @param helperId
     * @param keyWord
     * @param value
     * @return
     */
    public Object addAutoResponse(String roomId,String helperId,String keyWord,String value){

        GroupHelper.KeyWord keyword= new GroupHelper.KeyWord();
        keyword.setId(ObjectId.get().toString());
        keyword.setKeyWord(keyWord);
        keyword.setValue(value);

        List<GroupHelper.KeyWord> list = new ArrayList<>();

        GroupHelper groupHelper = groupHelperDao.queryGroupHelper(roomId,helperId);
        if(null==groupHelper){
            throw new ServiceException(KConstants.ResultCode.GroupHelperNotExist);
        }

        if(null!=groupHelper.getKeywords()){
            for(int i=0;i<groupHelper.getKeywords().size();i++){
                if(groupHelper.getKeywords().get(i).getKeyWord().equals(keyWord)){
                    throw new ServiceException(KConstants.ResultCode.KeyWordIsExist);
                }
            }
            groupHelper.getKeywords().add(keyword);
        }else{
            list.add(keyword);
            groupHelper.setKeywords(list);
        }

        Map<String,Object> map = new HashMap<>();
        map.put("keywords",groupHelper.getKeywords());
        groupHelperDao.updateGroupHelper(roomId,helperId,map);
        return keyword;

    }

    /**
     * 修改自动回复关键字和回复
     * @param id
     * @param keyWordId
     * @param keyword
     * @param value
     */
    public Object updateKeyword(String groupHelperId,String keyWordId,String keyword,String value){
        GroupHelper groupHelper = groupHelperDao.getGroupHelper(new ObjectId(groupHelperId));
        if(null==groupHelper){
            throw new ServiceException(KConstants.ResultCode.GroupHelperNotExist, ReqUtil.getRequestLanguage());
        }
        if(null==groupHelper.getKeywords()){
            throw new ServiceException(KConstants.ResultCode.KeyWordNotExist, ReqUtil.getRequestLanguage());
        }
        for(int i=0;i<groupHelper.getKeywords().size();i++){
            if(groupHelper.getKeywords().get(i).getId().equals(keyWordId)){
                groupHelper.getKeywords().get(i).setKeyWord(keyword);
                groupHelper.getKeywords().get(i).setValue(value);
            }
        }
        Map<String,Object> map = new HashMap<>();
        map.put("keywords",groupHelper.getKeywords());
        groupHelperDao.updateGroupHelper(new ObjectId(groupHelperId),null,map);
        return null;
    }

    /**
     * 删除自动回复关键字
     * @param groupHelperId
     * @param keyWordId
     */
    public Object deleteAutoResponse(Integer userId,String groupHelperId,String keyWordId){
        GroupHelper groupHelper = groupHelperDao.queryGroupHelper(new ObjectId(groupHelperId),userId);
        if(null==groupHelper){
             throw new ServiceException(KConstants.ResultCode.GroupHelperNotExist, ReqUtil.getRequestLanguage());
        }
        if(null==groupHelper.getKeywords()){
             throw new ServiceException(KConstants.ResultCode.KeyWordNotExist, ReqUtil.getRequestLanguage());
        }
        for(int i=0;i<groupHelper.getKeywords().size();i++){
            if(groupHelper.getKeywords().get(i).getId().equals(keyWordId)){
                groupHelper.getKeywords().remove(i);
            }
        }
        Map<String,Object> map = new HashMap<>();
        map.put("keywords",groupHelper.getKeywords());
        groupHelperDao.updateGroupHelper(new ObjectId(groupHelperId),userId,map);
        return null;
    }

    /**
     * 删除群助手
     * @param id
     */
    public void deleteGroupHelper(Integer userId,String id){
        groupHelperDao.deleteGroupHelper(userId,new ObjectId(id));
    }

    /**
     * 查询群组群助手
     * @param roomId
     * @return
     */
    public List<GroupHelper> queryGroupHelper(String roomId, String helperId){
        List<GroupHelper> list = groupHelperDao.getGroupHelperList(roomId);
        List<GroupHelper> newList = new ArrayList<>();
        if(!StringUtil.isEmpty(helperId)){
            for(int i=0;i<list.size();i++){
                if(list.get(i).getHelperId().equals(helperId)){
                    list.get(i).setHelper(helperDao.getHelper(new ObjectId(list.get(i).getHelperId())));
                    newList.add(list.get(i));
                }
            }
        }else{
            for(int i=0;i<list.size();i++){
                Helper getHelper = helperDao.getHelper(new ObjectId(list.get(i).getHelperId()));
                if(null!=getHelper){
                    list.get(i).setHelper(getHelper);
                    newList.add(list.get(i));
                }
            }
        }

        return newList;

    }
}

package com.shiku.im.msg.service.impl;

import com.shiku.im.msg.dao.MusicDao;
import com.shiku.im.msg.entity.MusicInfo;
import com.shiku.im.utils.ConstantUtil;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MusicManagerImpl{

	@Autowired
	private MusicDao musicDao;


	public List<MusicInfo> queryMusicInfo(int pageIndex, int pageSize, String keyword) {
		List<MusicInfo> resultList = musicDao.getMusicInfoList(pageIndex,pageSize,keyword);
		return resultList;
	}
	
	/**
	 * 添加短视频音乐
	 * @param musicInfo
	 */
	public void addMusicInfo(MusicInfo musicInfo){
		MusicInfo entity = new MusicInfo();
		if (!StringUtil.isEmpty(musicInfo.getCover()))
			entity.setCover(musicInfo.getCover());
		if(!StringUtil.isEmpty(musicInfo.getName()))
			entity.setName(musicInfo.getName());
		if(!StringUtil.isEmpty(musicInfo.getNikeName()))
			entity.setNikeName(musicInfo.getNikeName());
		if(!StringUtil.isEmpty(musicInfo.getPath()))
			entity.setPath(musicInfo.getPath());
		
		entity.setLength(musicInfo.getLength());
		entity.setUseCount(musicInfo.getUseCount());
		
//		saveEntity(entity);
		musicDao.addMusicInfo(entity);
	}
	
	/**
	 * 删除短视频音乐
	 * @param id
	 */
	public void deleteMusicInfo(ObjectId id){
		MusicInfo musicInfo = musicDao.getMusicInfoById(id);
		try {
			// 删除音乐文件
			deleteResource(musicInfo.getPath());
			// 删除头像文件
			deleteResource(musicInfo.getCover());
			// 删除短视频音乐主体
//			deleteByQuery(query);
			musicDao.deleteMusicInfo(id);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 修改
	 * @param musicInfo
	 */
	public void updateMusicInfo(MusicInfo musicInfo){
		Map<String,Object> map = new HashMap<>();
		if(!StringUtil.isEmpty(musicInfo.getCover()))
			map.put("cover", musicInfo.getCover());
		if(!StringUtil.isEmpty(musicInfo.getName()))
			map.put("name", musicInfo.getName());
		if(!StringUtil.isEmpty(musicInfo.getNikeName()))
			map.put("nikeName", musicInfo.getNikeName());
		if(!StringUtil.isEmpty(musicInfo.getPath()))
			map.put("path", musicInfo.getPath());
		if(musicInfo.getLength()!=0)
			map.put("length", musicInfo.getLength());
		map.put("useCount", musicInfo.getUseCount());
		musicDao.updateMusicInfo(musicInfo.getId(),map);
	}
	
	/**
	 * 维护音乐使用次数
	 * @param id
	 */
	public void updateUseCount(ObjectId id){
//		Query<MusicInfo> query=getDatastore().createQuery(getEntityClass()).field("_id").equal(id);
//		UpdateOperations<MusicInfo> ops=getDatastore().createUpdateOperations(getEntityClass());
//		ops.set("useCount", query.get().getUseCount()+1);
//		getDatastore().update(query, ops);

		Map<String,Object> map = new HashMap<>();
		map.put("useCount", musicDao.getMusicInfoById(id).getUseCount()+1);
		musicDao.updateMusicInfo(id,map);
	}
	
	/**
	 * 删除文件
	 * @param url
	 */
	public void deleteResource(String url){
		
		ConstantUtil.deleteFile(url);
	}
}

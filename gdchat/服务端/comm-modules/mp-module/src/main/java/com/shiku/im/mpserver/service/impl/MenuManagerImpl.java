package com.shiku.im.mpserver.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.google.common.collect.Maps;
import com.mongodb.BasicDBObject;
import com.shiku.im.comm.utils.IdWorker;
import com.shiku.im.friends.dao.FriendsDao;
import com.shiku.im.mpserver.dao.MenuDao;
import com.shiku.im.mpserver.model.MenuVO;
import com.shiku.im.mpserver.service.MenuManager;
import com.shiku.im.mpserver.vo.Menu;
import com.shiku.im.user.dao.UserDao;
import com.shiku.utils.StringUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service
public class MenuManagerImpl implements MenuManager {
	@Autowired
	private MenuDao menuDao;
	@Autowired
	private FriendsDao friendsDao;
	@Autowired
	private UserDao userDao;

	//@Autowired(required = false)
	//@Qualifier(value = "mongoTemplateForTigase")
	//private MongoTemplate dsForTigase;
	
	public List<Menu> getMenu(int userId){
		List<Menu> data = menuDao.getMenuList(userId,0);
		if (null != data && data.size() > 0) {
			for (Menu menu : data) {
				List<Menu> urlList = menuDao.getMenuList(menu.getId());
				for(Menu urlMenu : urlList){
					if(!StringUtil.isEmpty(urlMenu.getUrl()))
						urlMenu.setUrl(urlMenu.getUrl().replaceAll(" ", ""));
				}
				menu.setMenuList(urlList);
			}
		}
		return data;
	} 
	
	public List<MenuVO> navMenu(int userId) {
		List<Menu> menuList = menuDao.getMenuList(userId,0);
		List<MenuVO> list = new ArrayList<>();
		List<MenuVO> listMenu = new ArrayList<>();
		MenuVO menuVO = null;
		MenuVO menus = null;
		if (null != menuList && menuList.size() > 0) {
			for (Menu menu : menuList) {
				menu.setMenuList(menuDao.getMenuList(menu.getId()));
				menuVO = new MenuVO();
				menuVO.setId(String.valueOf(menu.getId()));
				menuVO.setIndex(menu.getIndex());
				menuVO.setMenuId(menu.getMenuId());
				menuVO.setDesc(menu.getDesc());
				menuVO.setParentId(String.valueOf(menu.getParentId()));
				menuVO.setUrl(menu.getUrl());
				menuVO.setName(menu.getName());
				for (Menu me : menu.getMenuList()) {
					menus = new MenuVO();
					menus.setId(String.valueOf(me.getId()));
					menus.setIndex(me.getIndex());
					menus.setMenuId(me.getMenuId());
					menus.setDesc(me.getDesc());
					menus.setParentId(String.valueOf(me.getParentId()));
					menus.setUrl(me.getUrl());
					menus.setName(me.getName());
					listMenu.add(menus);
				}
				menuVO.setMenuList(listMenu);
				list.add(menuVO);

			}
		}
		return list;
	}
	
	@SuppressWarnings("deprecation")
	public JSONObject getHomeCount(int userId) {
		JSONObject obj = new JSONObject();
		long fansCount = friendsDao.getFriendsCount(userId);
		long userCount = userDao.getAllUserCount();
		BasicDBObject query = new BasicDBObject("direction", 0);
		query.append("receiver", userId);
		query.append("isRead", 0);
		obj.put("fansCount", fansCount);
		obj.put("userCount", userCount);
		return obj;
	}
	
	public void menuOp(int userId, String op, long parentId, String desc, String name, int index, String urls, long id,String menuId,
			HttpServletResponse response) {
		Menu entity = new Menu();
			if ("save".equals(op)) {
				entity.setId(IdWorker.getId());
				entity.setUserId(userId);
				entity.getName();

				entity.setParentId(parentId);
				entity.setIndex(index);
				if (!StringUtil.isEmpty(desc))
					entity.setDesc(desc);
				if (!StringUtil.isEmpty(name))
					entity.setName(name);
				if (!StringUtil.isEmpty(urls))
					entity.setUrl(urls);
				if(!StringUtil.isEmpty(menuId))
					entity.setMenuId(menuId);
				menuDao.addMenu(entity);
			} else if ("delete".equals(op)) {
				menuDao.deleteMenu(id);
			}
	}
	
	/*public Map<String, Long> getFans(int userId){
		Map<String, Long> map = Maps.newConcurrentMap();
		long fansCount = friendsDao.getFriendsCount(userId);
		map.put("fansCount", fansCount);
		BasicDBObject query=new BasicDBObject("direction", 0);
		query.append("receiver", userId);
		query.append("isRead", 0);
		long msgCount = dsForTigase.getCollection("shiku_msgs").count(query);
		map.put("msgCount", msgCount);
		return map;
	}*/
	
	public void saveupdate(Menu entity) {
		Map<String,Object> map = new HashMap<>();
		if (0 != entity.getParentId())
			map.put("parentId", entity.getParentId());
		if (!StringUtil.isEmpty(entity.getName()))
			map.put("name", entity.getName());

		map.put("url", entity.getUrl());
		if (0 != entity.getIndex())
			map.put("index", entity.getIndex());
		if (!StringUtil.isEmpty(entity.getDesc()))
			map.put("desc", entity.getDesc());
		if(!StringUtil.isEmpty(entity.getMenuId()))
			map.put("menuId", entity.getMenuId());
		menuDao.updateMenu(entity.getId(),map);
	}
	
}

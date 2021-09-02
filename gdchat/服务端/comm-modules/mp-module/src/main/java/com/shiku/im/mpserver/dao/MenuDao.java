package com.shiku.im.mpserver.dao;

import com.shiku.im.mpserver.vo.Menu;
import com.shiku.im.repository.IMongoDAO;

import java.util.List;
import java.util.Map;

public interface MenuDao extends IMongoDAO<Menu, Long> {
    void addMenu(Menu menu);

    List<Menu> getMenuList(int userId, long parentId);

    List<Menu> getMenuList(long parentId);

    void updateMenu(long id, Map<String, Object> map);

    void deleteMenu(long id);
}

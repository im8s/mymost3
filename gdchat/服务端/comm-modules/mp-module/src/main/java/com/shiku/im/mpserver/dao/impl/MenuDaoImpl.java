package com.shiku.im.mpserver.dao.impl;

import com.shiku.im.mpserver.dao.MenuDao;
import com.shiku.im.mpserver.vo.Menu;
import com.shiku.im.repository.MongoRepository;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * 
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/24 16:59
 */
@Repository
public class MenuDaoImpl extends MongoRepository<Menu,Long> implements MenuDao {

   
    @Override
    public Class<Menu> getEntityClass() {
        return Menu.class;
    }

    @Override
    public void addMenu(Menu menu) {
        getDatastore().save(menu);
    }

    @Override
    public List<Menu> getMenuList(int userId, long parentId) {
        Query query = createQuery("userId",userId);
                addToQuery(query,"parentId",parentId);
                ascByquery(query,"index");
        return queryListsByQuery(query);
    }

    @Override
    public List<Menu> getMenuList(long parentId) {
        Query query = createQuery("parentId",parentId);
        ascByquery(query,"index");
        return queryListsByQuery(query);
    }

    @Override
    public void updateMenu(long id, Map<String, Object> map) {
        Query query = createQuery(id);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        getDatastore().updateFirst(query,ops,getEntityClass());
    }

    @Override
    public void deleteMenu(long id) {
       deleteById(id);
    }
}

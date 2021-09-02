package com.shiku.im.dao.impl;

import com.google.common.collect.Lists;
import com.shiku.common.model.PageResult;
import com.shiku.im.friends.dao.AddressBookDao;
import com.shiku.im.friends.entity.AddressBook;
import com.shiku.im.repository.MongoOperator;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.BasicBSONObject;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/2 18:23
 */
@Repository
public class AddressBookDaoImpl extends MongoRepository<AddressBook, ObjectId> implements AddressBookDao {


    @Override
    public Class<AddressBook> getEntityClass() {
        return AddressBook.class;
    }

    @Autowired
    @Qualifier(value = "mongoTemplateContact")
    private MongoTemplate mongoTemplateContact;

    @Override
    public MongoTemplate getDatastore() {
        return mongoTemplateContact;
    }
    @Override
    public void addAddressBookList(List<AddressBook> bookList) {
        if(null != bookList && bookList.size() > 0){
            int userId = bookList.get(0).getUserId();
            String collectionName = getCollectionName(userId);
            getDatastore().insert(bookList,collectionName);
        }
    }

    @Override
    public void addAddressBook(AddressBook addressBook) {
        getDatastore().save(addressBook,getCollectionName(addressBook.getUserId()));
    }

    @Override
    public void deleteAddressBook(int userId, String[] deleteArray) {
        Query query=createQuery("userId", userId);
        addToQuery(query,"toTelephone", new BasicBSONObject(MongoOperator.IN, deleteArray));

        deleteByQuery(query,getCollectionName(userId));
    }

    @Override
    public List<AddressBook> queryListByUserId(int userId) {
        Query query = createQuery("userId",userId);
        Criteria criteria = createCriteria();
        criteria.orOperator(Criteria.where("status").is(1),Criteria.where("status").is(2));
        query.addCriteria(criteria);
        return queryListsByQuery(query,getCollectionName(userId));
    }

    @Override
    public List<AddressBook> queryListByUserId(int userId, int pageIndex, int pageSize) {
        return null;
    }

    @Override
    public List<AddressBook> queryListByToTelephone(String toTelephone) {
       final List<AddressBook> resultList= Lists.newArrayList();
        Query query=createQuery("toTelephone", toTelephone);
        getCollectionList().forEach(name->{
            resultList.addAll(queryListsByQuery(query,name));
        });
        return resultList;
    }

    @Override
    public List<AddressBook> queryRegisterEdList(int userId, int registerEd,int pageIndex,int pageSize) {
        Query query=createQuery("registerEd",registerEd);
        addToQuery(query,"userId",userId);
        PageRequest pageRequest = createPageRequest(pageIndex, pageSize);
        query.with(pageRequest);
        return queryListsByQuery(query,getCollectionName(userId));
    }

    @Override
    public PageResult<AddressBook> queryAddressBookForAdmin(int userId, int pageIndex, int pageSize) {
        PageResult<AddressBook> result=new PageResult<>();
        Query query= createQuery("userId",userId);
        query.with(Sort.by(Sort.Order.asc("toRemarkName")));
        result.setCount(count(query, getCollectionName(userId)));
        result.setData(queryListsByQuery(query, pageIndex-1, pageSize,getCollectionName(userId)));
        return result;
    }

    @Override
    public List<String> queryTelephoneListToTelephone(String toTelephone) {
        final List<String> resultList= Lists.newArrayList();
        Query query=createQuery("toTelephone", toTelephone);
        getCollectionList().forEach(name->{
            resultList.addAll(distinct(name,"telephone",query,String.class));
        });
        return resultList;
    }

    @Override
    public long getAddressBookAllCount(int userId, String toTelephone) {
        Query query=createQuery("userId", userId);
        addToQuery(query,"toTelephone", toTelephone);
        return count(query,getCollectionName(userId));


    }

    @Override
    public AddressBook getAddressBook(String telephone, int toUserId) {
        return null;
    }

    @Override
    public void deleteAddressBook(String telephone, String toTelephone, Integer userId) {
        Query query=createQuery();
		if(!StringUtil.isEmpty(telephone))
			addToQuery(query,"telephone", telephone);
		if(!StringUtil.isEmpty(telephone))
			addToQuery(query,"toTelephone", toTelephone);
		if(0 != userId) {
            addToQuery(query, "userId", userId);
            deleteByQuery(query,getCollectionName(userId));
            return;
        }

		deleteByQuery(query);
    }

    @Override
    public void deleteAddressBook(int userId, int toUserId) {
        Query query=createQuery("userId",userId);
        addToQuery(query,"toUserId",toUserId);

        deleteByQuery(query,getCollectionName(userId));
    }

    @Override
    public List<AddressBook> getAddressBookAll(String telephone) {
        return null;
    }

    @Override
    public void updateAddressBook(String telephone) {

        Query query=createQuery("toTelephone", telephone);
        Update update=createUpdate();
        update.set("registerEd", 0);
        update.set("registerTime",0);
        getCollectionList().forEach(name->{
            update(query,update,name);
        });
    }

    @Override
    public void updateAddressBook(String telephone, int userId, String nickName, long registerTime,int status) {


        Query query=createQuery("toTelephone", telephone);
        addToQuery(query,"registerEd", 0);
        Update update=createUpdate();
        update.set("registerEd", 1);
        update.set("toUserName", nickName);
        update.set("registerTime", registerTime);
        update.set("toUserId", userId);
        update.set("status", status);

        getCollectionList().forEach(name->{
            update(query,update,name);
        });



    }
}

package com.shiku.im.company.dao.impl;

import com.shiku.im.company.dao.CustomerDao;
import com.shiku.im.company.entity.Customer;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import com.shiku.utils.StringUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/6 12:31
 */
@Repository
public class CustomerDaoImpl extends BaseMongoRepository<Customer, ObjectId> implements CustomerDao {



    @Override
    public Class<Customer> getEntityClass() {
        return Customer.class;
    }

    @Override
    public Map<String, Object> addCustomer(Customer customer) {

         // 1、新增客户记录
        getDatastore().save(customer);



        return null;
    }

    @Override
    public Integer findUserByIp(String ip) {
        Query query = createQuery();
        if (!StringUtil.isEmpty(ip)){
           addToQuery(query,"userKey",ip);
        }
        Customer customer = findOne(query);
        if(customer!=null){
            return customer.getCustomerId();
        }else{
            return null;
        }
    }

}

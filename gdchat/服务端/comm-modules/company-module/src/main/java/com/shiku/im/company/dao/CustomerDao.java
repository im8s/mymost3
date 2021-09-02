package com.shiku.im.company.dao;

import com.shiku.im.company.entity.Customer;
import com.shiku.mongodb.springdata.IBaseMongoRepository;
import org.bson.types.ObjectId;

import java.util.Map;

public interface CustomerDao extends IBaseMongoRepository<Customer, ObjectId> {

    Map<String,Object> addCustomer(Customer customer);

    Integer findUserByIp(String ip);

}

package com.shiku.im.repository;

import com.shiku.mongodb.springdata.IBaseMongoRepository;

import java.io.Serializable;

public interface IMongoDAO<T,ID extends Serializable> extends IBaseMongoRepository<T,ID> {


}

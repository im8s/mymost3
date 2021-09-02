package com.shiku.im.admin.dao;


import com.shiku.common.model.PageResult;
import com.shiku.im.model.ErrorMessage;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

public interface ErrorMessageDao extends IMongoDAO<ErrorMessage, ObjectId> {

    void addErrorMessage(ErrorMessage errorMessage);

    PageResult getErrorMessageList(String keyword, int pageIndex, int pageSize);

    void deleteErrorMessage(String code);

    ErrorMessage getErrorMessage(String code);

    ErrorMessage getErrorMessage(ObjectId id);

    ErrorMessage updateErrorMessage(ObjectId id, ErrorMessage errorMessage);
}

package com.shiku.im.company.dao;

import com.shiku.im.company.entity.CommonText;
import com.shiku.mongodb.springdata.IBaseMongoRepository;
import org.bson.types.ObjectId;

import java.util.List;

public interface CommonTextDao extends IBaseMongoRepository<CommonText, ObjectId> {

    CommonText addCommonText(CommonText commonText);

    boolean deleteCommonText(String commonTextId);

    List<CommonText> commonTextGetByCommpanyId(String companyId, int pageIndex, int pageSize);

    List<CommonText> commonTextGetByUserId(int userId, int page, int limit);

    CommonText commonTextModify(CommonText commonText);
}

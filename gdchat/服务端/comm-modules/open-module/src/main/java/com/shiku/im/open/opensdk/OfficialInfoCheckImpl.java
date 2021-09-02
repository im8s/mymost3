package com.shiku.im.open.opensdk;

import com.shiku.common.model.PageResult;
import com.shiku.im.open.entity.OfficialInfo;
import com.shiku.im.repository.MongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

/**
 * 
 * @Date Created in 2019/9/17 19:58
 * @description TODO
 * @modified By:
 */
@Service
public class OfficialInfoCheckImpl extends MongoRepository<OfficialInfo, ObjectId> {
   

    @Override
    public Class<OfficialInfo> getEntityClass() {
        return OfficialInfo.class;
    }

    /**
     * 
     * @date 2019/9/17 20:01
     *      查询全部审核记录
     */
    public PageResult<OfficialInfo> getOfficialInfoList(int pageIndex, int pageSize){
        Query query=createQuery();
        PageResult<OfficialInfo> data=new PageResult<>();
        data.setCount(count());
        data.setData(queryListsByQuery(query,pageIndex, pageSize, 1));
        return data;
    }

    /**
     * 
     * @date 2019/9/18 9:34
     *          删除审核纪律
     */
    public void delOfficialInfoLog(ObjectId id){
        deleteById(id);
    }

    /**
     * 
     * @date 2019/9/18 10:11
     *          根据id 获取审核详情
     */
    public OfficialInfo getOfficialInfo(ObjectId id){
        return get(id);
    }

    /**
     * 
     * @date 2019/9/19 11:35
     *      根据电话号码查出公众号信息
     */
    public OfficialInfo getOfficialInfo(String telephone){
        return findOne("telephone",telephone);
    }

    /**
     * 
     * @date 2019/9/18 12:11
     *          确认审核
     */
    public OfficialInfo updateOfficialInfo(ObjectId id, int verify, String feedback){
        Query query = createQuery(id);
        Update ops = createUpdate();
        ops.set("verify",verify);
        ops.set("feedback",feedback);
        return getDatastore().findAndModify(query,ops,getEntityClass());
    }

    /**
     * 
     * @date 2019/9/19 18:35
     *      重新审核
     */
    public OfficialInfo updateOfficialInfoByTel(OfficialInfo info){
        Query query = createQuery("telephone",info.getTelephone());
        Update ops = createUpdate();
        ops.set("verify",0);
        ops.set("feedback","");
        ops.set("adminID",info.getAdminID());
        ops.set("adminName",info.getAdminName());
        ops.set("adminTelephone",info.getAdminTelephone());
        ops.set("companyBusinessLicense",info.getCompanyBusinessLicense());
        ops.set("companyName",info.getCompanyName());
        ops.set("companyType",info.getCompanyType());
        ops.set("desc",info.getDesc());

        return getDatastore().findAndModify(query,ops,getEntityClass());
    }
}

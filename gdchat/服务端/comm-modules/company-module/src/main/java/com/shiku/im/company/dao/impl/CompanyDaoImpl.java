package com.shiku.im.company.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.common.util.StringUtil;
import com.shiku.im.company.dao.CompanyDao;
import com.shiku.im.company.entity.Company;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import com.shiku.utils.DateUtil;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Repository
public class CompanyDaoImpl extends BaseMongoRepository<Company,ObjectId> implements CompanyDao {

    @Override
    public Class<Company> getEntityClass() {
        return Company.class;
    }


    //创建公司
    @Override
    public Company addCompany(String companyName, int createUserId, ObjectId rootDpartId) {

        Company company = new Company();
        List<ObjectId> list = new ArrayList<ObjectId>();
        list.add(rootDpartId);

        company.setCompanyName(companyName);
        company.setCreateUserId(createUserId);
        company.setDeleteUserId(0);
        company.setCreateTime(DateUtil.currentTimeSeconds());
        company.setRootDpartId(list);
        company.setNoticeContent("");
        company.setDeleteTime(0);
        company.setNoticeTime(0);
        company.setEmpNum(1);

        //存入公司数据
        ObjectId companyId = (ObjectId) getDatastore().save(company).getId();
        company.setId(companyId);

        return company;
    }


    //根据创建者Id查找公司
    @Override
    public Company findCompanyByCreaterUserId(int createUserId) {
        //根据创建者Id查找公司，同时排除掉deleteUserId != 0 的数据(deleteUserId != 0 :表示已经删除）
        Query query =createQuery("createUserId",createUserId);
        addToQuery(query,"deleteUserId",0);
        return findOne(query);

    }

    @Override
    public List<Company> findCompanyListByCreateUserId(int createUserId) {
        Query query =createQuery("createUserId",createUserId);
        addToQuery(query,"deleteUserId",0);
        return queryListsByQuery(query);
    }

    //修改公司信息
    @Override
    public Company modifyCompany(Company company) {
        ObjectId companyId = company.getId();
        if(companyId == null){
            return null;
        }

        Query query =createQuery("_id",companyId);
        Update ops = createUpdate();
        if(null != company.getCompanyName())
            ops.set("companyName", company.getCompanyName());
        if(0 != company.getCreateUserId())
            ops.set("createUserId", company.getCreateUserId());
        if(0 != company.getDeleteUserId())
            ops.set("deleteUserId", company.getDeleteUserId());
        if(null != company.getRootDpartId())
            ops.set("rootDpartId", company.getRootDpartId());
        if(0 != company.getCreateTime())
            ops.set("createTime", company.getCreateTime());
        if(null != company.getNoticeContent()){
            ops.set("noticeContent", company.getNoticeContent());
            ops.set("noticeTime", DateUtil.currentTimeSeconds());
        }
        if(0 != company.getDeleteTime())
            ops.set("deleteTime", company.getDeleteTime());
        if(0 != company.getEmpNum())
            ops.set("empNum", company.getEmpNum());

        update(query,ops);

        return company;
    }


    //通过公司名称的关键字模糊查找公司
    @Override
    public List<Company> findCompanyByName(String keyworld) {

        Query query = createQuery();
        query.addCriteria(Criteria.where("companyName").regex(keyworld));

        //忽略大小写进行模糊匹配
        List<Company> companys = queryListsByQuery(query);

        //除去执行过删除操作,被隐藏的公司
        for (Iterator<Company> iter = companys.iterator(); iter.hasNext();) {
            Company company = iter.next();
            if (company.getDeleteUserId() != 0) {   //将DeleteUserId不为0的数据剔除
                iter.remove();
            }
        }

        return companys;
    }

    //根据公司id查找公司
    @Override
    public Company findById(ObjectId companyId){
       return get(companyId);
    }



    //获得所有公司
    @Override
    public PageResult<Company> companyList(int pageSize, int pageIndex) {
        PageResult<Company> list = new PageResult<>();
        //查找没有被隐藏起来的公司
        Query query =createQuery("deleteUserId",0);
        List<Company> companies = queryListsByQuery(query, pageIndex - 1, pageSize);
        list.setData(companies);
        list.setCount(count(query));
        return list;
    }


    //根据公司名称查找公司，精准查找
    @Override
    public Company findOneByName(String companyName) {
        //查找公司名称完全匹配，且没有被隐藏起来的公司
        Query query =createQuery("deleteUserId",0);
        addToQuery(query,"companyName",companyName);
        return findOne(query);
    }


    //返回某个特定状态值的公司
    @Override
    public List<Company> findByType(int type) {
        Query query =createQuery("type",type);
       return queryListsByQuery(query);
    }

    @Override
    public void deleteComplay(Company company) {

        deleteById(company.getId());
    }

    public static boolean isEscapeChar(String str){
        Pattern pattern = Pattern.compile("^[+*.](.*?)");
        Matcher isEscape = pattern.matcher(str);
        if(!isEscape.matches()){
            return false;
        }
        return true;
    }
    /**
     * 
     * @date 2019/11/21 11:03
     *      通过公司名称的关键字模糊查找公司
     */
    @Override
    public PageResult<Company> findCompanyByNameLimit(String keyworld, int page, int limit) {
        PageResult<Company> data = new PageResult<>();
        if(StringUtil.isEscapeChar(keyworld)){
            // 特殊字符开头 .*+ 会导致异常，这里做一下特殊处理
            keyworld = keyworld.replaceAll("^[+*.](.*?)","");
            if(StringUtil.isEmpty(keyworld)){
                return data;
            }
        }
        Query query = createQuery();
        query.addCriteria(Criteria.where("companyName").regex(keyworld));

        //忽略大小写进行模糊匹配
        List<Company> companys = queryListsByQuery(query);

        //除去执行过删除操作,被隐藏的公司
        for (Iterator<Company> iter = companys.iterator(); iter.hasNext();) {
            Company company = iter.next();
            if (company.getDeleteUserId() != 0) {   //将DeleteUserId不为0的数据剔除
                iter.remove();
            }
        }

        data.setData(companys);
        data.setCount(count(query));
        return data;
    }

}

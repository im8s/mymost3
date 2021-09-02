package com.shiku.im.company.dao.impl;

import com.shiku.im.company.dao.DepartmentDao;
import com.shiku.im.company.entity.Department;
import com.shiku.mongodb.springdata.BaseMongoRepository;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class DepartmentDaoImpl extends BaseMongoRepository<Department,ObjectId> implements DepartmentDao {


    @Override
    public Class<Department> getEntityClass() {
        return Department.class;
    }

    //创建部门,返回值为部门Id
    @Override
    public ObjectId addDepartment(Department department) {
        //存入数据，并获取id
        ObjectId departmentId = (ObjectId) getDatastore().save(department).getId();
        return departmentId;
    }

    //修改部门信息
    @Override
    public Department modifyDepartment(Department department) {

        ObjectId departmentId = department.getId();

        if(departmentId == null){
            return null;
        }

        Query query = createQuery("_id",departmentId);
        Update ops = createUpdate();

        if(null != department.getDepartName())
            ops.set("departName", department.getDepartName());
        if(0 <= department.getEmpNum())
            ops.set("empNum", department.getEmpNum());

        if (null != department.getParentId()){
            ops.set("parentId",department.getParentId());
        }
        Department depart = getDatastore().findAndModify(query,ops,new FindAndModifyOptions().returnNew(true),getEntityClass());

        return depart;


    }

	/**
	 *	修改部门人数
	 * @param deptId
	 * @param type  1 人数加一   -1 人数减一
	 */
	@Override
	public Department updateDepartment(ObjectId deptId, int type) {
        Query query = createQuery("_id",deptId);
		Department department = findOne(query);
		Update ops = createUpdate();
		if(type == 1){
			ops.set("empNum",department.getEmpNum()+1);
		}else if(type == -1){
			ops.set("empNum",department.getEmpNum()-1);
		}
		return getDatastore().findAndModify(query,ops,getEntityClass());
	}

    //根据部门Id查找部门
    @Override
    public Department findDepartmentById(ObjectId departmentId) {
        return get(departmentId);
    }

    //删除部门
    @Override
    public void deleteDepartment(ObjectId departmentId) {
        //根据id找到部门
       deleteById(departmentId);
    }

    @Override
    public void deleteAllDepartment(ObjectId companyId) {
        Query query = createQuery("companyId",companyId);
        deleteByQuery(query);
    }

    //部门列表(公司的所有部门，包含员工,分页)
    @Override
    public List<Department> departmentList(ObjectId companyId, int pageSize, int pageIndex) {
        Query query = createQuery("companyId",companyId);

        return queryListsByQuery(query,pageIndex,pageSize);
    }

    //根据id查找部门
    @Override
    public Department findById(ObjectId departmentId) {
        return get(departmentId);
    }

    //公司部门列表，封装员工数据
    @Override
    public List<Department> departmentList(ObjectId companyId) {
        Query query = createQuery("companyId",companyId);
        ascByquery(query,"createTime");
        return queryListsByQuery(query);  //按创建时间升序排列
    }

    //根据公司id修改根部门信息
    @Override
    public Department modifyRootDepartByCompId(ObjectId companyId, Department depart) {
        //查找根部门
        Query query =createQuery("companyId",companyId);
        addToQuery(query,"type",1);
         //type:1   1:根部门
        depart.setId(findOne(query).getId());
        //更新信息
        Update ops =createUpdate();
        if(null != depart.getDepartName())
            ops.set("departName", depart.getDepartName());
        if(0 <= depart.getEmpNum())
            ops.set("empNum", depart.getEmpNum());

        return getDatastore().findAndModify(query, ops,getEntityClass());

    }

    //根据部门名称，查找某个公司的部门,精准查找
    @Override
    public Department findOneByName(ObjectId companyId, String departName) {
        Query query =createQuery("companyId",companyId);
        addToQuery(query,"departName",departName);
        return findOne(query);
    }

    //通过部门id得到公司id
    @Override
    public ObjectId getCompanyId(ObjectId departmentId) {
        Department department = findById(departmentId);
        if(null!=department)
            return department.getCompanyId();
        else  return null;
    }

    //查找某个公司中某个特定状态值的部门
    @Override
    public List<Department> findByType(ObjectId companyId, int type) {
        Query query =createQuery("companyId",companyId);
        addToQuery(query,"type",type);
        return queryListsByQuery(query);
    }

    //查找某个部门的子部门
    @Override
    public List<Department> findChildDepartmeny(ObjectId departmentId) {
        Query query =createQuery("parentId",departmentId);
        return queryListsByQuery(query);
    }

    @Override
    public List<Department> departmentAllList(ObjectId companyId) {
        Query query =createQuery("companyId",companyId);
        return queryListsByQuery(query);
    }

    @Override
    public Department queryDepartmentId(ObjectId companyId) {
        Query query =createQuery("companyId",companyId);
        Criteria criteria1=Criteria.where("type").is(1);
        Criteria criteria=createCriteria().orOperator(criteria1);
        return findOne(query);
    }


}

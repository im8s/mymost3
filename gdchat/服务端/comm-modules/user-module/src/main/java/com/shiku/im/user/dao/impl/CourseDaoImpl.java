package com.shiku.im.user.dao.impl;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.CourseDao;
import com.shiku.im.user.entity.Course;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public class CourseDaoImpl extends MongoRepository<Course,ObjectId> implements CourseDao {

    @Override
    public Class<Course> getEntityClass() {
        return Course.class;
    }

    @Override
    public void addCourse(Course course) {
        getDatastore().save(course);
    }

    @Override
    public Course getCourseById(ObjectId courseId) {
        return get(courseId);
    }

    @Override
    public Course getCourse(ObjectId courseId, Integer userId) {
        Query query =createQuery("_id",courseId);
        addToQuery(query,"userId",userId);
        return findOne(query);
    }

    @Override
    public List<Course> getCourseListByUserId(Integer userId) {
        Query query = createQuery("userId",userId);
        ascByquery(query,"createTime");
        return queryListsByQuery(query);
    }

    @Override
    public void updateCourse(ObjectId courseId, List<String> messageIds, long updateTime, String courseName) {
        Query query = createQuery("_id",courseId);
        Update ops = createUpdate();
        if(null!=messageIds){
            ops.set("messageIds",messageIds);
        }
        if(0!=updateTime){
            ops.set("updateTime",updateTime);
        }
        if(null!=courseName){
            ops.set("courseName",courseName);
        }
        update(query,ops);
    }

    @Override
    public void deleteCourse(ObjectId courseId, Integer userId) {
        Query query =createQuery("_id",courseId);
        addToQuery(query,"userId",userId);
        deleteByQuery(query);

    }
}

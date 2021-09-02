package com.shiku.im.user.dao.impl;

import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.repository.MongoRepository;
import com.shiku.im.user.dao.CourseMessageDao;
import com.shiku.im.user.entity.CourseMessage;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CourseMessageDaoImpl extends MongoRepository<CourseMessage,ObjectId> implements CourseMessageDao {



    @Override
    public Class<CourseMessage> getEntityClass() {
        return CourseMessage.class;
    }

    @Override
    public void addCourseMessage(ObjectId courseMessageId,int userId,String courseId,String message,String messageId,String createTime) {
        CourseMessage courseMessage = new CourseMessage();
        if(null != courseMessageId)
            courseMessage.setCourseMessageId(courseMessageId);
        if(0 != userId)
            courseMessage.setUserId(userId);
        if(!StringUtil.isEmpty(courseId))
            courseMessage.setCourseId(courseId);
        if(!StringUtil.isEmpty(message))
            courseMessage.setMessage(message);
        if(!StringUtil.isEmpty(messageId))
            courseMessage.setMessageId(messageId);
        if(!StringUtil.isEmpty(createTime))
            courseMessage.setCreateTime(createTime);

        getDatastore().save(courseMessage);
    }

    @Override
    public CourseMessage queryCourseMessageById(String courseMessageId) {
        Query query=createQuery("messageId", courseMessageId);
        return findOne(query);
    }

    @Override
    public CourseMessage queryCourseMessageByIdOld(ObjectId courseMessageId) {
        Query query=createQuery("_id", courseMessageId);
        return findOne(query);
    }

    @Override
    public void deleteCourseMessage(CourseMessage courseMessage) {
        deleteById(courseMessage.getCourseMessageId());
    }

    @Override
    public List<CourseMessage> getCourseMessageList(String courseId, Integer userId) {
        Query query = createQuery("courseId",courseId);
        if(null != userId)
           addToQuery(query,"userId",userId);
        return queryListsByQuery(query);
    }
}

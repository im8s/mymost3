package com.shiku.im.user.service;

import com.shiku.im.user.entity.Course;
import com.shiku.im.user.entity.CourseMessage;
import com.shiku.im.user.entity.Emoji;
import org.bson.types.ObjectId;

import java.util.List;

public interface CollectService {

    // 添加收藏
    List<Object> addCollection(int userId, String roomJid, String msgId, String type);

    // 添加收藏表情
    Object addEmoji(int userId, String url, String type);

    // 收藏列表
    List<Emoji> emojiList(int userId, int type, int pageSize, int pageIndex);

    List<Emoji> emojiList(int userId);

    //取消收藏
    void deleteEmoji(Integer userId, String emojiId);

    //添加消息课程
    void addMessageCourse(int userId, List<String> messageIds, long createTime, String courseName, String roomJid);

    //通过userId获取用户课程
    List<Course> getCourseList(int userId);

    //修改课程
    void updateCourse(Course course, String courseMessageId);

    //删除课程
    boolean deleteCourse(Integer userId, ObjectId courseId);

    //发送课程
    List<CourseMessage> getCourse(String courseId);

    Emoji addNewEmoji(String emoji);
}

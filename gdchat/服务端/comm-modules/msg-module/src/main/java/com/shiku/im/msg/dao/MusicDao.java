package com.shiku.im.msg.dao;

import com.shiku.common.model.PageResult;
import com.shiku.im.msg.entity.MusicInfo;
import com.shiku.im.repository.IMongoDAO;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Map;

public interface MusicDao extends IMongoDAO<MusicInfo, ObjectId> {

    void addMusicInfo(MusicInfo musicInfo);

    void deleteMusicInfo(ObjectId id);

    MusicInfo getMusicInfoById(ObjectId id);

    List<MusicInfo> getMusicInfoList(int pageIndex, int pageSize, String keyword);

    void updateMusicInfo(ObjectId id, Map<String,Object> map);

    PageResult<MusicInfo> getMusicInfo(int pageIndex, int pageSize, String keyword);

}

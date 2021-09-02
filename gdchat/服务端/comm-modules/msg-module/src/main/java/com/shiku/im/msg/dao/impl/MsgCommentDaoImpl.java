package com.shiku.im.msg.dao.impl;

import com.shiku.common.model.PageResult;
import com.shiku.im.comm.utils.StringUtil;
import com.shiku.im.msg.dao.MsgCommentDao;
import com.shiku.im.msg.model.AddCommentParam;
import com.shiku.im.msg.service.MsgRedisRepository;
import com.shiku.im.repository.MongoRepository;
import com.shiku.utils.DateUtil;
import com.shiku.im.msg.entity.Comment;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 *
 * @version V1.0
 * @Description: TODO(todo)
 * @date 2019/9/6 16:29
 */
@Repository
public class MsgCommentDaoImpl extends MongoRepository<Comment, ObjectId> implements MsgCommentDao {

    @Autowired
    private MsgRedisRepository msgRedisRepository;
    @Override
    public Class<Comment> getEntityClass() {
        return Comment.class;
    }
    private final String s_comment="s_comment";// 评论表名称

    @Override
    public ObjectId add(int userId,String nickName, AddCommentParam param) {
        ObjectId commentId = ObjectId.get();
        Comment entity = new Comment(commentId, new ObjectId(
                param.getMessageId()), userId, nickName,
                param.getBody(), param.getToUserId(), param.getToNickname(),
                param.getToBody(), DateUtil.currentTimeSeconds());
         saveEntity(entity);
         return commentId;
    }

    //    @Override
//    public ObjectId add(int userId, AddCommentParam param) {
//        User user = SKBeanUtils.getUserManager().getUser(userId);
//        ObjectId commentId = ObjectId.get();
//        Comment entity = new Comment(commentId, new ObjectId(
//                param.getMessageId()), user.getUserId(), user.getNickname(),
//                param.getBody(), param.getToUserId(), param.getToNickname(),
//                param.getToBody(), DateUtil.currentTimeSeconds());
//		/*// 缓存评论
//		String key = String.format("msg:%1$s:comment",
//				param.getMessageId());
//		SKBeanUtils.getRedisCRUD().del(key);*/
//        SKBeanUtils.getRedisService().deleteMsgComment(param.getMessageId());
//
//        // 保存评论
//        getDatastore().save(entity);
//        // 更新消息：评论数+1、活跃度+1
//        SKBeanUtils.getMsgRepository().update(new ObjectId(param.getMessageId()),
//                Msg.Op.Comment, 1);
//
//        //新线程进行xmpp推送
//        ThreadUtil.executeInThread(new Callback() {
//            @Override
//            public void execute(Object obj) {
//                tack(userId,param);
//            }
//        });
//
//        return entity.getCommentId();
//    }


//    private void tack(int userId, AddCommentParam param){
//        User user = SKBeanUtils.getUserManager().getUser(userId);
//        // xmpp推送
//        Query<Msg> q=getDatastore().createQuery(getEntityClass());
//        Msg msg=q.filter("msgId", new ObjectId(param.getMessageId())).get();
//        int type=msg.getBody().getType();
//
//        String url=null;
//        if(type==1){
//            url=msg.getBody().getText();
//        }else if(type==2){
//            url=msg.getBody().getImages().get(0).getTUrl();
//        }else if(type==3){
//            url=msg.getBody().getAudios().get(0).getOUrl();
//        }else if(type==4){
//            url=msg.getBody().getVideos().get(0).getOUrl();
//        }
//        String u=String.valueOf(type);
//        String us=param.getMessageId()+","+u+","+url;
//        KXMPPServiceImpl.MessageBean messageBean=new KXMPPServiceImpl.MessageBean();
//        messageBean.setType(KXMPPServiceImpl.COMMENT);//类型为42
//        messageBean.setFromUserId(String.valueOf(userId));//评论者的Id
//        messageBean.setFromUserName(user.getNickname());//评论者的昵称
//				/*messageBean.setToUserId(String.valueOf(param.getToUserId()));//被回复者的ID
//				if(StringUtil.isEmpty(param.getToNickname())){
//					messageBean.setToUserName(param.getToNickname());//被回复者的昵称
//				}*/
//        messageBean.setObjectId(us);//id,type,url
//        messageBean.setContent(param.getBody());//评论内容
//        messageBean.setMessageId(StringUtil.randomUUID());
//        try {
//            List<Integer> praiseuserIdlist=new ArrayList<Integer>();
//            DBObject d=new BasicDBObject("msgId",new ObjectId(param.getMessageId()));
//            praiseuserIdlist=distinct("s_praise", "userId", d);
//
//            List<Integer> userIdlist=new ArrayList<Integer>();
//            userIdlist=distinct("s_comment","userId", d);
//
//            userIdlist.addAll(praiseuserIdlist);
//
//            userIdlist.add(msg.getUserId());
//            HashSet<Integer> hs=new HashSet<Integer>(userIdlist);
//            List<Integer> list=new ArrayList<Integer>(hs);
//            //移出集合中当前操作人
//            for (int i = 0; i < list.size(); i++) {
//                if (list.get(i).equals(userId)) {
//                    list.remove(i);
//                }
//            }
//            for(Integer toUserId : list){
//                messageBean.setToUserId(toUserId.toString());//被回复者的ID
//                if(!StringUtil.isEmpty(param.getToNickname())){
//                    messageBean.setToUserName(param.getToNickname());//被回复者的昵称
//                }
//                KXMPPServiceImpl.getInstance().send(messageBean);
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    @Override
    public boolean delete(ObjectId msgId, String commentId) {
        String[] commentIds = StringUtil.getStringList(commentId);
        for (String commId : commentIds) {
            if(!ObjectId.isValid(commId))
                continue;
            deleteById(new ObjectId(commId));
        }
        // 清除缓存
        msgRedisRepository.deleteMsgComment(msgId.toString());
        return true;
    }


//    @Override
//    public boolean delete(ObjectId msgId, String commentId) {
//        String[] commentIds = StringUtil.getStringList(commentId);
//        for (String commId : commentIds) {
//            if(!ObjectId.isValid(commId))
//                continue;
//            // 删除评论
//            Query query = getDatastore().createQuery(Comment.class).field(MongoOperator.ID).equal(new ObjectId(commId));
//            if(null != query.get()){
//                getDatastore().findAndDelete(query);
//                // 更新消息：评论数-1、活跃度-1
//                SKBeanUtils.getMsgRepository().update(msgId, Msg.Op.Comment, -1);
//            }else{
//                throw new ServiceException(KConstants.ResultCode.DataNotExists);
//            }
//        }
//        // 清除缓存
//        SKBeanUtils.getRedisService().deleteMsgComment(msgId.toString());
//        return true;
//    }

    @SuppressWarnings("deprecation")
    public List<Comment> find(ObjectId msgId, ObjectId commentId, int pageIndex, int pageSize) {
        Query query=null;
        if(null != commentId)
            query=createQuery("commentId",commentId);

        else{
           query=createQuery("msgId",msgId);
            // 倒序查询  正序返回
			/*Collections.sort(commentList,new Comparator<Comment>() {

				@Override
				public int compare(Comment o1, Comment o2) {
					if (o1.getTime() > o2.getTime()) {
						return 1;
					}else if(o1.getTime() == o2.getTime()){
						return 0;
					}
					return -1;
				}
			});*/
        }
        descByquery(query,"time");

        return queryListsByQuery(query,pageIndex,pageSize);
    }

    @Override
    public List<ObjectId> getCommentIds(Integer userId){
        Query query=createQuery("userId",userId);

        return  getDatastore().findDistinct(query,"msgId",getEntityClass(),ObjectId.class);
    }

    @Override
    public void update(int userId, Map<String, Object> map) {
        Query query=createQuery("userId",userId);
        Update ops = createUpdate();
        map.forEach((key,value)->{
            ops.set(key,value);
        });
        update(query,ops);
    }

    @Override
    public Comment getComment(ObjectId id) {
        return get(id);
    }

    @Override
    public void deleteComment(ObjectId id) {
        deleteById(id);
    }

    @Override
    public PageResult<Comment> commonListMsg(ObjectId msgId, Integer page, Integer limit) {
        PageResult<Comment> result = new PageResult<Comment>();
        Query query=createQuery("msgId", msgId);
        ascByquery(query,"time");
        result.setCount(count(query));
        result.setData(queryListsByQuery(query,page, limit, 1));
        return result;
    }
}

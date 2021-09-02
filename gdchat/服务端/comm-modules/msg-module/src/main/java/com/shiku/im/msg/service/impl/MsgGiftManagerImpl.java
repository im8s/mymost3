package com.shiku.im.msg.service.impl;

import com.google.common.collect.Lists;
import com.shiku.im.dao.GiftDao;
import com.shiku.im.dao.GiveGiftDao;
import com.shiku.im.entity.Gift;
import com.shiku.im.entity.Givegift;
import com.shiku.im.msg.dao.MsgDao;
import com.shiku.im.msg.entity.Msg;
import com.shiku.im.msg.model.AddGiftParam;
import com.shiku.im.msg.service.MsgGiftManager;
import com.shiku.im.user.entity.User;
import com.shiku.im.user.service.UserCoreService;
import com.shiku.utils.DateUtil;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 *
 * @version V1.0
 * @Description: TODO(礼物相关业务)
 * @date 2019/9/6 20:18
 */
@Service
public class MsgGiftManagerImpl implements MsgGiftManager {
    @Autowired
    private GiftDao giftDao;
    @Autowired
    private GiveGiftDao giveGiftDao;
    @Autowired
    private MsgDao msgDao;

    @Autowired
    private RedissonClient redissonClient;

    @Autowired
    private UserCoreService userCoreService;

    @Override
    public List<ObjectId> add(Integer userId, ObjectId msgId, List<AddGiftParam> paramList) {
        User user = userCoreService.getUser(userId);

        List<ObjectId> giftIdList = Lists.newArrayList();
        List<Givegift> entities = Lists.newArrayList();
        int activeValue = 0;

        for (AddGiftParam param : paramList) {
            Double price =1.0;
			/* goodsService.getGiftGoods(param.getGoodsId())
					.getPrice();*/
            activeValue += price * param.getCount();

            Givegift gift = new Givegift(param.getCount(),ObjectId.get(), msgId,
                    user.getNickname(),price, DateUtil.currentTimeSeconds(), user.getUserId(),user.getUserId());

            giftIdList.add(gift.getGiftId());
            entities.add(gift);
        }

        // 缓存礼物
        try {
            String key = String.format("msg:%1$s:gift", msgId.toString());

            for (Givegift gift : entities) {
                String string = gift.toString();
                redissonClient.getQueue(key).add(string);

            }
            redissonClient.getList(key).trim(0, 500);
            redissonClient.getBucket(key).expire(43200, TimeUnit.SECONDS);
            redissonClient.shutdown();


        } catch (Exception e) {
            e.printStackTrace();
        }

//        getDatastore().save(entities);
        giveGiftDao.addGiveGiftList(entities);
//        SKBeanUtils.getMsgRepository().update(msgId, Msg.Op.Gift, activeValue);
        msgDao.update(msgId, Msg.Op.Gift,activeValue);
        return giftIdList;
    }

    @Override
    public List<Gift> getGiftList() {
        return null;
    }

    @Override
    public List<Givegift> find(ObjectId msgId, ObjectId giftId, int pageIndex, int pageSize) {
        return giveGiftDao.find(msgId,giftId,pageIndex,pageSize);
    }

    @Override
    public List<Document> findByUser(ObjectId msgId) {
        return giftDao.findByUser(msgId);
    }

    @Override
    public List<Document> findByGift(ObjectId msgId) {
        return giftDao.findByGift(msgId);
    }
}

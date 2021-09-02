package com.shiku.im.user.entity;

import com.shiku.im.user.constants.MoneyLogConstants;
import com.shiku.im.user.constants.MoneyLogConstants.*;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 用户余额更新记录
 */
@Data

@Document("usermoeny_log")
public class UserMoneyLog {
    public UserMoneyLog(){

    }

    public UserMoneyLog(int userId, int toUserId,
                        String businessId, double moeny, MoneyLogConstants.MoenyAddEnum changeType,

                        MoneyLogConstants.MoneyLogEnum businessType, MoneyLogConstants.MoneyLogTypeEnum logType) {
        this.userId = userId;
        this.toUserId = toUserId;
        this.businessId = businessId;
        this.moeny = moeny;
        this.changeType=changeType.getType();
        this.businessType = businessType.getType();
        this.logType = logType.getType();


    }



    public void setBeforeMoenyAndEndMoeny(double beforeMoeny,double endMoeny){
        this.beforeMoeny=beforeMoeny;
        this.endMoeny=endMoeny;
        /**
         * 创建时间毫秒
         */
        //this.createTime=System.currentTimeMillis();

    }


    /**
     * %s
     * %s [余额记录成功]-> to %s %s  %s %s  %s  当前余额 %s
     */
    private static  final String DESCRIPTION_FORMAT = "%s [余额记录成功]-> to %s %s  %s %s  %s  当前余额 %s";

    public void createDescription(){

        this.description=String.format(DESCRIPTION_FORMAT,
                this.userId,this.toUserId,
                MoneyLogEnum.getMoneyLogDesc(this.getBusinessType()),
                MoneyLogTypeEnum.getLogTypeDesc(this.getLogType()),
                MoenyAddEnum.getAddTypeDesc(this.getChangeType()),
                this.getMoeny(),this.getEndMoeny()

                );

    }

    @Id
    private ObjectId id;

    /**
     * 用户ID
     */
    @Indexed
    private int userId;


    /**
     * 记录描述
     */
    private String description;

    /**
     * 对方用户ID
     */
    private int toUserId;




    /**
     * 业务ID
     */
    private String businessId;

    /**
     * 操作记录 毫秒
     */
    private long createTime;


    /**
     * 操作前余额
     */
    private double beforeMoeny;

    /**
     * 改变余额
     */
    private double moeny;

    /**
     * 1 增加余额
     * 2.减少余额
     */

    private byte changeType;

    /**
     * 操作后余额
     */
    private double endMoeny;


    /**
     * 1:发送/支出 操作
     *
     * 2:领取/收入 操作
     *
     * 3:退款操作
     *
     * 5:锁定余额操作
     *
     * 6:取消锁定余额操作
     *
     *
     *-1:异常回滚操作
     */
    private byte logType;


    /**
     * @link MoneyLogEnum
     * 业务类型
     */
    @Indexed
    private byte businessType;


    /**
     * 自定义参数
     */
    private String extra;


}

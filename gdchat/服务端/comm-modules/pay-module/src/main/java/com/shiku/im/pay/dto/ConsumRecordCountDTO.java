package com.shiku.im.pay.dto;

import com.shiku.im.pay.entity.BaseConsumeRecord;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * 按照时间查询账单 统计
 */
@Setter
@Getter
public class ConsumRecordCountDTO {

    private double income;

    private double expenses;


    private List<BaseConsumeRecord> recordList;




}

package com.shiku.im.mpserver.utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 
 * @Date Created in 2019/9/17 10:43
 * @description TODO
 * @modified By:  验证手机号码
 */
public class MobileValidateUtils {

    public static boolean checkMobileNumber(String mobileNumber) {

        if (mobileNumber.length() != 11){
            return false;
        }

        boolean flag = false;
        try {
            Pattern regex = Pattern.compile("^1[345789]\\d{9}$");
            Matcher matcher = regex.matcher(mobileNumber);
            flag = matcher.matches();
        } catch (Exception e) {
            e.printStackTrace();
            flag = false;

        }
        return flag;
    }
}

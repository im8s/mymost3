package com.shiku.im.mpserver.utils;


import com.shiku.utils.StringUtil;

/**
 * 
 * @Date Created in 2019/9/16 20:33
 * @description TODO  营业执照 统一社会信用代码（18位）
 * @modified By:
 */
public class BusinessUtils {
    /**
     * @since 1.0.0
     * 
     * @date 2019/9/17 9:43
     *  校验18位统一社会信用
     */
    public static boolean isBusinessLicense18(String license) {
        if(StringUtil.isEmpty(license)) {
            return false;
        }
        if(license.length() != 18) {
            return false;
        }

        String regex = "^([159Y]{1})([1239]{1})([0-9ABCDEFGHJKLMNPQRTUWXY]{6})([0-9ABCDEFGHJKLMNPQRTUWXY]{9})([0-90-9ABCDEFGHJKLMNPQRTUWXY])$";
        if (!license.matches(regex)) {
            return false;
        }
        String str = "0123456789ABCDEFGHJKLMNPQRTUWXY";
        int[] ws = { 1, 3, 9, 27, 19, 26, 16, 17, 20, 29, 25, 13, 8, 24, 10, 30, 28 };
        String[] codes = new String[2];
        codes[0] = license.substring(0, license.length() - 1);
        codes[1] = license.substring(license.length() - 1, license.length());
        int sum = 0;
        for (int i = 0; i < 17; i++) {
            sum += str.indexOf(codes[0].charAt(i)) * ws[i];
        }
        int c18 = 31 - (sum % 31);
        if (c18 == 31) {
            c18 = 0;
        }
        if (str.charAt(c18) != codes[1].charAt(0)) {
            return false;
        }
        return true;
    }


    public static String ERROR_COMMON = "您输入的营业执照注册号%s，请核对后再输!";

    /**
     * @since 1.0.0
     * 
     * @date 2019/9/17 9:44
     * 校验15位的营业执照注册号
     */
    public static boolean isBusinessLicense15(String businessLicense) {

        if ("".equals(businessLicense) || " ".equals(businessLicense)) {
            return false;
        } else if (businessLicense.length() != 15) {
            return false;
        }else if (isBusinessLicense(businessLicense)) {// 传入15位 只校验营业执照的有效性推荐用这个
            return true;
        }else {
            return false;
        }
    }

    /**
     * 获取 营业执照注册号的校验码
     *
     * @param businessLicense 为15为返回1为有效，否则无效；传入14为则会计算出第15位的校验码。
     * @return
     */
    private static int getCheckCode(String businessLicense, boolean getCheckCode) {
        int result = -1;
        if (null == businessLicense || businessLicense.trim().equals("")|| businessLicense.length() != 15) {
            return result;
        }else{
            int ti = 0;
            int si = 0; // pi|11+ti
            int cj = 0; // （si||10==0？10：si||10）*2
            int pj = 10; // pj=cj|11==0?10:cj|11
            for (int i = 0; i < businessLicense.length(); i++) {
                ti = Integer.parseInt(businessLicense.substring(i,i+1));
                si = pj + ti;
                cj = (0 == si % 10 ? 10 : si % 10) * 2;
                pj = (cj % 11) == 0 ? 10 : (cj % 11);
                if (i == businessLicense.length()-2 && getCheckCode) {
                    result = (1 - pj < 0 ? 11 - pj : 1 - pj) % 10;// 返回营业执照注册号的校验码
                    return result;
                }
                if (i == businessLicense.length()-1) {
                    result = si % 10; // 返回1 表示是一个有效营业执照号
                }
//                System.out.println(i + " ti=" + ti + ", si=" + si + ", cj=" + cj + ", pj=" + pj);
            }
        }
        return result;
    }

    //1 -- 有效   -1 -- 无效
    private static boolean isBusinessLicense(String businessLicense) {
        return 1 == getCheckCode(businessLicense, false);
    }


    public static int  getComputeCheckCode(String businessLicense){
        return getCheckCode(businessLicense,true);
    }
}

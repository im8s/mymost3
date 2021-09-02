package com.shiku.im.user.utils;

import com.shiku.utils.encrypt.AES;
import com.shiku.utils.encrypt.MD5;

public final class MoneyUtils {

    private final static byte[] saltComm = new byte[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

    private  final static String salt="1b07762b14ebf17f";
    public static byte[] encrypt(double encrypt,String userId){
        byte[] keys= MD5.encrypt(salt + userId);
        return  AES.encrypt(String.valueOf(encrypt).getBytes(),keys);
    }

    public static double decrypt(byte[] byteMoney,String userId){
        double result=0.0;
        byte[] keys= MD5.encrypt(salt + userId);
        String hex = null;
        try {
            hex = AES.decryptString(byteMoney,keys);
            result=Double.valueOf(hex);
        } catch (Exception e) {
          throw e;
        }

        return result;
    }
}

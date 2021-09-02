package com.shiku.im.i18n;


import com.shiku.im.comm.utils.ReqUtil;
import net.bytebuddy.build.EntryPoint;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.SearchStrategy;
import org.springframework.context.MessageSource;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;


public class LocaleMessageUtils {

    private static  MessageSource messageSource;


    public static final Locale DEFAULT_LOCALE=Locale.CHINESE;

    private static Map<String,Locale> localeMap;
    static {
        localeMap=new HashMap<>();
        localeMap.put("zh",DEFAULT_LOCALE);
        localeMap.put("en",new Locale("en",""));
        localeMap.put("big5",new Locale("big5",""));

    }

    public static void setMessageSource(MessageSource messageSource) {
        LocaleMessageUtils.messageSource = messageSource;
        System.out.println("LocaleMessageUtils ====> init");
        LocaleContextHolder.setDefaultLocale(DEFAULT_LOCALE);
    }
    public static Locale getRequestLocale() {
        try {
            Locale locale = localeMap.get(ReqUtil.getRequestLanguage());
            if(null==locale) {
                locale=DEFAULT_LOCALE;
            }
           return locale;
        } catch (Exception e) {
            return DEFAULT_LOCALE;
        }
    }


    public static String getMessage(String msgKey, Object[] args) {
        try {
            Locale locale = localeMap.get(ReqUtil.getRequestLanguage());
            if(null==locale) {
                locale=DEFAULT_LOCALE;
            }
            return messageSource.getMessage(msgKey, args, locale);
        } catch (Exception e) {
           return msgKey;
        }
    }
    /**
     * 获取单个国际化翻译值
     */
    public static String getMessage(String msgKey) {
        Locale locale = localeMap.get(ReqUtil.getRequestLanguage());
        try {
            if(null==locale) {
                locale=DEFAULT_LOCALE;
            }
            return messageSource.getMessage(msgKey, null, locale);
        } catch (Exception e) {
           return msgKey;
        }
    }

    /**
     * 获取单个国际化翻译值
     */
    public static String getMessage(String msgKey,Locale locale) {
        try {
            return messageSource.getMessage(msgKey, null, locale);
        } catch (Exception e) {
            return msgKey;
        }
    }


}

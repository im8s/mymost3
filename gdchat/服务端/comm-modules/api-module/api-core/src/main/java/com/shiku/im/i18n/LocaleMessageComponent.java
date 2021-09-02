package com.shiku.im.i18n;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
public class LocaleMessageComponent {

    @Autowired
    private MessageSource messageSource;


    @PostConstruct
    public void initMessageSource(){
        LocaleMessageUtils.setMessageSource(messageSource);
    }

    /**
     * 默认拦截器 其中lang表示切换语言的参数名
     * 例如:   ?lang=zh_CN
     */
   /* @Bean
    public WebMvcConfigurer localeInterceptor() {
        *//**
         *
         *//*

        System.out.println(" localeInterceptor===> ");
        return new WebMvcConfigurer() {
            @Override
            public void addInterceptors(InterceptorRegistry registry) {
                LocaleChangeInterceptor localeInterceptor = new LocaleChangeInterceptor();
                localeInterceptor.setParamName("language");
                registry.addInterceptor(localeInterceptor);
            }
        };
    }*/
}

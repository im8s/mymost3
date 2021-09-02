package com.shiku.im.service;


import com.shiku.im.user.service.AbstractUserHandlerImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

@Service
public class UserHandlerImpl extends AbstractUserHandlerImpl {


    @Autowired
    protected ApplicationContext applicationContext;



    @Override
    public void publishEvent(Object event) {
        applicationContext.publishEvent(event);
    }
}

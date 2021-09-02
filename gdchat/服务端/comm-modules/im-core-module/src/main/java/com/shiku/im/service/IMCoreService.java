package com.shiku.im.service;

import com.shiku.im.entity.ClientConfig;
import com.shiku.im.entity.Config;
import com.shiku.im.entity.PayConfig;
import com.shiku.im.repository.CoreRedisRepository;
import com.shiku.im.repository.IMCoreRepository;
import com.shiku.im.utils.ConstantUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class IMCoreService {

    @Autowired
    private IMCoreRepository imCoreRepository;


    @Autowired
    private CoreRedisRepository coreRedisRepository;


    public Config getConfig() {
        Config config=null;
        try {
            config= coreRedisRepository.getConfig();
            if(null==config){
                config = imCoreRepository.getConfig();
                if(null==config)
                    config=new Config();
                coreRedisRepository.setConfig(config);
            }
        } catch (Exception e) {
            log.error(e.getMessage());
            config = imCoreRepository.getConfig();
        }

        return config;
    }
    public void setConfig(Config dest){
        imCoreRepository.setConfig(dest);
        coreRedisRepository.setConfig(dest);
    }

    public void setClientConfig(ClientConfig clientconfig){
        imCoreRepository.setClientConfig(clientconfig);
        coreRedisRepository.setClientConfig(clientconfig);
    }

    public ClientConfig getClientConfig() {
        ClientConfig clientconfig=null;
        try {
            clientconfig=coreRedisRepository.getClientConfig();
            if(null==clientconfig){
                clientconfig = imCoreRepository.getClientConfig();
                if(null==clientconfig)
                    clientconfig=new ClientConfig();
            }
        } catch (Exception e) {
            log.error(e.getMessage());
            clientconfig = imCoreRepository.getClientConfig();
        }

        return clientconfig;
    }

    public void setPayConfig(PayConfig payConfig){
        imCoreRepository.setPayConfig(payConfig);
        coreRedisRepository.setPayConfig(payConfig);
//        ConstantUtil.setPayConfig(payConfig);
    }

    public PayConfig getPayConfig(){
        PayConfig payConfig = null;
        try {
            payConfig = coreRedisRepository.getPayConfig();
            if(null == payConfig){
                payConfig = imCoreRepository.getPayConfig();
                if(null == payConfig){
                    payConfig = new PayConfig();
                }
            }
        } catch (Exception e){
            log.error(e.getMessage());
            payConfig = imCoreRepository.getPayConfig();
        }
        return payConfig;
    }
}

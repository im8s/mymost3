package com.shiku.mianshi.swagger;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.ParameterBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.schema.ModelRef;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Parameter;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;

import java.util.ArrayList;
import java.util.List;

/**
 * Swagger配置类
 *
 *
 */
@Configuration
public class Swagger2 {

    @Bean
    public Docket createRestApi() {
    //设置Swagger全局参数start
        ParameterBuilder ticketPar = new ParameterBuilder();
        List<Parameter> pars = new ArrayList<Parameter>();
        ticketPar.name("access_token").description("访问令牌  登陆后的接口操作为必要值")
                .modelRef(new ModelRef("string")).parameterType("query").defaultValue("123456")
                .required(true).build(); //header中的ticket参数非必填，传空也可以
        pars.add(ticketPar.build());    //根据每个方法名也知道当前方法在设置什么参数
    //设置Swagger全局参数end


        return new Docket(DocumentationType.SWAGGER_2)
                .enable(true)       //是否开启swagger
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.shiku.im"))//扫描接口的路径
                .paths(PathSelectors.any())
                .build()
                .globalOperationParameters(pars)
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Swagger2在线接口文档")
                .description("测试接口文档")
                .version("3.0")
                .build();
    }
}
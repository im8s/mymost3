package com.shiku.im.user.model;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

@Data
@ApiModel("公私钥匙类")
public class KeyPairParam {
	@ApiModelProperty("RSA公钥")
    private String rsaPublicKey="";
	@ApiModelProperty("RSA私钥")
    private  String rsaPrivateKey="";

	@ApiModelProperty("DH公钥")
    private String dhPublicKey="";
	@ApiModelProperty("DH公钥")
    private String dhPrivateKey="";

	@ApiModelProperty("mac值")
    private String mac="";
}

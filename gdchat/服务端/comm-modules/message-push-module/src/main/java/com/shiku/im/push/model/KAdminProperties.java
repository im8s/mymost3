package com.shiku.im.push.model;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "admin")
public class KAdminProperties {
	private String systemUsers;// IM系统用户
	

	public String getSystemUsers() {
		return systemUsers;
	}

	public void setSystemUsers(String systemUsers) {
		this.systemUsers = systemUsers;
	}
}

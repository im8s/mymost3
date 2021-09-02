package com.shiku.controller;

import com.shiku.UploadApplication;
import com.shiku.commons.utils.ResourcesDBUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
* @Description: TODO(用一句话描述该文件做什么)
* @author lidaye
* @date 2018年7月27日 
*/
@Controller
public class UploadController {

	private static final Logger log = LoggerFactory.getLogger(UploadController.class);

	@RequestMapping("/")
	public String  index() {
		return "index";
	}


}


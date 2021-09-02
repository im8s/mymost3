package com.shiku.task;

import com.shiku.UploadApplication;
import com.shiku.commons.utils.ResourcesDBUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimerTask;

/**
* @Description: TODO(定时删除文件 )
* @author lidaye
* @date 2018年5月24日 
*/


@Component
public class FileDeleteTask extends TimerTask {
	private static final Logger log = LoggerFactory.getLogger(UploadApplication.class);
	public FileDeleteTask() {
		log.info(getClass()+"======> init >");
	}
	
	@Override
	public void run() {
		Date currentTime = new Date();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String dateString = formatter.format(currentTime);
		log.info("=== 执行定时任务 删除 run =====> "+dateString);
		
		ResourcesDBUtils.runDeleteFileTask();
		
		
	}
	
	@Override
	public boolean cancel() {
		// TODO Auto-generated method stub
		return super.cancel();
	}



	/**
	 * 每天执行一次定时任务     每天凌晨2:00定时删除 0 0 0 * *
	 */
	@Scheduled(cron = "0 0 2 * * ?")
	public void executeDayTask(){

		log.info("=== Start Run Delete Files Task =====> ");

		ResourcesDBUtils.delFileFromDelCollection();

		log.info("===== End Delete Files Task ====> ");
	}

}


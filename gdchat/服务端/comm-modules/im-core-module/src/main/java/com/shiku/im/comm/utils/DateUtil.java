package com.shiku.im.comm.utils;

import com.shiku.utils.Money;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.regex.Pattern;

public final class DateUtil {

	public static final SimpleDateFormat FORMAT_YYYY_MM;
	public static final SimpleDateFormat FORMAT_YYYY_MM_DD;
	public static final SimpleDateFormat FORMAT_YMDHMS;
	public static final Pattern PATTERN_YYYY_MM;
	public static final Pattern PATTERN_YYYY_MM_DD;
	public static final Pattern PATTERN_YYYY_MM_DD_HH_MM_SS;

	static {
		FORMAT_YMDHMS = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		FORMAT_YYYY_MM_DD = new SimpleDateFormat("yyyy-MM-dd");
		FORMAT_YYYY_MM = new SimpleDateFormat("yyyy-MM");
		PATTERN_YYYY_MM_DD_HH_MM_SS = Pattern.compile("[0-9]{4}-[0-9]{1,2}-[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}");
		PATTERN_YYYY_MM_DD = Pattern.compile("[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}");
		PATTERN_YYYY_MM = Pattern.compile("[0-9]{4}-[0-9]{1,2}");
	}

	/**
	 * 精确到秒
	 */
	public static long currentTimeSeconds() {
		return System.currentTimeMillis() / 1000;
	}
	
	/**  
	*  精确到毫秒 Millisecond
	**/ 
	public static long currentTimeMilliSeconds() {
		return System.currentTimeMillis();
	}

	public static String getFullString() {
		return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
	}

	public static String getYMDString() {
		return new SimpleDateFormat("yyyyMMdd").format(new Date());
	}

	public static String getYMString() {
		return new SimpleDateFormat("yyyyMM").format(new Date());
	}
	public static String getY_MString() {
		return new SimpleDateFormat("yyyy-MM").format(new Date());
	}
	public static String getMDString() {
		return new SimpleDateFormat("MM-dd").format(new Date());
	}
	
	public static String getTimeString(long millis) {
		return FORMAT_YMDHMS.format(new Date(millis));
	}

	public static Date toDate(String strDate) {
		return cn.hutool.core.date.DateUtil.parse(strDate);
	}

	public static long toTimestamp(String strDate) {
		return toDate(strDate).getTime();
	}

	public static long toSeconds(String strDate) {
		return toTimestamp(strDate) / 1000;
	}

	public static long s2s(String s) {
		s = StringUtil.trim(s);
		if ("至今".equals(s)) {
			return 0;
		}
		return toSeconds(s);
	}
	
	
	
	
	
	/**
	 * 比较两个时间的年月日是否相同
	 * @param d1  时间1
	 * @param d2  时间2
	 * @return
	 */
	public static boolean compareDayTime(Calendar d1,Calendar d2){
		int d1_year=d1.get(Calendar.YEAR);
		int d1_month=d1.get(Calendar.MONTH);
		int d1_day=d1.get(Calendar.DAY_OF_MONTH);
		int d2_year=d2.get(Calendar.YEAR);
		int d2_month=d2.get(Calendar.MONTH);
		int d2_day=d2.get(Calendar.DAY_OF_MONTH);
		if(d1_year==d2_year&&d1_month==d2_month&&d1_day==d2_day)return true;
	    return false;
	}
	/**
	 * 比较两个时间的年月是否相同
	 * @param d1  时间1
	 * @param d2  时间2
	 * @return
	 */
	public static boolean compareMonthTime(Calendar d1,Calendar d2){
		int d1_year=d1.get(Calendar.YEAR);
		int d1_month=d1.get(Calendar.MONTH);
		int d2_year=d2.get(Calendar.YEAR);
		int d2_month=d2.get(Calendar.MONTH);
		if(d1_year==d2_year&&d1_month==d2_month)return true;
	    return false;
	}
	/**
	 * 获取上传路径的前缀
	 * @return
	 */
	/*public static String getUploadPathPrefix(){
		 ResourceBundle bundle = ResourceBundle.getBundle("application");  
		  return bundle.getString("upload.path.prefix");  
	}*/
	
	
	public static Date getNextDay(Date currentDay){    
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(currentDay);
		calendar.add(Calendar.DATE, 1);
		Date nextDay = calendar.getTime();
		return nextDay;
	}
	/**
	 *  获得当天0点时间
	 * @return
	 */
		public static Date getTodayMorning() {
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());//把当前时间赋给cal
			cal.set(Calendar.HOUR_OF_DAY, 0);
			cal.set(Calendar.SECOND, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.MILLISECOND, 0);
			return cal.getTime();
		}

	/**
	 *  获得当天24点时间
	 * @return
	 */
		public static Date getTodayNight() {
			Calendar cal = Calendar.getInstance();
			cal.set(Calendar.HOUR_OF_DAY, 24);
			cal.set(Calendar.SECOND, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.MILLISECOND, 0);
			return  cal.getTime();
		}
		
		/** @Description:（获得第n后的当前时间） 
		* @param times 当前时间
		* @param days  第n天
		* @param type  0:后n天 , 1:前n天
		* @return
		**/ 
		public static long getOnedayNextDay(long times,int days,int type){
			final long ruleTimes = 86400;// 基数
			return (0 == type ? times+(ruleTimes*days) : times-(ruleTimes*days));
		}



		/**
		 *  获得昨天0点时间
		 * @return
		 */
			public static Date getYesterdayMorning() {
				Calendar cal = Calendar.getInstance();
				cal.add(Calendar.DATE, -1);
				cal.set(Calendar.HOUR_OF_DAY, 0);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MINUTE, 0);
				cal.set(Calendar.MILLISECOND, 0);
				return cal.getTime();
			}
			/**
			 *  获得昨天23.59点时间
			 * @return
			 */
				public static Date getYesterdayLastTime() {
					Calendar cal = Calendar.getInstance();
					cal.add(Calendar.DATE, -1);
					cal.set(Calendar.HOUR_OF_DAY, 23);
					cal.set(Calendar.SECOND, 0);
					cal.set(Calendar.MINUTE, 59);
					cal.set(Calendar.MILLISECOND,00);
					return cal.getTime();
				}
		/**
		 *  获得昨天24点时间
		 * @return
		 */
			public static Date getYesterdayNight() {
				Calendar cal = Calendar.getInstance();
				cal.add(Calendar.DATE, -1);
				cal.set(Calendar.HOUR_OF_DAY, 24);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MINUTE, 0);
				cal.set(Calendar.MILLISECOND, 0);
				return  cal.getTime();
			}
			
			/**
			 *  获得明天0点时间
			 * @return
			 */
				public static Date getTomorrowMorning() {
					Calendar cal = Calendar.getInstance();
					cal.add(Calendar.DATE, 1);
					cal.set(Calendar.HOUR_OF_DAY, 0);
					cal.set(Calendar.SECOND, 0);
					cal.set(Calendar.MINUTE, 0);
					cal.set(Calendar.MILLISECOND, 0);
					return cal.getTime();
				}
				/**
				 *  获得明天23.59点时间
				 * @return
				 */
					public static Date getTomorrowLastTime() {
						Calendar cal = Calendar.getInstance();
						cal.add(Calendar.DATE, 1);
						cal.set(Calendar.HOUR_OF_DAY, 23);
						cal.set(Calendar.SECOND, 0);
						cal.set(Calendar.MINUTE, 59);
						cal.set(Calendar.MILLISECOND,00);
						return cal.getTime();
					}
			/**
			 *  获得明天24点时间
			 * @return
			 */
				public static Date getTomorrowNight() {
					Calendar cal = Calendar.getInstance();
					cal.add(Calendar.DATE, 1);
					cal.set(Calendar.HOUR_OF_DAY, 24);
					cal.set(Calendar.SECOND, 0);
					cal.set(Calendar.MINUTE, 0);
					cal.set(Calendar.MILLISECOND, 0);
					return  cal.getTime();
				}

		/**
		 *  获得本周一0点时间
		 * @return
		 */
		public static Date getWeekMorning() {
			Calendar cal = Calendar.getInstance();
			cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONDAY), cal.get(Calendar.DAY_OF_MONTH), 0, 0, 0);
			cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
			return  cal.getTime();
		}

		/**
		 * 获得本周日24点时间
		 * @return
		 */
		public  static Date getWeekNight() {
			Calendar cal = Calendar.getInstance();
			cal.setTime(getWeekMorning());
			cal.add(Calendar.DAY_OF_WEEK, 7);
			return cal.getTime();
		}

		/**
		 * 获得本月第一天0点时间
		 * @return
		 */
		public static Date getMonthMorning() {
			Calendar cal = Calendar.getInstance();
			cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONDAY), cal.get(Calendar.DAY_OF_MONTH), 0, 0, 0);
			cal.set(Calendar.DAY_OF_MONTH, cal.getActualMinimum(Calendar.DAY_OF_MONTH));
			return  cal.getTime();
		}

		/**
		 *  获得本月最后一天24点时间
		 * @return
		 */
		public static Date getMonthNight() {
			Calendar cal = Calendar.getInstance();
			cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONDAY), cal.get(Calendar.DAY_OF_MONTH), 0, 0, 0);
			cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
			cal.set(Calendar.HOUR_OF_DAY, 24);
			return cal.getTime();
		}
		
		/**
		 *  获得上月第一天0点时间
		 * @return
		 */
		public static Date getLastMonthMorning(){
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());//把当前时间赋给cal
			cal.add(Calendar.MONTH, -1);
			cal.set(Calendar.DAY_OF_MONTH, 1);
			cal.set(Calendar.HOUR_OF_DAY,00);
			cal.set(Calendar.SECOND, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.MILLISECOND, 0);
			return cal.getTime();
		}
		
		/**
		 * 获取上周一0点
		 * @return
		 */
		public static Date getPreviousWeekday(){
			 Calendar cal = Calendar.getInstance();
			 cal.setFirstDayOfWeek(Calendar.MONDAY);
		        cal.add(Calendar.DATE, -7);
		        cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
		    	cal.set(Calendar.HOUR_OF_DAY, 0);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MINUTE, 0);
				cal.set(Calendar.MILLISECOND, 0);
		       
			return cal.getTime();
		}
		
		
		
		/**
		 * 获取当前时间的前一年的0点
		 */
		public static Date getLastYear(){
			Calendar cal = Calendar.getInstance();
			 cal.setTime(new Date());
		     cal.add(Calendar.YEAR, -1);
		     cal.set(Calendar.HOUR_OF_DAY,00);
			 cal.set(Calendar.SECOND, 0);
			 cal.set(Calendar.MINUTE, 0);
			 cal.set(Calendar.MILLISECOND, 0);
			 return cal.getTime();
		}
		/**
		 * 获取当前时间的下一年的0点
		 */
		public static Date getNextYear(){
			Calendar cal = Calendar.getInstance();
			 cal.setTime(new Date());
		     cal.add(Calendar.YEAR, +1);
		     return cal.getTime();
		}
		
		
		
		/**
		 *  获得当前时间一个月前的时间
		 * @return
		 */
		public static Date getLastMonth(){
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());//把当前时间赋给cal
			cal.add(Calendar.MONTH, -1); 
			cal.set(Calendar.HOUR_OF_DAY,00);
			cal.set(Calendar.SECOND, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.MILLISECOND, 0);
			return cal.getTime();
		}
		
		
		
		/**
		 *  获得当前时间的三个月前的时间
		 * @return
		 */
		public static Date getLast3Month(){
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());//把当前时间赋给cal
			cal.add(Calendar.MONTH, -3); //设置为前3月
			return cal.getTime();
		}
		
		
		/**
		 * 获取上周日23点59分
		 * @return
		 */
		public static Date getPreviousWeekSunday(){
			 Calendar cal = Calendar.getInstance();
			 cal.setFirstDayOfWeek(Calendar.MONDAY);
		     cal.add(Calendar.DATE, -7);
		     cal.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
		     cal.set(Calendar.HOUR_OF_DAY, 23);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MINUTE, 59);
				cal.set(Calendar.MILLISECOND,00);
			return cal.getTime();
		}

		/**
        * 时间戳转年月日
        * 
        * @param long strDateTime：日期时间的字符串形式
        * @return timestamp
        * @throws
        */
		public static String strToDateTime(long strDateTime){
        	String timestamp;
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = new Date(strDateTime*1000);
            timestamp = simpleDateFormat.format(date);
            return ("1970-01-01 08:00:00".equals(timestamp)?null:timestamp);
        }
		
        public static String TimeToStr(Date date){//可以用
        	SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        	return format.format(date);
        }
        public static Date strYYMMDDToDate(String strYYMMDD) {
        	SimpleDateFormat format = new SimpleDateFormat("yy-MM-dd");
            try {
				return format.parse(strYYMMDD);
			} catch (ParseException e) {
				e.printStackTrace();
			}
            return null;
		}
	
        /**
    	 * 将字符串装换为Date类型
    	 * @param time 字符串时间
    	 * @param pattern 匹配格式
    	 * @return 返回Date格式时间
    	 * @throws ParseException 转换异常
    	 */
    	public static Date getDate(String time,String pattern) throws ParseException{
    		SimpleDateFormat sdf=new SimpleDateFormat(pattern);
    		if(!StringUtils.isEmpty(time))
    		  return sdf.parse(time);
    		return null;
    	}
    	/**
    	 * 将Date类型装换为字符串
    	 * @param date 时间
    	 * @param pattern 匹配格式
    	 * @return 返回字符串格式时间
    	 */
    	public static String getDateStr(Date date,String pattern){
    		SimpleDateFormat sdf=new SimpleDateFormat(pattern);
    		return sdf.format(date);
    	}

		/**
		 * 获取系统时间，加同步锁
		 * @return
		 */
		public synchronized static  long getSysCurrentTimeMillis_sync() {
			return System.currentTimeMillis();
		}
		
		/* public static String getDiff(long start, long end) {
		 long diff = end - start;
		 long day = diff / 86400;
		 long hour = diff % 86400 / 3600;
		 long minute = (diff % 86400 % 3600) / 60;
		 return MessageFormat.format("{0}天{1}时{2}分", diff / 86400, diff % 86400 /
		 3600, (diff % 86400 % 3600) / 60);
		 }
		
		 public static void main(String... args) {
		 long a = System.currentTimeMillis() + 86400 * 7;
		 System.out.println(a + 121);
		 System.out.println(getDiff(System.currentTimeMillis(), a + 79504));
		 System.out.println(getDiff(System.currentTimeMillis(), a + 121));
		 System.out.println(getDiff(System.currentTimeMillis(),
		 System.currentTimeMillis() + 121));
		
		 long b = 1420788389937L;
		 System.out.println(b % 86400);
		 System.out.println(b % 86400 % 3600);
		 System.out.println((b % 86400) % 3600);
		 }*/
		 
		// 十位数时间戳转年月日 eg:1565941038 , yyyy-MM-dd 
		 public static String timestamp2Date(String str_num,String format ) {  
			    SimpleDateFormat sdf = new SimpleDateFormat(format);  
			    if (str_num.length() == 13) {  
			        String date = sdf.format(new Date(Long.parseLong(str_num)));  
			        return date;  
			    } else {  
			        String date = sdf.format(new Date(Integer.parseInt(str_num) * 1000L));  
			        return date;  
			    }  
			}

	/**
	 * 小时转秒
	 */
	public static long hoursToSeconds(double hours){
		long time = (long) hours*60*60;
		return time;
	}

	/**
	 * 秒转小时
	 */
	public static double secondsToHours(long seconds){
		BigDecimal time = new BigDecimal(seconds);
		time = time.divide(new BigDecimal(60), 2, BigDecimal.ROUND_HALF_UP).divide(new BigDecimal(60),2,BigDecimal.ROUND_HALF_UP);
		return time.doubleValue();
	}

	public static String toHoursMinute(long seconds){
		int time = (int)seconds;
		String timeStr = null;
		int hour = 0;
		int minute = 0;
		int second = 0;
		minute = time/60;
		if (minute < 60) {
			 second = time % 60;
			 timeStr = "00:"+unitFormat(minute) + ":" + unitFormat(second);
		 } else {
			 hour = minute / 60;
			 minute = minute % 60;
			 second = time - hour * 3600 - minute * 60;
			 timeStr = unitFormat(hour) + ":" + unitFormat(minute) + ":" + unitFormat(second);
		 }
		return timeStr;
	}

	private static String unitFormat(int i) {
		 String retStr = null;
		 if (i >= 0 && i < 10)
				 retStr = "0" + i;
		 else
			 retStr = "" + i;
		 return retStr;
	 }
}

package com.shiku.im.sms;

import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.IAcsClient;
import com.aliyuncs.dysmsapi.model.v20170525.SendSmsRequest;
import com.aliyuncs.dysmsapi.model.v20170525.SendSmsResponse;
import com.aliyuncs.exceptions.ClientException;
import com.aliyuncs.profile.DefaultProfile;
import com.aliyuncs.profile.IClientProfile;
import com.shiku.im.sms.model.SmsConfig;
import com.shiku.im.sms.utils.HttpClientUtil;
import com.shiku.utils.StringUtil;
import com.shiku.utils.WebNetEncode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;

/** @version:（1.0） 
* @ClassName	SMSPushUtils
* @Description: （短信验证服务） 
* @date:2018年9月8日下午12:20:30  
*/ 
@Component
public class SMSVerificationUtils {
	
	protected static Logger smsLogger=LoggerFactory.getLogger("SMSVerificationUtils");

	@Autowired
	private  SmsConfig smsConfig;
	public static final String SMSFORMAT = "00";
	
	public  SendSmsResponse sendSms(String telephone, String code, String areaCode,int type) throws ClientException {
		// 可自助调整超时时间
		System.setProperty("sun.net.client.defaultConnectTimeout", "10000");
		System.setProperty("sun.net.client.defaultReadTimeout", "10000");

		// 初始化acsClient,暂不支持region化
		IClientProfile profile = DefaultProfile.getProfile("cn-hangzhou", smsConfig.getAccesskeyid(),
				smsConfig.getAccesskeysecret());
		DefaultProfile.addEndpoint("cn-hangzhou", "cn-hangzhou", smsConfig.getProduct(),
				smsConfig.getDomain());
		IAcsClient acsClient = new DefaultAcsClient(profile);

		// 组装请求对象-具体描述见控制台-文档部分内容
		SendSmsRequest request = new SendSmsRequest();
		// 必填:待发送手机号
		smsLogger.info("格式化手机号 :  00 + 国际区号 + 号码   ==========>"+"   SMSFORMAT :"+ SMSFORMAT +"  areaCode: " + areaCode);
		System.out.println("telephone = " + telephone);
		request.setPhoneNumbers(SMSFORMAT + telephone);// 接收号码格式为00+国际区号+号码
		// 必填:短信签名-可在短信控制台中找到
		request.setSignName(smsConfig.getSignname());
		// 必填:短信模板-可在短信控制台中找到
//		request.setTemplateCode(smsConfig.getEnglish_templetecode());
		// 886台湾 852香港
		/*if ("86".equals(areaCode) || "886".equals(areaCode) || "852".equals(areaCode))
			request.setTemplateCode(smsConfig.getChinase_templetecode());*/
		if("86".equals(areaCode)){
			if(type == 1){
				request.setTemplateCode(smsConfig.getChinase_templetecode());
			}else if(type == 2){// 云钱包开户短信验证码
				request.setTemplateCode(smsConfig.getCloudWalletVerification());
			}else if(type == 3){
				request.setTemplateCode(smsConfig.getCloudWalletNotification());
			}

		}else{
			request.setTemplateCode(smsConfig.getInternational_templetecode());
		}

		// 可选:模板中的变量替换JSON串,如模板内容为"亲爱的用户,您的验证码为${code}"时,此处的值为
		if(!StringUtil.isEmpty(code)){
			request.setTemplateParam("{\"code\":\"" + code + "\"}");
		}

		// 选填-上行短信扩展码(无特殊需求用户请忽略此字段)
		// request.setSmsUpExtendCode("90997");

		// 可选:outId为提供给业务方扩展字段,最终在短信回执消息中将此值带回给调用者
		// request.setOutId("yourOutId");

		// hint 此处可能会抛出异常，注意catch
		SendSmsResponse sendSmsResponse = acsClient.getAcsResponse(request);
		smsLogger.info("阿里云短信服务回执详情："+JSONObject.toJSONString(sendSmsResponse));
		if (sendSmsResponse.getCode() != null && "OK".equals(sendSmsResponse.getCode())) {
			smsLogger.info("短信发送成功！");
			//saveSMSToDB(request.getPhoneNumbers(), areaCode, code, request.getSignName()+request.getTemplateCode(), sendSmsResponse.getRequestId());
		} else {
			smsLogger.info("短信发送失败！");
		}
		return sendSmsResponse;
	}

	// 使用天天国际短信平台发送国际短信
	public  String sendSmsToMs360(String telephone, String areaCode, String code) {
		String msgId = null;
		try {
			String ip = smsConfig.getHost();
			int port = smsConfig.getPort();
			// HTTP 请求工具
			HttpClientUtil util = new HttpClientUtil(ip, port, smsConfig.getApi());
			String user = smsConfig.getUsername();// 你的用户名
			String pwd = smsConfig.getPassword();// 你的密码：
			String ServiceID = "SEND"; // 固定，不需要改变
			String dest = telephone; // 你的目的号码【收短信的电话号码】
			String sender = "";// 你的原号码,可空【大部分国家原号码带不过去，只有少数国家支持透传，所有一般为空】
			String templateEnglishSMS = new String(smsConfig.getTemplateEnglishSMS().getBytes("ISO-8859-1"),"utf-8");
			String msg = templateEnglishSMS + code;// 你的短信内容
			if ("86".equals(areaCode) || "886".equals(areaCode) || "852".equals(areaCode)) {
				String templateChineseSMS = new String(smsConfig.getTemplateChineseSMS().getBytes("ISO-8859-1"),"utf-8");
				msg = templateChineseSMS + code;
				
			}
			// codec=8 Unicode 编码, 3 ISO-8859-1, 0 ASCII
			// 短信内容 HEX 编码，8 为 UTF-16BE HEX 编码， dataCoding = 8 ,支持所有国家的语言，建议直接使用
			// 8
			String hex = WebNetEncode.encodeHexStr(8, msg);
			hex = hex.trim() + "&codec=8";
			// HTTP 封包请求, util.sendPostMessage 返回结果，
			// 如果是以 “-” 开头的为发送失败，请查看错误代码，否则为MSGID
			msgId = util.sendGetMessage(user, pwd, ServiceID, dest, sender, hex);
			smsLogger.info("msgid =  " + msgId + "    msg = " + msg);
			// 发送短信记录保存到数据库
			//saveSMSToDB(telephone, areaCode, code, msg, msgId);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return msgId;
	}

	/**
	 * @Description:（短信详情存库）
	 * @param telephone
	 * @param areaCode
	 * @param code
	 * @param content
	 * @param msgId
	 **/
	/*public static void saveSMSToDB(String telephone, String areaCode, String code, String content, String msgId) {
		SmsRecord sms = ConstantUtil.getSmsPrice(areaCode);
		if (null == sms)
			sms = new SmsRecord();
		sms.setAreaCode(areaCode);
		sms.setTelephone(telephone);
		sms.setCode(code);
		sms.setContent(content);
		sms.setMsgId(msgId);
		sms.setTime(DateUtil.currentTimeSeconds());
		ConstantUtil.dsForRW.save(sms);
	}*/
}

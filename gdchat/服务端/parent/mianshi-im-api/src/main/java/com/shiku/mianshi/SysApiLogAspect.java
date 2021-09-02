package com.shiku.mianshi;

import cn.hutool.extra.servlet.ServletUtil;
import com.alibaba.fastjson.JSON;
import com.shiku.commons.thread.pool.AbstractQueueRunnable;
import com.shiku.im.api.service.IdempotenceApiService;
import com.shiku.im.api.utils.FastjsonSerializeConfig;
import com.shiku.im.comm.ex.ServiceException;
import com.shiku.im.comm.utils.ReqUtil;
import com.shiku.im.entity.SysApiLog;
import com.shiku.im.utils.SKBeanUtils;
import com.shiku.im.vo.JSONMessage;
import com.shiku.utils.DateUtil;
import org.apache.catalina.connector.ClientAbortException;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Aspect
@Order(1)
@Component(value = "sysApiLogAspect")
public class SysApiLogAspect extends AbstractQueueRunnable<SysApiLog> {

    private Logger logger = LoggerFactory.getLogger(SysApiLogAspect.class);

    @Autowired
    private IdempotenceApiService idempotenceApiService;


    /**
     *
     */
    public SysApiLogAspect() {
        setBatchSize(50);
        new Thread(this).start();
    }

    @Override
    public void runTask() {
        SysApiLog document = null;
        List<SysApiLog> list = new ArrayList<>();
        try {
            while (!msgQueue.isEmpty()) {
                document = msgQueue.poll();
                if (null == document)
                    continue;
                list.add(document);
                if (loopCount.incrementAndGet() > batchSize)
                    break;
            }
        } catch (Exception e) {
            logger.error(e.toString(), e);
        } finally {
            if (!list.isEmpty())
                SKBeanUtils.getDatastore().insertAll(list);
        }

    }

    @Pointcut("execution(* com.shiku.im.*.controller.*.* (..))")
    public void apiLogAspect() {

    }


    //@Before("apiLogAspect()")
    public void dobefore(JoinPoint joinPoint) {

        RequestAttributes ra = RequestContextHolder.getRequestAttributes();

        ServletRequestAttributes sra = (ServletRequestAttributes) ra;

        HttpServletRequest request = sra.getRequest();

        // 使用log4j的MDC及NDC特性，识别请求方的IP及调用资料，输出到日志中

        MDC.put("uri", request.getRequestURI());


        // 记录下请求内容

        logger.info("HTTP_METHOD : " + request.getMethod());

        logger.info("CLASS_METHOD : " + joinPoint.getSignature().getDeclaringTypeName() + "."

                + joinPoint.getSignature().getName());

        logger.info("ARGS : " + Arrays.toString(joinPoint.getArgs()));


        MDC.get("uri");

        MDC.remove("uri");

    }

    @AfterReturning(returning = "ret", pointcut = "apiLogAspect()")
    public void doAfterReturning(Object ret) throws Throwable {

        // 处理完请求，返回内容

        // logger.info("RESPONSE : " + ret);
    }

    @Around("apiLogAspect()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {

        Object response = null;//定义返回信息
        String stackTrace = null;
        Exception exception = null;
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attributes.getRequest();

        Signature curSignature = joinPoint.getSignature();

        String className = curSignature.getDeclaringTypeName();//类名

        String methodName = curSignature.getName(); //方法名

        // String queryString = request.getQueryString();

        // 获取方法参数
        // String reqParamArr = Arrays.toString(joinPoint.getArgs());


        //记录请求
        //logger.info(String.format("【%s】类的【%s】方法，请求参数：%s", className, methodName, reqParamArr));
        StringBuffer fullUri = new StringBuffer();
        fullUri.append(request.getRequestURI());
        Map<String, String> paramMap = request.getParameterMap().entrySet().stream()
                .collect(Collectors.toMap(Map.Entry::getKey, obj -> obj.getValue()[0]));


        if (!paramMap.isEmpty())
            fullUri.append("?");
        for (String key : paramMap.keySet()) {
            fullUri.append(key).append("=").append(paramMap.get(key)).append("&");
        }
        SysApiLog apiLog = new SysApiLog();
        //时间
        apiLog.setTime(DateUtil.currentTimeSeconds());
        //类名加方法名
        apiLog.setApiId(className + "_" + methodName);
        //请求地址
        apiLog.setClientIp(ServletUtil.getClientIP(request));

        apiLog.setFullUri(fullUri.toString());
        apiLog.setUserAgent(request.getHeader("User-Agent"));
        Integer uid = ReqUtil.getUserId();
        String reqId = UUID.randomUUID().toString();
        logger.info("【请求开始】请求ID:[{}]， uid：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]",
                reqId, uid, apiLog.getFullUri(), apiLog.getClientIp(), apiLog.getUserAgent());
        //用于统计调用耗时
        long startTime = System.currentTimeMillis();
        long totalTime = -1;
        try {
            response = joinPoint.proceed(); // 执行服务方法
            //临时记录3秒返回值数据到redis，用于幂等数据使用
            try {
                idempotenceApiService.addGlobalIdempotenceApiData(uid, request.getRequestURI() + paramMap.get("secret"), JSON.toJSONString(response, FastjsonSerializeConfig.SERIALIZE_CONFIG));
            } catch (Exception e) {
                logger.error("【请求结果存储redis异常】{}", e.getMessage(), e);
            }
            totalTime = System.currentTimeMillis() - startTime;
            Object finalResponse = response;
            long finalTotalTime = totalTime;
            CompletableFuture.runAsync(() -> {
                logger.info("【请求完成】请求ID:[{}]， uid：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]，响应内容：[{}]，响应时长：[{}]",
                        reqId, uid, apiLog.getFullUri(), apiLog.getClientIp(), apiLog.getUserAgent(), JSON.toJSONString(finalResponse), finalTotalTime);
            });
        } catch (Exception e) {
            // TODO: handle exception
            exception = e;
            logger.error("【请求异常】请求ID:[{}]， uid：[{}]，请求参数：[{}]，客户端ip：[{}]，User-Agent：[{}]，响应时长：[{}]",
                    reqId, uid, apiLog.getFullUri(), apiLog.getClientIp(), apiLog.getUserAgent(), totalTime, e);
        }
        logger.info("********************************************");
        apiLog.setTotalTime(totalTime);
        //记录应答
        //logger.info(String.format("【%s】类的【%s】方法，应答参数：%s", className, methodName, response));
        //logger.info("RESPONSE : " + response);
        /**
         * 代码异常了
         */
        int isSaveRequestLogs = SKBeanUtils.getSystemConfig().getIsSaveRequestLogs();
        if (null != exception) {
            stackTrace = ExceptionUtils.getStackTrace(exception);
            apiLog.setStackTrace(stackTrace);
            return handleErrors(exception);
        }

        if (1 == isSaveRequestLogs)
            saveSysApiLogToDB(apiLog);


        return response;

    }

    private void saveSysApiLogToDB(SysApiLog apiLog) {
        apiLog.setUserId(ReqUtil.getUserId());
        synchronized (msgQueue) {
            msgQueue.offer(apiLog);
            msgQueue.notifyAll();
        }

    }

    private Object handleErrors(Exception e) {
        int resultCode = 1020101;
        String resultMsg = "接口内部异常";
        String detailMsg = "";
        if (e instanceof MissingServletRequestParameterException
                || e instanceof BindException) {
            resultCode = 1010101;
            resultMsg = "请求参数验证失败，缺少必填参数或参数错误";
        } else if (e instanceof ServiceException) {
            ServiceException ex = ((ServiceException) e);

            resultCode = 0 == ex.getResultCode() ? 0 : ex.getResultCode();
            if (0 == resultCode && null != ex.getMessage()) {
                return JSONMessage.failure(ex.getMessage());
            }

        } else if (e instanceof ClientAbortException) {
            resultMsg = "====> ClientAbortException";
            resultCode = -1;
        } else {
            detailMsg = e.getMessage();
        }
        //logger.error(resultMsg+" ↓ \n"+e.getMessage());

			/*Map<String, Object> map = Maps.newHashMap();
			map.put("resultCode", resultCode);
			map.put("resultMsg", resultMsg);
			map.put("detailMsg", detailMsg);*/

        return JSONMessage.failureByErrCode(resultCode);
    }


}

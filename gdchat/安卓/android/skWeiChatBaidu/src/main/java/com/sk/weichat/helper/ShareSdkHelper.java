package com.sk.weichat.helper;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.Toast;

import com.sk.weichat.R;
import com.sk.weichat.ui.me.redpacket.UtilWeixin;
import com.sk.weichat.util.AppUtils;
import com.sk.weichat.util.Constants;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;


public class ShareSdkHelper {

    private ShareSdkHelper() {
    }

    public static void shareWechat(
            Context ctx,
            String title,
            String text,
            String url) {
        platformShare(ctx, SendMessageToWX.Req.WXSceneSession, title, text, url);
    }

    public static void shareWechatMoments(
            Context ctx,
            String title,
            String text,
            String url) {
        platformShare(ctx, SendMessageToWX.Req.WXSceneTimeline, title, text, url);
    }

    private static IWXAPI getApi(Context ctx) {
        IWXAPI api = WXAPIFactory.createWXAPI(ctx, Constants.VX_APP_ID, true);
        api.registerApp(Constants.VX_APP_ID);
        return api;
    }

    private static void platformShare(
            Context ctx,
            int scene,
            String title,
            String text,
            String url
    ) {
        if (!AppUtils.isAppInstalled(ctx, "com.tencent.mm")) {
            Toast.makeText(ctx, ctx.getString(R.string.tip_no_wx_chat), Toast.LENGTH_SHORT).show();
            return;
        }
        WXWebpageObject webpage = new WXWebpageObject();
        webpage.webpageUrl = url;
        final WXMediaMessage msg = new WXMediaMessage(webpage);
        msg.title = title;
        msg.description = text;
        Bitmap thumb = BitmapFactory.decodeResource(ctx.getResources(), R.mipmap.icon);
        if (thumb != null) {
            Bitmap logo = Bitmap.createScaledBitmap(thumb, 120, 120, true);
            thumb.recycle();
            msg.thumbData = UtilWeixin.bmpToByteArray(logo, true);
        }
        SendMessageToWX.Req req = new SendMessageToWX.Req();    //创建一个请求对象
        req.message = msg;
        req.scene = scene;
        getApi(ctx).sendReq(req);   //如果调用成功微信,会返回true
    }
}

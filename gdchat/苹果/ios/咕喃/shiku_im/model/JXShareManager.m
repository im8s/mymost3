//
//  JXShareManager.m
//  shiku_im
//
//  Created by MacZ on 16/8/19.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXShareManager.h"
#import "JXMyTools.h"
//#import "WeiboSDK.h"
#import <Social/Social.h>

@implementation JXShareManager

static JXShareManager *shared;

+ (JXShareManager *)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[JXShareManager alloc] init];
    });
    return shared;
}

- (void)shareSuccess{
    if ([self.delegate respondsToSelector:@selector(didShareSuccess)]) {
        [self.delegate didShareSuccess];
    }
    
    [JXMyTools showTipView:Localized(@"ShareSuccess")];
    NSLog(@"分享成功");
}

- (void)shareWith:(JXShareModel *)shareModel delegate:(id)delegate{
    self.delegate = delegate;
    
    switch (shareModel.shareTo) {
//        case JXShareToSina:     //微博
//        {
//            
//            if (![WeiboSDK isWeiboAppInstalled]) {
//                [g_App showAlert:Localized(@"SinaWBNotInstalled")];
//                return;
//            }
//            
//            //            [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeWeb url:_webUrlString];
//            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina] content:[NSString stringWithFormat:@"%@ %@",shareModel.shareTitle,shareModel.shareUrl] image:nil location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
//                if (response.responseCode == UMSResponseCodeSuccess) {
//                    [self shareSuccess];
//                }
//            }];
//        }
//            break;
        case JXShareToWechatSesion:     //微信
        {

            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareModel.shareUrl;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = shareModel.shareTitle;
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession] content:shareModel.shareContent image:shareModel.shareImage location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [self shareSuccess];
                }
            }];
        }
            break;
        case JXShareToWechatTimeline:     //朋友圈
        {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareModel.shareUrl;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareModel.shareTitle;
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatTimeline] content:shareModel.shareContent image:shareModel.shareImage location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [self shareSuccess];
                }
            }];
        }
            break;
//        case JXShareToFaceBook:     //FaceBook
//        {
            //                [[UMSocialControllerService defaultControllerService] setShareText:[NSString stringWithFormat:@"%@ %@",_shareTitle,_webUrlString] shareImage:nil socialUIDelegate:self];
            //                UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToFacebook];
            //                snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            //facebook友盟SDK底层分享接口
            //                [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToFacebook] content:[NSString stringWithFormat:@"%@",_shareTitle] image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
            //                    if (response.responseCode == UMSResponseCodeSuccess) {
            //                        [self updateShareActivi];
            //                        NSLog(@"分享成功");
            //                    }
            //                }];
            
            //                self.view.alpha = 0;
            
            
            //facebook官方SDK分享
//            if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//                [g_App showAlert:Localized(@"Facebook NO")];
//                return;
//            }
//            
//            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//            
//            
//            //链接
//            content.contentURL = [NSURL URLWithString:shareModel.shareUrl];
//            
//            //标题
//            content.contentTitle = shareModel.shareTitle;
//            //内容
//            content.contentDescription = shareModel.shareContent;
//            //图片
//            content.imageURL = [NSURL URLWithString:shareModel.shareImageUrl];
//            //contentURL和imageURL效果不并存，若同时有值，则分享的图片和链接是contentURL
//            
//            
//            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//            dialog.shareContent = content;
//            dialog.mode = FBSDKShareDialogModeNative;
//            dialog.fromViewController = self.delegate;
//            
//            if ([dialog canShow]) {
//                [dialog show];
//            }
//        }
//            break;
//        case JXShareToTwitter:
//        {
//            //Twitter(直接分享打开对应的应用，因友盟不支持打开twitter和FaceBook，故此处用非直接分享，使用友盟自定义分享界面样式)
////            [[UMSocialControllerService defaultControllerService] setShareText:[NSString stringWithFormat:@"%@\r\n%@",shareModel.shareContent,shareModel.shareUrl] shareImage:shareModel.shareImage socialUIDelegate:self];
////            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTwitter];
////            snsPlatform.snsClickHandler(self.delegate,[UMSocialControllerService defaultControllerService],YES);
//            //iOS 自带分享
//            SLComposeViewController *shareVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//            //判断是否安装推特
//            if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
//                [g_App showAlert:Localized(@"TW NO")];
//                return;
//            }
//            
//            [shareVC setInitialText:shareModel.shareContent];
//            [shareVC addImage:shareModel.shareImage];
//            [shareVC addURL:[NSURL URLWithString:shareModel.shareUrl]];
//            __block SLComposeViewController *slcVCBlock = shareVC;
//            shareVC.completionHandler = ^(SLComposeViewControllerResult result){
//                if (result == SLComposeViewControllerResultDone) {
//                    [self shareSuccess];
//                }
//                [slcVCBlock dismissViewControllerAnimated:YES completion:nil];
//            };
//            
//            [self.delegate presentViewController:shareVC animated:YES completion:nil];
//        }
//            break;
//        case JXShareToWhatsapp://WhatsApp(只能分享纯文字或纯图片信息)；此分享无法触发回调，安卓亦如此。？
//        {
//            
//            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWhatsapp] content:[NSString stringWithFormat:@"【%@】%@\r\n%@",Localized(@"PinBa"),shareModel.shareTitle,shareModel.shareUrl] image:nil location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
//                if (response.responseCode == UMSResponseCodeSuccess) {
//                    [self shareSuccess];
//                }
//            }];
//            
//        }
//            break;
//        case JXShareToSMS://SMS
//        {
//            NSString *smsContent = [NSString stringWithFormat:@"%@%@",shareModel.shareTitle,shareModel.shareUrl];
//            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSms] content:smsContent image:nil location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
//                if (response.responseCode == UMSResponseCodeSuccess) {
//                    [self shareSuccess];
//                }
//            }];
//        }
//            break;
//            
//        case JXShareToLine://Line
//        {
//            NSString *smsContent = [NSString stringWithFormat:@"%@%@",shareModel.shareTitle,shareModel.shareUrl];
//            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToLine] content:smsContent image:nil location:nil urlResource:nil presentedController:self.delegate completion:^(UMSocialResponseEntity *response) {
//                if (response.responseCode == UMSResponseCodeSuccess) {
//                    [self shareSuccess];
//                }
//            }];
//        }
//            break;
            
        default:
            break;
    }
}

//友盟非直接分享回调
#pragma mark UMSocialUIDelegate
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    if (response.responseCode == UMSResponseCodeSuccess) {
        [self shareSuccess];
    }
}

//FaceBook官方SDK分享回调
#pragma mark FBSDKSharingDelegate
//- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0) {    //iOS8分享成功results为空；iOS9网页分享成功results不为空,点完成（不分享）results为空
//        if (results.count <= 0) {
//            return;
//        }
//    }
//    
//    [self shareSuccess];
//}

//- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
//    NSLog(@"FB Share error:%@",error);
//}
//
//- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
//    NSLog(@"FB Share cancel");
//}

@end

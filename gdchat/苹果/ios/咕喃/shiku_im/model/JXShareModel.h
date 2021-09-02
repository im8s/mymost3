//
//  JXShareModel.h
//  shiku_im
//
//  Created by MacZ on 16/8/22.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JXShareToWechatSesion,
    JXShareToWechatTimeline,
    JXShareToSina,
    JXShareToFaceBook,
    JXShareToTwitter,
    JXShareToWhatsapp,
    JXShareToSMS,
    JXShareToLine,
} JXShareTo;

@interface JXShareModel : NSObject

@property (nonatomic,assign) JXShareTo shareTo;
@property (nonatomic,copy) NSString *shareTitle;
@property (nonatomic,copy) NSString *shareContent;
@property (nonatomic,copy) NSString *shareUrl;
@property (nonatomic,strong) UIImage *shareImage;
@property (nonatomic,copy) NSString *shareImageUrl;

@end

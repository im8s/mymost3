//
//  JXHelperModel.h
//  shiku_im
//
//  Created by 1 on 2019/5/28.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXHelperModel : NSObject

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *developer;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *helperId;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *openAppId;
@property (nonatomic, strong) NSString *urlScheme;
@property (nonatomic, assign) int type;


// other
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *appIcon;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *title;

- (void)getDataWithDict:(NSDictionary *)dict;

+ (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

//
//  JXShareFileObject.h
//  shiku_im
//
//  Created by 1 on 17/7/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXShareFileObject : NSObject

@property (nonatomic,copy) NSString * createUserName;
@property (nonatomic,copy) NSString * roomId;
@property (nonatomic,copy) NSString * shareId;
@property (nonatomic,copy) NSNumber * size;
@property (nonatomic,copy) NSNumber * time;
@property (nonatomic,copy) NSNumber * type;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSString * userId;
@property (nonatomic,copy) NSString * fileName;

+(JXShareFileObject *)shareFileWithDict:(NSDictionary *)dict;

@end

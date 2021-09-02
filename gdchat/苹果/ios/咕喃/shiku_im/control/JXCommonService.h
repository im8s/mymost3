//
//  JXCommonService.h
//  shiku_im
//
//  Created by p on 2017/11/9.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXCommonService : NSObject

@property (nonatomic, strong) NSTimer *courseTimer;

- (void)sendCourse:(JXMsgAndUserObject *)obj Array:(NSArray *)array;

@end

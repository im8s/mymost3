//
//  JXBadgeView.h
//  shiku_im
//
//  Created by flyeagleTang on 15-1-10.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXBadgeView : JXImageView
{
    CGSize _baseSize;
}
    
@property (nonatomic, strong) UILabel *lb;
@property (nonatomic, strong) NSString *badgeString;
@property (nonatomic, assign) int fontsize;
@property (nonatomic, assign) BOOL isSmall;

@end

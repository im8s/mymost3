//
//  JXCustomButton.m
//  lveliao_IM
//
//  Created by 1 on 17/8/15.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXCustomButton.h"

@implementation JXCustomButton


-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [super titleRectForContentRect:contentRect];
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [super imageRectForContentRect:contentRect];
}


@end

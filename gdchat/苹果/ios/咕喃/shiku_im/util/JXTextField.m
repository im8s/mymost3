//
//  JXTextField.m
//  shiku_im
//
//  Created by 1 on 2018/12/5.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTextField.h"

@implementation JXTextField

// 禁用菜单
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action == @selector(paste:))//禁止粘贴
        return NO;
    if(action == @selector(select:))// 禁止选择
        return NO;
    if(action == @selector(selectAll:))// 禁止全选
        return NO;
    return[super canPerformAction:action withSender:sender];
}
@end

//
//  JXAutoSizeImageView.h
//  lveliao_IM
//
//  Created by MacZ on 2017/8/9.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXAutoSizeImageView : UIView{
    NSMutableArray* _users;
    NSMutableArray* _images;
}
-(id)initWithFrame:(CGRect)frame;

-(void)add:(NSString*)userId;//加一个人
-(void)delete:(NSString*)userId;//减一个人
-(void)clear;//清除所有
-(void)show;//刷新显示
-(BOOL)isMember:(NSString*)userId;//是否成员

@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, strong) NSMutableArray* users;
@end

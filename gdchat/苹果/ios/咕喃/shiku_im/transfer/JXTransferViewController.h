//
//  JXTransferViewController.h
//  shiku_im
//
//  Created by 1 on 2019/3/1.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "admobViewController.h"

@protocol transferVCDelegate <NSObject>

-(void)transferToUser:(NSDictionary *)redpacketDict;

@end

@interface JXTransferViewController : admobViewController

@property (nonatomic, strong) JXUserObject *user;

@property (weak, nonatomic) id <transferVCDelegate> delegate;


@end


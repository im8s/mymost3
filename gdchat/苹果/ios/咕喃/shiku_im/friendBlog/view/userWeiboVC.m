//
//  userWeiboVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-7-10.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "userWeiboVC.h"


@interface userWeiboVC ()

@end

@implementation userWeiboVC

- (id)init
{
    self.isNotShowRemind = YES;
    self = [super init];
    if (self) {
//        if ([self.user.userId isEqualToString:MY_USER_ID]) {
//            self.title = Localized(@"WeiboViewControlle_MyFriend");
//        }else {
            self.title = self.user.userNickname;
//        }
    }
    return self;
}

- (void)dealloc {
//    [super dealloc];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getServerData{
    [self stopLoading];
    [g_App.jxServer getUserMessage:self.user.userId messageId:[self getLastMessageId:self.datas] toView:self];
}


@end

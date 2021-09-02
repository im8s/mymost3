//
//  JXChatLogMoveActionVC.m
//  shiku_im
//
//  Created by p on 2019/6/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXChatLogMoveActionVC.h"

@interface JXChatLogMoveActionVC ()

@end

@implementation JXChatLogMoveActionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isGotoBack = YES;
    self.title = Localized(@"JX_ChatLogMove");
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    [self createHeadAndFoot];
    
    [_wait start:Localized(@"JX_Migrating")];
}

- (void)moveActionFinish {
    
    [self actionQuit];
    
    [JXMyTools showTipView:Localized(@"JX_ChatLogReceivingCompleted")];
}

- (void)actionQuit {
 
    [_wait stop];
    
    [super actionQuit];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

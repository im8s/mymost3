//
//  JXOpenRedPacketVC.h
//  shiku_im
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXPacketObject.h"
#import "JXGetPacketList.h"
@interface JXOpenRedPacketVC : admobViewController{
//    ATMHud * _wait;
    JXOpenRedPacketVC *_pSelf;
}
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *fromUserLabel;
@property (strong, nonatomic) IBOutlet UILabel *greetLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UIView *centerRedPView;

@property (strong, nonatomic) NSDictionary * dataDict;
@property (strong, nonatomic) JXPacketObject * packetObj;
@property (strong, nonatomic) NSArray * packetListArray;
@property (strong, nonatomic) IBOutlet UIView *blackBgView;

- (void)doRemove;
@end

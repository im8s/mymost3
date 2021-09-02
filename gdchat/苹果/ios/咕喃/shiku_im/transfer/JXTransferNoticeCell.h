//
//  JXTransferNoticeCell.h
//  shiku_im
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXTransferNoticeModel;

@interface JXTransferNoticeCell : UITableViewCell


- (void)setDataWithMsg:(JXMessageObject *)msg model:(id)tModel;


+ (float)getChatCellHeight:(JXMessageObject *)msg;

@end

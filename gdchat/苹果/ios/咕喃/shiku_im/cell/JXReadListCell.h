//
//  JXReadListCell.h
//  shiku_im
//
//  Created by p on 2017/9/2.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXReadListCell : UITableViewCell

@property (nonatomic, assign) int index;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, strong) roomData *room;

- (void) setData:(JXUserObject *)obj;

@end

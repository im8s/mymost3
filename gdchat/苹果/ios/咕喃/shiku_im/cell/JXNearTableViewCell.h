//
//  JXNearTableViewCell.h
//  lveliao_IM
//
//  Created by liangjian on 2020/3/10.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXNearTableViewCell : UITableViewCell
@property(nonatomic,assign) int fnId;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didTouch;

- (void)doRefreshNearExpert:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END

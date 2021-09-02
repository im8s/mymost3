//
//  JXExpertCell.h
//  shiku_im
//
//  Created by MacZ on 2016/10/20.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXNearCell : UICollectionViewCell

@property(nonatomic,assign) int fnId;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didTouch;

- (void)doRefreshNearExpert:(NSDictionary *)dict;

@end

//
//  WhoCanSeeViewController.h
//  shiku_im
//
//  Created by 1 on 17/11/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

@protocol VisibelDelegate <NSObject>

-(void)seeVisibel:(int)visibel userArray:(NSArray *)userArray selLabelsArray:(NSMutableArray *)selLabelsArray mailListArray:(NSMutableArray *)mailListArray;

@end

@interface WhoCanSeeViewController : admobViewController

@property (nonatomic,weak) id<VisibelDelegate> visibelDelegate;
@property (nonatomic,assign) int type;
@property (nonatomic, strong) NSMutableArray *selLabelsArray;
@property (nonatomic, strong) NSMutableArray *mailListUserArray;

@property (nonatomic, assign) BOOL isAddWindow;

@end

//
//  JXGoogleMapVC.h
//  shiku_im
//
//  Created by 1 on 2018/8/20.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"


typedef NS_OPTIONS(NSUInteger, JXGooLocationType){
    JXGooLocationTypeCurrentLocation     = 0,
    JXGooLocationTypeShowStaticLocation  = 2,
};

@interface JXGoogleMapVC : admobViewController{
    NSInteger _selIndex;
    NSMutableArray *_nearMarkArray; //周边检索数据源
    UITableView * _nearMarkTableView;
}
@property (nonatomic,retain)  UIButton * sendButton;
@property (nonatomic,assign) JXGooLocationType locationType;

@property (nonatomic,assign) double longitude; //右边
@property (nonatomic,assign) double latitude; //左边
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL        didSelect;
@property (nonatomic,copy) NSString * address;
@property (nonatomic,retain)  NSMutableArray *locations;
@property (nonatomic, copy) NSString *placeNames;

@property (assign, nonatomic) BOOL isSend;


@end

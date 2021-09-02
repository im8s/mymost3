//
//  JXLocMapVC.h
//  shiku_im
//
//  Created by Apple on 16/10/19.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXLocPerImageVC;
@interface JXLocMapVC : UIViewController<UIScrollViewDelegate>{
    ATMHud * _wait;
}
@property (nonatomic,assign) double locX;
@property (nonatomic,assign) double locY;
@property (nonatomic,strong) NSMutableArray * nearbyData;//数据源
@property (nonatomic,strong) UIButton * resetLoca;
@property (nonatomic,assign) int dataType;//依据VC获取不同的数据
@property (nonatomic,assign) int currentDataType;//依据VC获取不同的数据
@property (nonatomic,strong) NSMutableArray * allAnnotationView;
@property (nonatomic,strong) UIScrollView * resumeScrolView;
@property (nonatomic,strong) UIScrollView * topScrolView;
@property (nonatomic,strong) UIView * topMinView;
@property (nonatomic,strong) UIView * scrollBackground;
@property (nonatomic,assign) int fnId;
@property (nonatomic,assign) int cityId;
@property (nonatomic,assign) int currentIndex;//当前显示ScrollView的index，点击后展示
@property (nonatomic,assign) CGPoint lastContentSet;//旧的位置，用于判断ScrollView左划还是右划
@property (nonatomic,assign) int direction;//ScrollView左划还是右划
@property (nonatomic,strong) JXLocPerImageVC * lastAnnotationView;//上次被选择的大头针
@property (nonatomic,strong) UIButton * lastButton;//上次被选择的按钮
@property (nonatomic,strong) UIView * scaleView;//放大缩小按钮父视图
//@property (nonatomic,strong) UIButton * enlargeButton;//放大按钮
//@property (nonatomic,strong) UIButton * narrowButton;//缩小按钮
//ScrollView里的控件
@property (nonatomic,strong) UIView * jobDetailOne;
@property (nonatomic,strong) UIView * jobDetailTwo;
@property (nonatomic,strong) UIView * jobDetailThree;
//标题
@property (nonatomic,strong) UILabel * titleLabelOne;
@property (nonatomic,strong) UILabel * titleLabelTwo;
@property (nonatomic,strong) UILabel * titleLabelThree;
//付费方式
@property (nonatomic,strong) UILabel * payLabelOne;
@property (nonatomic,strong) UILabel * payLabelTwo;
@property (nonatomic,strong) UILabel * payLabelThree;
//详情
@property (nonatomic,strong) UILabel * detailLabelOne;
@property (nonatomic,strong) UILabel * detailLabelTwo;
@property (nonatomic,strong) UILabel * detailLabelThree;
//头像
@property (nonatomic,strong) UIImageView * headImageOne;
@property (nonatomic,strong) UIImageView * headImageTwo;
@property (nonatomic,strong) UIImageView * headImageThree;
//昵称
@property (nonatomic,strong) UILabel * nameLabelOne;
@property (nonatomic,strong) UILabel * nameLabelTwo;
@property (nonatomic,strong) UILabel * nameLabelThree;
//认证
@property (nonatomic,strong) UIImageView * identImageOne;
@property (nonatomic,strong) UIImageView * identImageTwo;
@property (nonatomic,strong) UIImageView * identImageThree;
//信誉积分背景
@property (nonatomic,strong) UIImageView * integralImageOne;
@property (nonatomic,strong) UIImageView * integralImageTwo;
@property (nonatomic,strong) UIImageView * integralImageThree;
//信誉积分
@property (nonatomic,strong) UILabel * integralLabelOne;
@property (nonatomic,strong) UILabel * integralLabelTwo;
@property (nonatomic,strong) UILabel * integralLabelThree;
//距离
@property (nonatomic,strong) UILabel * distanceLabelOne;
@property (nonatomic,strong) UILabel * distanceLabelTwo;
@property (nonatomic,strong) UILabel * distanceLabelThree;

@property (nonatomic, strong) searchData *search;


- (instancetype)initWithFrame:(CGRect)frame andType:(int)dataType;
-(void)getDataByCurrentLocation;

@end

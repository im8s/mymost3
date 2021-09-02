//
//  JXLocPerImageVC.h
//  shiku_im
//
//  Created by Apple on 16/10/23.
//  Copyright © 2016年 Reese. All rights reserved.
//

//#import <BaiduMapAPI_Map/BaiduMapAPI_Map.h>
//#import <BaiduMapAPI_Map/BMKMapComponent.h>//只引入所需的单个头文件
//#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
@interface JXLocPerImageVC : BMKAnnotationView

@property (nonatomic,strong) JXImageView * headImage;
@property (nonatomic,strong) UIImageView * pointImage;
@property (nonatomic,strong) UIView * headView;
-(void)setData:(NSDictionary*)data andType:(int)dataType;
-(void)selectAnimation;
-(void)cancelSelectAnimation;
@end

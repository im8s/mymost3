//
//  PSMyViewController
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "admobViewController.h"
//添加VC转场动画
#import "DMScaleTransition.h"
#import "JXImageScrollVC.h"
#import "JXActionSheetVC.h"
#import "JX_SelectMenuView.h"
#import "addMsgVC.h"
#import "JXBlogRemindVC.h"

@protocol JXServerResult;

@interface PSMyViewController : admobViewController<JXServerResult,UIImagePickerControllerDelegate,UINavigationControllerDelegate,JXActionSheetVCDelegate,JXSelectMenuViewDelegate>{
    
//    int h1;
    UIImage* _image;
    UILabel* _userName;
    UILabel* _userDesc;
    UILabel* _friendLabel;
    UILabel* _groupLabel;
    BOOL _isSelected;
    JXImageView *_topImageVeiw;
    UIView *_setBaseView;
}
@property (nonatomic, strong) DMScaleTransition *scaleTransition;
@property (nonatomic,assign) BOOL isRefresh;
@property (nonatomic,strong) UILabel * moneyLabel;
@property (nonatomic, assign) int isAudioMeeting;
@property (nonatomic, strong) JXImageView *head;
@property (nonatomic, assign) BOOL isGetUser;

//-(void)doLogout;
//-(void)doRefresh;
-(void)refreshUserDetail;
@end

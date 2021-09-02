//
//  userInfoVC.m
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "userInfoVC.h"
#import "JXImageView.h"
#import "JXLabel.h"
#import "AppDelegate.h"
#import "JXServer.h"
#import "JXConnection.h"
#import "UIFactory.h"
#import "JXTableView.h"
#import "JXFriendViewController.h"
#import "ImageResize.h"
#import "userWeiboVC.h"
#import "LXActionSheet.h"
#import "webpageVC.h"


@implementation userInfoVC
@synthesize user,userId;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"UserInfoVC_UserInfo");
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.isGotoBack = YES;
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = HEXCOLOR(0xf0eff4);
     
        if(self.user)
            [self show];
        else
            [g_server getUser:userId toView:self];
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"userInfoVC.dealloc");
//    [_image release];
    self.user = nil;
    self.userId = nil;
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if( [aDownload.action isEqualToString:act_UploadHeadImage] ){
        _head.image = _image;
//        [_image release];
        _image = nil;
    }
    if( [aDownload.action isEqualToString:act_UserGet] ){
        user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        [self show];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


-(void)showOneLine:(NSString*)title value:(NSString*)value y:(int)y height:(int)height{
    UIView* v = [[UIView alloc]init];
    v.frame = CGRectMake(0, y, JX_SCREEN_WIDTH, height);
    v.backgroundColor = [UIColor whiteColor];
    [self.tableBody addSubview:v];
//    [v release];

    UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 78, height)];
    name.font = g_factory.font13b;
    name.text = title;
    name.textColor = HEXCOLOR(0xa7a7a7);
    name.backgroundColor = [UIColor clearColor];
    [v addSubview:name];
//    [name release];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 200, height)];
    p.font = g_factory.font13;
    p.text = value;
    p.textColor = [UIColor blackColor];
    p.backgroundColor = [UIColor clearColor];
    p.numberOfLines = 0;
    [v addSubview:p];
//    [p release];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,height-0.5,JX_SCREEN_WIDTH,0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [v addSubview:line];
//    [line release];
}
#pragma mark -----------------对用户进行操作------------------
-(void)onMore{
    
    if(g_myself.userId == self.userId){
        LXActionSheet* _menu = [[LXActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:Localized(@"JX_Cencal")
                                destructiveButtonTitle:Localized(@"JXUserInfoVC_SetName")
                                otherButtonTitles:@[Localized(@"UserInfoVC_SendToFirend"),Localized(@"UserInfoVC_Complaint")]];
        [g_window addSubview:_menu];
//        [_menu release];
    }else{
        LXActionSheet* _menu = [[LXActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:Localized(@"JX_Cencal")
                                destructiveButtonTitle:Localized(@"JXUserInfoVC_SetName")
                                otherButtonTitles:@[Localized(@"UserInfoVC_SendToFirend"),Localized(@"UserInfoVC_Complaint")]];
        [g_window addSubview:_menu];
//        [_menu release];
    }
    
    
}

- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
    if(buttonIndex<0)
        return;
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                break;
                
            default:
                break;
        }
}

-(void)onHeadImage{
    userWeiboVC* vc = [userWeiboVC alloc];
    vc.user = user;
    [vc init];
    [g_window addSubview:vc.view];
}

-(void)show{
    UIButton* btn;
    int h=0;int h1=35;
//    int w=JX_SCREEN_WIDTH-9*2;
    
    btn = [UIFactory createButtonWithImage:@"title_more@2x" highlight:nil target:self selector:@selector(onMore)];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-24-8, 20+10, 24, 24);
    [self.tableHeader addSubview:btn];
    
    UIView* v = [[UIView alloc]init];
    v.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, 90);
    [self.tableBody addSubview:v];
//    [v release];
    
    h+=v.frame.size.height;
    
    _head = [[JXImageView alloc]initWithFrame:CGRectMake(9, 10, 70, 70)];
    _head.layer.cornerRadius = 6;
    _head.layer.masksToBounds = YES;
    _head.didTouch = @selector(onHeadImage);
    _head.delegate = self;
    [v addSubview:_head];
//    [_head release];
    [g_server getHeadImageSmall:user.userId imageView:_head];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(_head.frame.size.width+20, 10, 200, 20)];
    p.font = g_factory.font16;
    p.text = user.userNickname;
    p.backgroundColor = [UIColor clearColor];
    [v addSubview:p];
//    [p release];
    
    JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(75+15,60,20,20)];
    iv.image = [UIImage imageNamed:@"icon_fans@2x.png"];
    iv.userInteractionEnabled = YES;
    [v addSubview:iv];
//    [iv release];
    
    p = [[JXLabel alloc]initWithFrame:CGRectMake(95+15, 60, 180-97, 20)];
    p.textColor    = HEXCOLOR(0x36d55c);
    p.backgroundColor = [UIColor clearColor];
    p.font = g_factory.font12;
    p.text = [NSString stringWithFormat:@"%d%@",[user.fansCount intValue],Localized(@"UserInfoVC_Fans")];
    [v addSubview:p];
//    [p release];
    
    iv = [[JXImageView alloc]initWithFrame:CGRectMake(75+15,35,20,20)];
    iv.userInteractionEnabled = YES;
    iv.image = [UIImage imageNamed:@"avatar_icon_boy@2x.png"];
    [v addSubview:iv];
//    [iv release];
    
    p = [[JXLabel alloc]initWithFrame:CGRectMake(95+15, 35, 160, 20)];
    p.textColor    = HEXCOLOR(0xa7a7a7);
    p.backgroundColor = [UIColor clearColor];
    p.font = g_factory.font12;
    p.text = [NSString stringWithFormat:@"%d%@",[user.level intValue],Localized(@"UserInfoVC_Lever")];
    [v addSubview:p];
//    [p release];
    
    [self showOneLine:Localized(@"UserInfoVC_BirthDay") value:[TimeUtil formatDate:user.birthday format:@"yyyy-MM"] y:h height:h1];
    h+=h1;
    [self showOneLine:Localized(@"UserInfoVC_Loation") value:user.location y:h height:h1];
    h+=h1;
    [self showOneLine:Localized(@"UserInfoVC_CompanyName") value:user.companyName y:h height:h1];
    h+=h1;
    [self showOneLine:Localized(@"UserInfoVC_Job") value:@"" y:h height:h1];
    h+=h1;
    [self showOneLine:Localized(@"UserInfoVC_PerSign") value:user.userDescription y:h height:60];
    h+=60;
    
    UIButton* _btn;
    _btn = [UIFactory createCommonButton:Localized(@"JX_Attion") target:self action:@selector(onSearch)];
    _btn.frame = CGRectMake(10, h, 300, 44);
    [self.tableBody addSubview:_btn];

    self.tableBody.contentSize = CGSizeMake(self_width, h);
    if(h>JX_SCREEN_HEIGHT-JX_SCREEN_TOP)
        self.tableBody.scrollEnabled = YES;
}

@end

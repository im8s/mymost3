//
//  JXSelectImageView.m
//
//  Created by Reese on 13-8-22.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXSelectImageView.h"

#define SELECTIMAGE_WIDTH 53 // 图片宽度
//动态间距
#define DWIDTH (JX_SCREEN_WIDTH - 200)/5.0
//动态间距
#define DHEIGHT (218 - 110)/3.0


@implementation JXSelectImageView 
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:HEXCOLOR(0xF9F9F9)];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        
        self.helperScrollV = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.helperScrollV.delegate = self;
        self.helperScrollV.showsVerticalScrollIndicator = NO;
        self.helperScrollV.showsHorizontalScrollIndicator = NO;
        self.helperScrollV.hidden = YES;
        [self addSubview:self.helperScrollV];

        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH * 2,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [self.scrollView addSubview:line];

        // 创建功能栏
        int h = SELECTIMAGE_WIDTH+15+9;
        
        int inset = (JX_SCREEN_WIDTH-SELECTIMAGE_WIDTH*4)/5;
        int margeY = (frame.size.height - (THE_DEVICE_HAVE_HEAD ? 75 : 40) - (h * 2)) / 2;
        
        int n = 0;
        int m = 1;
        int X = inset;
        int Y = margeY;
        
        UIView *button;
        // 照片
        button = [self createButtonWithImage:@"im_photo_button_normal" highlight:@"im_photo_button_press" target:delegate selector:self.onImage title:Localized(@"JX_Photo")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        
        // 拍摄
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
        Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
        button = [self createButtonWithImage:@"im_pickup_button_normal" highlight:@"im_pickup_button_press" target:delegate selector:self.onCamera title:Localized(@"JX_PhotoAndVideo")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        
        // 收藏
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
        Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
        button = [self createButtonWithImage:@"im_collection_button_normal" highlight:@"im_collection_button_press" target:delegate selector:self.onCollection title:Localized(@"JX_Collection")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        
        // 位置
        if ([g_config.isOpenPositionService intValue] == 0) {
            n = (n + 1) >= 4 ? 0 : n + 1;
            m += 1;
            X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
            Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
            button = [self createButtonWithImage:@"im_map_button_normal" highlight:@"im_map_button_press" target:delegate selector:self.onLocation title:Localized(@"JX_Location")];
            button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        }
//        enablePayModule
        if ([g_config.enablePayModule boolValue] && !self.isGroupMessages && !self.isDevice) {
            if ([g_App.isShowRedPacket boolValue]) {
                // 发红包
                n = (n + 1) >= 4 ? 0 : n + 1;
                m += 1;
                X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
                Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
                button = [self createButtonWithImage:@"im_awarda_a_bonus_normal" highlight:@"im_awarda_a_bonus_press" target:delegate selector:self.onGift title:Localized(@"JX_SendGift")];
                button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
            }
            
            if (!self.isGroup) {
                // 转账
                n = (n + 1) >= 4 ? 0 : n + 1;
                m += 1;
                X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
                Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
                button = [self createButtonWithImage:@"im_tool_transfer_button_normal" highlight:@"im_tool_transfer_button_press" target:delegate selector:self.onTransfer title:Localized(@"JX_Transfer")];
                button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
            }
        }
        
//#if TAR_IM
//#ifdef Meeting_Version
        if (!self.isGroupMessages && !self.isDevice) {
            // 语音通话 or 视频会议
            n = (n + 1) >= 4 ? 0 : n + 1;
            m += 1;
            X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
            Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
            
            NSString *str;
            if (_isGroup) {
                str = Localized(@"JXSettingVC_VideoMeeting");
            }else {
                str = Localized(@"JX_VideoChat");
            }
            button = [self createButtonWithImage:@"im_audio_button_normal" highlight:@"im_audio_button_press" target:delegate selector:self.onAudioChat title:str];
            button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        }
        
//#endif
//#endif
        // 名片
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
        Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
        button = [self createButtonWithImage:@"im_card_button_normal" highlight:@"im_card_button_press" target:delegate selector:self.onCard title:Localized(@"JX_Card")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        if (!self.isGroup) {
            // 戳一戳
            n = (n + 1) >= 4 ? 0 : n + 1;
            m += 1;
            X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
            Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
            button = [self createButtonWithImage:@"im_tool_shake_normal" highlight:@"im_tool_shake_press" target:delegate selector:self.onShake title:Localized(@"JX_Shake")];
            button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        }
        // 文件
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
        Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
        button = [self createButtonWithImage:@"im_file_button_normal" highlight:@"im_file_button_press" target:delegate selector:self.onFile title:Localized(@"JX_File")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        
        // 联系人
        n = (n + 1) >= 4 ? 0 : n + 1;
        m += 1;
        X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
        Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
        button = [self createButtonWithImage:@"im_ab_button_normal" highlight:@"im_ab_button_press" target:delegate selector:self.onAddressBook title:Localized(@"JX_SelectImageContact")];
        button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        /*
        // 群助手
        if (self.isGroup) {
            n = (n + 1) >= 4 ? 0 : n + 1;
            m += 1;
            X = m >8 ? SELECTIMAGE_WIDTH *n + (n+1)*inset+JX_SCREEN_WIDTH : SELECTIMAGE_WIDTH *n + (n+1)*inset;
            Y = m > 4 && m <=8 ? h+margeY*2 : margeY;
            button = [self createButtonWithImage:@"im_group_button_normal" highlight:@"im_group_button_normal" target:delegate selector:self.onGroupHelper title:Localized(@"JX_GroupAssistants")];
            button.frame = CGRectMake(X, Y, SELECTIMAGE_WIDTH, h);
        }
         */
        if (m > 8) {
            self.scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH * 2, 0);
            self.scrollView.pagingEnabled = YES;
            
            
            _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-(THE_DEVICE_HAVE_HEAD ? 65 : 30), JX_SCREEN_WIDTH-200, 30)];
            _pageControl.numberOfPages  = 2;
            _pageControl.pageIndicatorTintColor = [UIColor grayColor];
            _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
            [_pageControl addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_pageControl];
        }
        
    }
    return self;
}

- (void)actionPage {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x/320;
    int mod   = fmod(scrollView.contentOffset.x,320);
    if( mod >= 160)
        index++;
    _pageControl.currentPage = index;
}

-(void)dealloc
{
//    [super dealloc];
    
}

- (void)setHelpers:(NSArray *)helpers {
    for (UIView *subView in self.helperScrollV.subviews) {
        [subView removeFromSuperview];
    }
    if (!self.isWin && helpers.count <= 0) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-60)/2, 44+20, 60, 60)];
        img.image = [UIImage imageNamed:@"group_helper_notData"];
        [self.helperScrollV addSubview:img];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame)+10, JX_SCREEN_WIDTH, 20)];
        label.font = SYSFONT(15);
        label.text = Localized(@"JX_GroupNotAssistants");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HEXCOLOR(0x6E7377);
        [self.helperScrollV addSubview:label];
        return;
    }
    // 创建群助手
    CGFloat width = JX_SCREEN_WIDTH/2;
    int height = (self.frame.size.height-30-44)/3;

    UIView *lastView = nil;
    int m = 0;
    int count = self.isWin ? (int)(helpers.count + 1) : (int)helpers.count;
    for (int i = 0; i < count; i++) {
        JXGroupHeplerModel *model;
        if (i < helpers.count) {
            model = helpers[i];
        }
        UIView *view;
        if (lastView == nil) {
            view = [self createButtonWithFrame:CGRectMake(0, 0, width, height) iconUrl:model.helperModel.iconUrl title:model.helperModel.name index:i];
        }else {
            CGFloat maxX = CGRectGetMaxX(lastView.frame);
            
            int ii = ((int)maxX%(int)JX_SCREEN_WIDTH);
            if (ii <= 0) {
                int x = (int)((int)(CGRectGetMaxX(lastView.frame)+1)/(int)JX_SCREEN_WIDTH);
                if (CGRectGetMaxY(lastView.frame)+height > height*3) {
                    view = [self createButtonWithFrame:CGRectMake(x*JX_SCREEN_WIDTH, 0, width, height) iconUrl:model.helperModel.iconUrl title:model.helperModel.name index:i];
                }else {
                    view = [self createButtonWithFrame:CGRectMake((x-1)*JX_SCREEN_WIDTH, CGRectGetMaxY(lastView.frame), width, height) iconUrl:model.helperModel.iconUrl title:model.helperModel.name index:i];
                }
            }else {
                view = [self createButtonWithFrame:CGRectMake(CGRectGetMaxX(lastView.frame), CGRectGetMinY(lastView.frame), width, height) iconUrl:model.helperModel.iconUrl title:model.helperModel.name index:i];
            }
        }
        lastView = view;
        m += 1;
    }
    
    if (m > 6) {
        int num = m%6 > 0 ? m/6+1 : m/6;
        
        self.helperScrollV.contentSize = CGSizeMake(JX_SCREEN_WIDTH * num, 0);
        self.helperScrollV.pagingEnabled = YES;
        
        _pageControl.numberOfPages  = num;
    }else {
        self.pageControl.hidden = YES;
    }

}

- (void)resetPageControl {
    _pageControl.numberOfPages  = 2;
}

- (void)didView:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    self.viewIndex = view.tag;
    self.isDidSet = NO;
    [self.delegate performSelectorOnMainThread:self.onDidView withObject:self waitUntilDone:NO];
}

- (void)didSetImgV:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    self.viewIndex = view.tag;
    self.isDidSet = YES;
    [self.delegate performSelectorOnMainThread:self.onDidView withObject:self waitUntilDone:NO];
}


- (UIView *)createButtonWithImage:(NSString *)normalImage
                          highlight:(NSString *)clickIamge
                             target:(id)target
                           selector:(SEL)selector
                              title:(NSString*)title
{
    UIView* v = [[UIView alloc]init];
    
    UIButton* btn = [UIFactory createButtonWithImage:normalImage highlight:clickIamge target:target selector:selector];
    btn.frame = CGRectMake(0, 0, SELECTIMAGE_WIDTH, SELECTIMAGE_WIDTH);
    [v addSubview:btn];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(-15, SELECTIMAGE_WIDTH+9, SELECTIMAGE_WIDTH+30, 15)];
    p.text = title;
    p.font = g_factory.font13;
    p.textAlignment = NSTextAlignmentCenter;
    p.textColor = HEXCOLOR(0x666666);
    [v addSubview:p];
    
    [self.scrollView addSubview:v];
    
    return v;
}


- (UIView *)createButtonWithFrame:(CGRect)frame iconUrl:(NSString *)iconUrl title:(NSString *)title index:(NSInteger)index {

    UIView* view = [[UIView alloc]initWithFrame:frame];
    view.tag = index;
    
    UIView *riLine = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-LINE_WH, 0, LINE_WH, frame.size.height)];
    riLine.backgroundColor = THE_LINE_COLOR;
    [view addSubview:riLine];
    
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-LINE_WH, frame.size.width, LINE_WH)];
    botLine.backgroundColor = THE_LINE_COLOR;
    [view addSubview:botLine];
    
    if (index == 0 || index == 1) {
        UIView* topLine = [[UIView alloc]initWithFrame:CGRectMake(0,0,frame.size.width,LINE_WH)];
        topLine.backgroundColor = THE_LINE_COLOR;
        [view addSubview:topLine];
    }

    if (iconUrl.length <= 0 && title.length <= 0) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-20)/2, (frame.size.height-20)/2, 20, 20)];
        [btn setImage:[UIImage imageNamed:@"groupHelper_add"] forState:UIControlStateNormal];
        [btn addTarget:self.delegate action:self.onGroupHelperList forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:self.onGroupHelperList];
        [view addGestureRecognizer:tap];

    }else {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didView:)];
        [view addGestureRecognizer:tap];

        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height-30)/2, 30, 30)];
        imgV.layer.masksToBounds = YES;
        imgV.layer.cornerRadius = imgV.frame.size.width/2;
        [view addSubview:imgV];
        [imgV sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:@"avatar_normal"]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame)+10, (frame.size.height-18)/2, frame.size.width- 90, 16)];
        label.text = title;
        label.textColor = HEXCOLOR(0x6E7377);
        label.font = SYSFONT(14);
        [view addSubview:label];
        
        if (self.isWin) {
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-40, 0, 40, frame.size.height)];
            [view addSubview:view1];
            
            UIImageView *setImgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, (view1.frame.size.height-20)/2, 20, 20)];
            setImgV.image = [UIImage imageNamed:@"groupHelper_set"];
            setImgV.userInteractionEnabled = YES;
            setImgV.tag = index;
            [view1 addSubview:setImgV];
            
            UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSetImgV:)];
            [setImgV addGestureRecognizer:tap1];
        }
        

    }
    
    
    [self.helperScrollV addSubview:view];
    
    return view;
}


@end

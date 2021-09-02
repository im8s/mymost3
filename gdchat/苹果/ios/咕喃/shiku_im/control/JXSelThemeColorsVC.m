//
//  JXSelThemeColorsVC.m
//  shiku_im
//
//  Created by p on 2017/8/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXSelThemeColorsVC.h"

@interface JXSelThemeColorsVC ()
@property (nonatomic, strong) UIView *baseView;

@end

@implementation JXSelThemeColorsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.title = Localized(@"JX_ThemeColor");
    
    UILabel *tintLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, JX_SCREEN_WIDTH-15*2, 10)];
    tintLab.text = Localized(@"JX_ComeSelColor");
    tintLab.textColor = HEXCOLOR(0x999999);
    tintLab.font = SYSFONT(13);
    [self.tableBody addSubview:tintLab];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tintLab.frame)+5, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(tintLab.frame)-JX_SCREEN_TOP)];
    [self.tableBody addSubview:self.baseView];
    
    [self setupColorViews];
    
    
    //保存按钮
    UIButton *resaveBtn = [[UIButton alloc] init];
    resaveBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 51 - 15, JX_SCREEN_TOP - 8 - 29, 51, 29);
    resaveBtn.custom_acceptEventInterval = 1.0f;
    resaveBtn.layer.masksToBounds = YES;
    resaveBtn.layer.cornerRadius = 3.f;
    [resaveBtn setBackgroundColor:THEMECOLOR];
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [resaveBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    [resaveBtn.titleLabel setFont:SYSFONT(15)];
    [resaveBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
    [resaveBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:resaveBtn];
}

- (void) confirmBtnAction {
    [g_App showAlert:Localized(@"JXTheme_confirm") delegate:self tag:4444 onlyConfirm:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 4444 && buttonIndex == 1) {
        [g_theme switchSkinIndex:self.selectIndex];
        [g_mainVC.view removeFromSuperview];
        g_mainVC = nil;
        [self.view removeFromSuperview];
        self.view = nil;
        g_navigation.lastVC = nil;
        [g_navigation.subViews removeAllObjects];
        [[JXXMPP sharedInstance] logout];
        
        [g_App showMainUI];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSelectorColor:(UIButton *)button {
    self.selectIndex = button.tag;
    for (UIView *view  in self.baseView.subviews) {
        [view removeFromSuperview];
    }
    [self setupColorViews];
}


- (void)setupColorViews {
    
    UIButton *btn;
    int inset = 8;
    CGFloat w = (JX_SCREEN_WIDTH-30 - inset*3)/4;
    for (int i = 0; i < self.array.count; i++) {
        CGFloat x = 15+(w+inset)*(i % 4);
        int m = i / 4;
        btn = [self creatButtonWithFrame:CGRectMake(x, m*173+(15 * (m +1)), w, 157) color:[g_theme.skinList[i] objectForKey:SkinDictKeyColor] title:self.array[i] index:i];
    }
}



- (UIButton *)creatButtonWithFrame:(CGRect)frame color:(UIColor *)color title:(NSString *)title index:(NSInteger)index {
    UIButton *view = [[UIButton alloc] initWithFrame:frame];
    view.tag = index;
    [view addTarget:self action:@selector(onSelectorColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:view];
    
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 133)];
    colorView.backgroundColor = color;
    colorView.layer.masksToBounds = YES;
    colorView.layer.cornerRadius = 7.f;
    colorView.userInteractionEnabled = NO;
    [view addSubview:colorView];
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-5-14, 7, 14, 14)];
    imgV.image = [UIImage imageNamed:@"ThemeColor"];
    imgV.hidden = index != self.selectIndex;
    [colorView addSubview:imgV];
    
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]} context:nil].size;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(colorView.frame)+10, frame.size.width, size.height)];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = HEXCOLOR(0x333333);
    label.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview:label];
    
    return view;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


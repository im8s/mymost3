//
//  JXLinksShareVC.m
//  shiku_im
//
//  Created by 1 on 2019/3/11.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXLinksShareVC.h"

#define SHARE_HEIGHT 30  // 每个图片的宽度
#define SHARE_TEXT_WIDTH 60  // 每个文字的宽度
#define SELECTIMAGE_HEIGHT (SHARE_HEIGHT+40) // 每个单格的高度
#define TOP_INSET  25  // 间隔

@interface JXLinksShareVC ()
@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, assign) CGFloat bigH;


@end

@implementation JXLinksShareVC


- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bigH = SELECTIMAGE_HEIGHT*3+32+TOP_INSET*3 + (THE_DEVICE_HAVE_HEAD ? 50 : TOP_INSET);
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.bigView = [[UIView alloc] init];
    self.bigView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, self.bigH);
    self.bigView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bigView];
    
    [self setPartRoundWithView:self.bigView corners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:17.f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didBigView)];
    [self.bigView addGestureRecognizer:tap];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didView)];
    [self.view addGestureRecognizer:tap1];

    [self setupViews];
}

- (void)didBigView {
    // 点击bigview，不做处理。  优化体验， 防止每次点击到bigview 都会隐藏bigview
}

- (void)didView {
    [self hideShareView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.3f animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.bigView.frame = CGRectMake(0, JX_SCREEN_HEIGHT-self.bigH, JX_SCREEN_WIDTH, self.bigH);
    }];
}

// 画圆角
- (void)setPartRoundWithView:(UIView *)view corners:(UIRectCorner)corners cornerRadius:(float)cornerRadius {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
    view.layer.mask = shapeLayer;
}


- (void)setupViews {

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, JX_SCREEN_WIDTH, 14)];

    NSString *url = self.titleStr;
    if ([[NSURL URLWithString:self.titleStr] host] && [[NSURL URLWithString:self.titleStr] host].length > 0) {
        url = [[NSURL URLWithString:self.titleStr] host];
    }
    title.text = [NSString stringWithFormat:Localized(@"JX_ThisPageProvidedBy%@"),url];
    title.font = SYSFONT(13);
    title.textColor = [HEXCOLOR(0x333333) colorWithAlphaComponent:0.3];
    title.textAlignment = NSTextAlignmentCenter;
    [self.bigView addSubview:title];
    
    
    NSArray *images = @[self.isFloatWindow ? @"im_linksShare_un_float" : @"im_linksShare_float",@"im_linksShare_send_friend",@"im_linksShare_life",@"im_linksShare_safari",@"im_linksShare_send_friend_WX",@"im_linksShare_life_WX",@"im_linksShare_collection",@"im_linksShare_complaint",@"im_linksShare_link",@"im_linksShare_update",@"im_linksShare_search",@"im_linksShare_type"];
    
    NSArray *titles = @[self.isFloatWindow ? [NSString stringWithFormat:@"%@%@",Localized(@"JX_Close"),Localized(@"JX_FloatingWindow")] : Localized(@"JX_FloatingWindow"),Localized(@"JXSendToFriend"),Localized(@"JX_ShareLifeCircle"),Localized(@"JX_OpenInSafari"),Localized(@"JXSendToWXFriend"),Localized(@"JX_ShareLifeWXCircle"),Localized(@"JX_FavoriteURL"),Localized(@"UserInfoVC_Complaint"),[NSString stringWithFormat:@"%@%@",Localized(@"JX_Copy"),Localized(@"JXLink")],Localized(@"JX_Refresh"),Localized(@"JX_SearchPageContent"),Localized(@"JX_AdjustTheFont")];
    
    NSArray *sels = @[@"onFloatWindow",@"onSend",@"onShare",@"onSafari",@"onWXSend",@"onWXShare",@"onCollection",@"onReport",@"onPasteboard",@"onUpdate",@"onSearch",@"onTextType"];
    
    UIView *btn;
    int lineCount = 4; // 每行个数
    int inset = 15;     // 左右间隔
    int lineInset = TOP_INSET; // 行间隔
    int topInset = CGRectGetMaxY(title.frame)+lineInset; // 顶部间隔
    CGFloat w = (JX_SCREEN_WIDTH-inset*(lineCount+1))/lineCount;// 每个宽度
    
    for (int i = 0; i < 12; i++) {
        CGFloat x = (w+inset)*(i % lineCount)+inset;
        int m = i / lineCount;
        CGFloat y = topInset+m*SELECTIMAGE_HEIGHT+(lineInset * m);
        SEL sle = NSSelectorFromString(sels[i]);
        btn = [self createButtonWithFrame:CGRectMake(x, y, w, SELECTIMAGE_HEIGHT) image:images[i] highlight:images[i] target:self.delegate selector:sle title:titles[i]];
    }

}

- (UIView *)createButtonWithFrame:(CGRect)frame
                            image:(NSString *)normalImage
                        highlight:(NSString *)clickIamge
                           target:(id)target
                         selector:(SEL)selector
                            title:(NSString*)title
{
    UIView* v = [[UIView alloc]initWithFrame:frame];
    [self.bigView addSubview:v];

    UIButton* btn = [UIFactory createButtonWithImage:normalImage highlight:clickIamge target:target selector:selector];
    btn.frame = CGRectMake((frame.size.width-SHARE_HEIGHT)/2, 0, SHARE_HEIGHT, SHARE_HEIGHT);
    [v addSubview:btn];
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(12)} context:nil].size;
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame)+10, frame.size.width, size.height)];
    p.center = CGPointMake(btn.center.x, p.center.y);
    p.text = title;
    p.numberOfLines = 0;
    p.font = SYSFONT(11);
    p.textColor = HEXCOLOR(0x666666);
    p.textAlignment = NSTextAlignmentCenter;
    [v addSubview:p];
    
    CGRect frameV = v.frame;
    frameV.size.height = CGRectGetMaxY(p.frame);
    v.frame = frameV;
    
    return v;
}


- (void)hideShareView {
    [self hide];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}


- (void)hide {
    [UIView animateWithDuration:.3f animations:^{
        self.bigView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self) {
            [self.view removeFromSuperview];
        }
    }];
}

@end

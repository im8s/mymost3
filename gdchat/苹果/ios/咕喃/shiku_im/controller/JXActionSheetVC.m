//
//  JXActionSheetVC.m
//  shiku_im
//
//  Created by 1 on 2018/9/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXActionSheetVC.h"

#define HEIGHT 57    // 每个成员高度，如果更改记得更改button按钮的imageEdgeInsets
#define IMAGWE_W 25  // 图片宽高
#define INSET   17   // 文字和图片的间距

@interface JXActionSheetVC ()

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) CGFloat maxX;

@end

@implementation JXActionSheetVC

- (instancetype)initWithImages:(NSArray *)images names:(NSArray *)names {
    self = [super init];
    if (self) {
        //这句话是让控制器透明
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.backGroundColor = [UIColor whiteColor];
        self.names = names;
        self.images = images;
        
        
        // 获取当前最长的字符串
        NSString *currentStr = names[0];
        for (NSString *str in names) {
            if (currentStr.length < str.length) {
                currentStr = str;
            }
        }
        // 获取最长文字的size
        CGSize size = [currentStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(15)} context:nil].size;
        
        self.maxX = (JX_SCREEN_WIDTH-(size.width+INSET+IMAGWE_W))/2;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tag = self.tag;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    if (self.images.count > 0 || self.names.count > 0) {
        self.baseView = [[UIView alloc] init];
        self.baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self.view addSubview:self.baseView];
        [self setupViews];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.3f animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.baseView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}

- (void)setupViews {
    // 计算取消按钮的高度
    CGFloat cH = THE_DEVICE_HAVE_HEAD ? JX_SCREEN_BOTTOM : HEIGHT;

    // 创建一个取消按钮
    [self createButtonWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-cH, JX_SCREEN_WIDTH, cH) index:10000];
    for (int i = 0; i < self.names.count; i++) {
        int h = HEIGHT*(i+1);
        // 创建成员按钮
        [self createButtonWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-cH - h, JX_SCREEN_WIDTH,(i == self.names.count-1) ? HEIGHT+12 : HEIGHT) index:i];
    }
}

- (void)didButton:(UIButton *)button {
    
    //离开界面
    [self dismissViewController];
    if (button.tag >= 0 && button.tag != 10000) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:didButtonWithIndex:)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate actionSheet:self didButtonWithIndex:button.tag];
            });
        }
    } else {
        
    }
}

- (void)createButtonWithFrame:(CGRect)frame index:(int)index {
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    button.backgroundColor = self.backGroundColor;
    button.tag = index;
    [button addTarget:self action:@selector(didButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:button];
    UILabel *label = [[UILabel alloc] init];
    UIImageView *imgV;
    if (self.images.count > 0 && index !=10000 && index < self.images.count) {
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.maxX, (HEIGHT-IMAGWE_W)/2, IMAGWE_W, IMAGWE_W)];
        imgV.image = [UIImage imageNamed:self.images[index]];
        [button addSubview:imgV];
        label.frame = CGRectMake(CGRectGetMaxX(imgV.frame)+INSET, (HEIGHT-20)/2, JX_SCREEN_WIDTH-CGRectGetMaxX(imgV.frame)-INSET, 20);
    }else {
        label.frame = CGRectMake(0, (HEIGHT-20)/2, JX_SCREEN_WIDTH, 20);
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.backgroundColor = [UIColor clearColor];
    label.text = index==10000 ? Localized(@"JX_Cencal") : self.names[index];
    [button addSubview:label];
    if (index == self.names.count-1) {
        // 最顶部一行的位置处理
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y-12, button.frame.size.width, button.frame.size.height);
        imgV.frame = CGRectMake(imgV.frame.origin.x, (HEIGHT-IMAGWE_W)/2+12, imgV.frame.size.width, imgV.frame.size.height);
        label.frame = CGRectMake(label.frame.origin.x, (HEIGHT-20)/2+12, label.frame.size.width, label.frame.size.height);
        [self setPartRoundWithView:button corners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:17];
    }

    if (index == 10000) {
        //取消按钮位置处理
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width,THE_DEVICE_HAVE_HEAD ?  button.frame.size.height : HEIGHT);
        if (THE_DEVICE_HAVE_HEAD) { // iPhoneX 字体显示上移
            label.frame = CGRectMake(label.frame.origin.x, (HEIGHT-20)/2, label.frame.size.width, label.frame.size.height);
        }
    }
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(33, button.frame.size.height-LINE_WH, JX_SCREEN_WIDTH-66, LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [button addSubview:line];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewController];
}


- (void)dismissViewController {
    [UIView animateWithDuration:.3f animations:^{
        self.baseView.frame = CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self) {
            [self.view removeFromSuperview];
        }
    }];
}


// 画圆角
- (void)setPartRoundWithView:(UIView *)view corners:(UIRectCorner)corners cornerRadius:(float)cornerRadius {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
    view.layer.mask = shapeLayer;
}

@end

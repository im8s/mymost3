//
//  KKImageEditorViewController.m
//  WWImageEdit
//
//  Created by 邬维 on 2016/12/29.
//  Copyright © 2016年 kook. All rights reserved.
//

#import "KKImageEditorViewController.h"
#import "UIView+Frame.h"
#import "KKImageToolBase.h"
#import "KKImageToolInfo.h"
#import "KKToolBarItem.h"
#import "UIImage+Color.h"
#import "JXChatViewController.h"
#import "ImageBrowserViewController.h"
#import "RITLPhotosHorBrowseViewController.h"
#import "JXCameraVC.h"

@interface KKImageEditorViewController ()<KKImageToolProtocol>

@property (nonatomic, strong) KKImageToolBase *currentTool;
@property (nonatomic, strong) KKImageToolInfo *toolInfo;

@property (nonatomic, assign) BOOL isShowEdit;
@property (nonatomic, assign) BOOL isSelAllComplete;

@end

@implementation KKImageEditorViewController{
    UIImage *_originalImage;
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.toolInfo = [KKImageToolInfo toolInfoForToolClass:[self class]];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        
    }
    return self;
}


- (instancetype)initWithImage:(UIImage*)image delegate:(id<KKImageEditorDelegate>)delegate{
    self = [self init];
    if (self){
        _originalImage = [image copy];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark- view life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.view setBackgroundColor:[KKImageEditorTheme theme].backgroundColor];
    self.title = self.toolInfo.title;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushedDoneBtn)];
    [self.view addGestureRecognizer:tap];
    
    [self initMenuView];
    [self initImageScrollView];
    [self initToolSettings];
    [self initNavigationBar];
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        [_scrollView addSubview:_imageView];
        [self refreshImageView];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshImageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNavigationItem) name:KTextEditDoneNotification object:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                               NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]}];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    NSLog(@"KKImageEditorViewController dealloc");
}

#pragma -mark view init
//底部工具view
- (void)initMenuView{
    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - JX_SCREEN_BOTTOM, self.view.width, JX_SCREEN_BOTTOM)];
        _menuView.backgroundColor = [KKImageEditorTheme theme].toolbarColor;
        [self.view addSubview:_menuView];
    }
}

//底层ScrollView
- (void)initImageScrollView
{
    if(_scrollView==nil){
        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageScroll.showsHorizontalScrollIndicator = NO;
        imageScroll.showsVerticalScrollIndicator = NO;
        imageScroll.delegate = self;
        imageScroll.clipsToBounds = NO;
        
//        CGFloat y = self.navigationController.navigationBar.bottom;
//        imageScroll.top = y;
//        imageScroll.height = self.view.height - imageScroll.top - _menuView.height;

        [self.view insertSubview:imageScroll atIndex:0];
        _scrollView = imageScroll;
    }
}

//init工具 item
- (void)initToolSettings{
    for(UIView *sub in _menuView.subviews){ [sub removeFromSuperview]; }
    
    CGFloat x = 0;
    CGFloat W = 55;
    CGFloat H = _menuView.height;
    //基类不算 -1
    NSUInteger toolCount = self.toolInfo.subtools.count - 1;
    CGFloat padding = 0;
    
    CGFloat diff = _menuView.frame.size.width - toolCount * W;
    if (0<diff) {
        padding = diff/(toolCount+1);
    }
    
    for(KKImageToolInfo *info in [KKImageToolInfo sortWithTools:self.toolInfo.subtools]){
        if ([info.title isEqualToString:[KKImageToolBase defaultTitle]]) {
            continue;
        }
        KKToolBarItem *view = [[KKToolBarItem alloc] initWithFrame:CGRectMake(x+padding, 0, W, H) target:self action:@selector(tappedToolMenuItem:) toolInfo:info];
        
        [_menuView addSubview:view];
        x += W+padding;
    }
}

- (void)initNavigationBar{
    NSString *title;
    if ([self.delegate isKindOfClass:[JXChatViewController class]] || [self.delegate isKindOfClass:[JXCameraVC class]]) {
        title = Localized(@"JX_Send");
    }else {
        title = Localized(@"JX_Finish");
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(imageEditFinishBtn)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:Localized(@"JX_Cencal") style:UIBarButtonItemStylePlain target:self action:@selector(imageCancelBtn)];
    self.navigationItem.hidesBackButton = YES;

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(imageCancelBtn)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(imageEditFinishBtn)];
}

- (UIScrollView*)scrollView
{
    return _scrollView;
}

#pragma -mark KKImageToolProtocol
+ (UIImage*)defaultIconImage{
    return nil;
}

+ (NSString*)defaultTitle{
    return @"";
}

+ (NSArray*)subtools{
    return [KKImageToolInfo toolsWithToolClass:[KKImageToolBase class]];
}

+ (NSUInteger)orderNum{
    return 0;
}

#pragma -mark implementation

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.7*minZoomScale;
    _scrollView.minimumZoomScale = 0.7*minZoomScale;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)refreshImageView
{
    _imageView.image = _originalImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma -mark Tap Action
- (void)imageEditFinishBtn{
    self.isSelAllComplete = YES;
    
    [self pushedDoneBtn];
}

- (void)imageCancelBtn {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushedCancelBtn:(id)sender
{
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    
    self.currentTool = nil;
}

- (void)pushedDoneBtn
{
    //    self.view.userInteractionEnabled = NO;

    if (self.isShowEdit) {
        self.isShowEdit = NO;
        [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
            if(error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else if(image){
                _originalImage = image;
                _imageView.image = image;
                
                [self resetImageViewFrame];
                self.currentTool = nil;
                
                NSLog(@"------------------走的上面");
                [self popToVC];
            }
            //        self.view.userInteractionEnabled = YES;
        }];

    }else {
        NSLog(@"------------------走的下面");
        [self popToVC];
    }
}

- (void)popToVC {
    if (self.isSelAllComplete) {
        self.isSelAllComplete = NO;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if([self.delegate respondsToSelector:@selector(imageDidFinishEdittingWithImage:asset:)]){
                [self.delegate imageDidFinishEdittingWithImage:_originalImage asset:self.asset];
            }
        }];
    }

}

- (void)tappedToolMenuItem:(UITapGestureRecognizer*)sender
{
    self.isShowEdit = YES;
    KKToolBarItem *view = (KKToolBarItem *)sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kImageToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    [self setupToolWithToolInfo:view.imgToolInfo];
}

//设置当前工具信息
- (void)setupToolWithToolInfo:(KKImageToolInfo*)info
{
    if(self.currentTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[KKImageToolBase class]]){
            instance = [instance initWithImageEditor:self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

//初始化当前工具
- (void)setCurrentTool:(KKImageToolBase *)currentTool
{
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditting:(_currentTool!=nil)];
    }
}

//修改工具栏和导航栏
- (void)swapToolBarWithEditting:(BOOL)editting
{
    [UIView animateWithDuration:kImageToolAnimationDuration
                     animations:^{
                         if(editting){
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity; //复位
                         }
                     }
     ];
    if(self.currentTool){
        [self updateNavigationItem];
    }else{
        self.navigationItem.hidesBackButton = NO;
        [self initNavigationBar];
//        self.navigationItem.leftBarButtonItem = nil;
    }

}

- (void)updateNavigationItem{
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:Localized(@"JX_Cencal") style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark- ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

//view转为image
- (UIImage*)convertViewWithTop:(BOOL)isTop {
    UIView *tempView = [self setupViewWithTop:isTop];
    CGSize s = tempView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIView *)setupViewWithTop:(BOOL)isTop {
    UIView *view = [[UIView alloc] init];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    if (isTop) {  // 设置显示的fram
        gradientLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP);
    }else {
        gradientLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_BOTTOM);
    }
    if (isTop) { // 设置渐变颜色
        gradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[UIColor clearColor].CGColor];
    }else {
        gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor];
    }
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [view.layer addSublayer:gradientLayer];
    
    return view;
}

@end

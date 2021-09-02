//
//  ImageBrowserViewController.m
//  ImageBrowser
//
//  Created by msk on 16/9/1.
//  Copyright © 2016年 msk. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "PhotoView.h"
#import "JXUserInfoVC.h"
#import "webpageVC.h"
#import "JXActionSheetVC.h"
#import "KKImageEditorViewController.h"

@interface ImageBrowserViewController ()<UIScrollViewDelegate,PhotoViewDelegate,JXActionSheetVCDelegate,KKImageEditorDelegate,UINavigationControllerDelegate>{
    
    NSMutableArray *_subViewArray;//scrollView的所有子视图
}

/** 背景容器视图 */
@property(nonatomic,strong) UIScrollView *scrollView;

/** 外部操作控制器 */
@property (nonatomic,weak) UIViewController *handleVC;

/** 图片浏览方式 */
@property (nonatomic,assign) PhotoBroswerVCType type;

/** 图片数组 */
@property (nonatomic,strong) NSArray *imagesArray;

/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;

/** 圆点指示器 */
//@property(nonatomic,strong) UIPageControl *pageControl;

/** 记录当前的图片显示视图 */
@property(nonatomic,strong) PhotoView *photoView;

@end
static ImageBrowserViewController *shared;
@implementation ImageBrowserViewController

//+ (ImageBrowserViewController*)sharedInstance{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        shared = [[ImageBrowserViewController alloc]init];
//    });
//    return shared;
//}
- (void)dealloc{
    [g_notify removeObserver:self name:kImageDidTouchEndNotification object:[self.imagesArray lastObject]];
}
-(instancetype)init{
    
    self=[super init];
    if (self) {
        _subViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blackColor];
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurrentVC:)];
    [self.view addGestureRecognizer:tap];//为当前view添加手势，隐藏当前显示窗口
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

-(void)hideCurrentVC:(UIGestureRecognizer *)tap{
    [self hideScanImageVC];
}

#pragma mark - 显示图片
-(void)loadPhote:(NSInteger)index{
    
    if (index<0 || index >=self.imagesArray.count) {
        return;
    }
    id currentPhotoView = [_subViewArray objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoView class]]) {
        //url数组或图片数组
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if ([[self.imagesArray firstObject] isKindOfClass:[UIImage class]]) {
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoImage:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }else if ([[self.imagesArray firstObject] isKindOfClass:[NSString class]]){
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoUrl:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }
    }
}

#pragma mark - 生成显示窗口
+(void)show:(UIViewController *)handleVC delegate:(id)delegate isReadDel:(BOOL)isReadDel type:(PhotoBroswerVCType)type contentArray:(NSMutableArray *)contentArray index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock{
    
    NSArray *photoModels = imagesBlock();//取出相册数组
    
    if(photoModels == nil || photoModels.count == 0) {
        return ;
    }
    
    ImageBrowserViewController *imgBrowserVC = [[ImageBrowserViewController alloc] init];
    imgBrowserVC.isShow = YES;
    
    if(index >= photoModels.count){
        return ;
    }
    
    imgBrowserVC.delegate = delegate;
    
    imgBrowserVC.contentArray = contentArray;
    
    imgBrowserVC.index = index;
    
    imgBrowserVC.imagesArray = photoModels;
    
    imgBrowserVC.type =type;
    
    imgBrowserVC.handleVC = handleVC;
    
    imgBrowserVC.isReadDel = isReadDel;
    
    [imgBrowserVC show]; //展示
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].statusBarHidden = YES;
    });
    
}

/** 真正展示 */
-(void)show{
    
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self pushPhotoVC];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            
            [self modalPhotoVC];
            
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self zoomPhotoVC];
            
            break;
            
        default:
            break;
    }
}

/** push */
-(void)pushPhotoVC{
    
    [_handleVC.navigationController pushViewController:self animated:YES];
}


/** modal */
-(void)modalPhotoVC{
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [_handleVC presentViewController:self animated:YES completion:nil];
}

/** zoom */
-(void)zoomPhotoVC{
    
    //拿到window
    UIWindow *window = _handleVC.view.window;
    
    if(window == nil){
        NSLog(@"错误：窗口为空！");
        return;
    }
    
    self.view.frame=[UIScreen mainScreen].bounds;
    
    [window addSubview:self.view]; //添加视图
    
    [_handleVC addChildViewController:self]; //添加子控制器
}

#pragma mark - 隐藏当前显示窗口
-(void)hideScanImageVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissImageBrowserVC)]) {
        [self.delegate dismissImageBrowserVC];
    }
    [_subViewArray removeAllObjects];
    [UIApplication sharedApplication].statusBarHidden = NO;
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            [g_notify postNotificationName:kImageDidTouchEndNotification object:self.contentArray[self.index]];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            self.scrollView = nil;
            self.photoView = nil;
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page<0||page>=self.imagesArray.count) {
        return;
    }
//    self.pageControl.currentPage = page;
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[PhotoView class]]) {
            PhotoView *photoV=(PhotoView *)[_subViewArray objectAtIndex:page];
            if (photoV!=self.photoView) {
                [self.photoView.scrollView setZoomScale:1.0 animated:YES];
                self.photoView=photoV;
            }
        }
    }
    
    [self loadPhote:page];
}

#pragma mark - PhotoViewDelegate
-(void)tapHiddenPhotoView{
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self hideScanImageVC];//隐藏当前显示窗口
}

- (void)longPressPhotoView:(UIImage *)image {
    [self setupActionSheet];
}

- (void)setupActionSheet {
    NSMutableArray *names = @[Localized(@"JX_IdentifyTheQrCode"),Localized(@"JX_ImageEditTitle"),Localized(@"ImageBrowser_save")].mutableCopy;
    if (self.isReadDel) {
        [names removeObject:Localized(@"ImageBrowser_save")];
        [names removeObject:Localized(@"JX_ImageEditTitle")];
    }
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:names];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];
}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    if (self.isReadDel) {
        [self distinguishQRCode];
    }else {
        if (index == 0) {
            
            [self distinguishQRCode];
        }else if (index == 1) {
            KKImageEditorViewController *editor = [[KKImageEditorViewController alloc] initWithImage:self.photoView.imageView.image delegate:self];
            
            UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:editor];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }else if (index == 2) {
            
            [self saveImageToPhotos:self.photoView.imageView.image];
        }
    }
}

#pragma mark- 照片编辑后的回调
- (void)imageDidFinishEdittingWithImage:(UIImage *)image asset:(PHAsset *)asset
{
    self.photoView.imageView.image = image;
    [self setupActionSheet];
}


- (void) distinguishQRCode {
    UIImageView*tempImageView=(UIImageView*)self.photoView.imageView;
    
    if(tempImageView.image){
        
        //1. 初始化扫描仪，设置设别类型和识别质量
        
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        
        //2. 扫描获取的特征组
        
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:tempImageView.image.CGImage]];
        
        //3. 获取扫描结果
        
        if (features.count <= 0) {
            [g_App showAlert:Localized(@"JX_NoQrCode")];
            return;
        }
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        
        NSString *scannedResult = feature.messageString;
        
        if ([self.delegate respondsToSelector:@selector(imageBrowserVCQRCodeAction:)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideScanImageVC];
                [self.delegate imageBrowserVCQRCodeAction:scannedResult];
            });
        }
        
//        [self QRCodeAction:scannedResult];
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//
//        [alertView show];
        
    }else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:Localized(@"JX_ScanResults") message:Localized(@"JX_Haven'tQrCode") delegate:nil cancelButtonTitle:Localized(@"JX_Confirm") otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        
        msg = Localized(@"ImageBrowser_saveFaild");
        
    }else{
        
        msg = Localized(@"ImageBrowser_saveSuccess");
        
    }
    
    [g_server showMsg:msg];
    
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    
    if (_scrollView==nil) {
        _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.contentOffset=CGPointZero;
        //设置最大伸缩比例
        _scrollView.maximumZoomScale=3;
        //设置最小伸缩比例
        _scrollView.minimumZoomScale=1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

//-(UIPageControl *)pageControl{
//    if (_pageControl==nil) {
//        UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-40, WIDTH, 30)];
//        bottomView.backgroundColor=[UIColor clearColor];
//        _pageControl = [[UIPageControl alloc] initWithFrame:bottomView.bounds];
//        _pageControl.currentPage = self.index;
//        _pageControl.numberOfPages = self.imagesArray.count;
//        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1];
//        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:235 green:235 blue:235 alpha:0.6];
//        [bottomView addSubview:_pageControl];
//        [self.view addSubview:bottomView];
//    }
//    return _pageControl;
//}
-(void)setImagesArray:(NSArray *)imagesArray{
    _imagesArray = imagesArray;
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH * self.imagesArray.count, 0);
    
    for (int i = 0; i < self.imagesArray.count; i++) {
        [_subViewArray addObject:[NSNull class]];
    }
    
    self.scrollView.contentOffset = CGPointMake(JX_SCREEN_WIDTH*self.index, 0);//此句代码需放在[_subViewArray addObject:[NSNull class]]之后，因为其主动调用scrollView的代理方法，否则会出现数组越界
    
    if (self.imagesArray.count==1) {
        //        _pageControl.hidden=YES;
    }else{
        //        self.pageControl.currentPage=self.index;
    }
    
    [self loadPhote:self.index];//显示当前索引的图片

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

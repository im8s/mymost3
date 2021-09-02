//
//  JXSelectCoverVC.m
//  shiku_im
//
//  Created by IMAC on 2019/7/31.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSelectCoverVC.h"
#import "RITLPhotosViewController.h"
#import "RITLPhotosDataManager.h"

#define imgVWidth (JX_SCREEN_WIDTH - 25) / 4
#define imgVHeight 131

@interface JXSelectCoverVC ()<RITLPhotosViewControllerDelegate>
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)NSString *video;
@end

@implementation JXSelectCoverVC
- (instancetype)initWithVideo:(NSString *)video{
    if (self = [super init]) {
        self.video = video;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isGotoBack = YES;
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    [self createHeadAndFoot];
    self.headerTitle.text = Localized(@"JX_ChooseVideoCover");
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self_width-7-65, JX_SCREEN_TOP - 38, 65, 30)];
    if (THESIMPLESTYLE) {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [btn setTitle:Localized(@"ALBUM") forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(gotoImage) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:btn];
    [self.tableBody setScrollEnabled:YES];
    self.tableBody.backgroundColor = [UIColor whiteColor];
    self.imageArray = [NSMutableArray array];
    
    [self createImages];
}

- (void) createImages {
    [_wait start:Localized(@"JX_Loading")];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        double integer = [FileInfo getVideoTimeFromVideo:self.video];
        NSInteger num = 0;
        double interval;
        if (integer < 16) {
            interval = integer/16;
            num = 16;
        }else if (integer >= 16 && integer <= 32){
            interval = 1;
            num = ceil(integer);
        }else{
            interval = integer/32;
            num = 32;
        }
        for (int i = 0; i< num; i++) {
            UIImage *image = [FileInfo getImagesFromVideo:self.video withTimeInterval:interval*(i+1)];
            if (image) {
                [_imageArray addObject:image];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < _imageArray.count; i++) {
                if (i <= 3) {
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*i, 0, imgVWidth , imgVHeight) index:i];
                }else if (i > 3 && i <= 7 ) {
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-4), (imgVHeight + 5) * 1, imgVWidth, imgVHeight) index:i];
                }else if(i > 7 && i <= 11){
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-8), (imgVHeight + 5) * 2, imgVWidth, imgVHeight) index:i];
                }else if(i > 11 && i <= 15){
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-12), (imgVHeight + 5) * 3, imgVWidth, imgVHeight) index:i];
                }else if(i > 15 && i <= 19){
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-16), (imgVHeight + 5) * 4, imgVWidth, imgVHeight) index:i];
                }else if(i > 19 && i <= 23){
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-20), (imgVHeight + 5) * 5, imgVWidth, imgVHeight) index:i];
                }else if (i > 23 && i <= 27){
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-24), (imgVHeight + 5) * 6, imgVWidth, imgVHeight) index:i];
                }else{
                    [self createImageViewWithImage:_imageArray[i] frame:CGRectMake(5+(imgVWidth + 5)*(i-28), (imgVHeight + 5) * 7, imgVWidth, imgVHeight) index:i];
                }
            }
            int row = ceilf(_imageArray.count / 4.0);
            self.tableBody.contentSize = CGSizeMake(JX_SCREEN_WIDTH, (imgVHeight + 5) * row - 5);
            [_wait stop];
        });
    });
    
}

- (void)gotoImage{
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 1;//最大的选择数目
    photoController.configuration.containVideo = NO;
    photoController.configuration.containImage = YES;
    photoController.photo_delegate = self;
    CGSize assetSize = CGSizeMake(320, 320);
    photoController.thumbnailSize = assetSize;
    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoController animated:true completion:^{}];
}
- (void)photosViewController:(UIViewController *)viewController images:(NSArray <UIImage *> *)images infos:(NSArray <NSDictionary *> *)infos{
    UIImage *img = images[0];
    if ([self.delegate respondsToSelector:@selector(touchAtlasButtonReturnCover:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate touchAtlasButtonReturnCover:img];
            [self actionQuit];
        });
    }
}
- (void)photosViewController:(UIViewController *)viewController thumbnailImages:(NSArray <UIImage *> *)thumbnailImages infos:(NSArray <NSDictionary *> *)infos{
    UIImage *img = thumbnailImages[0];
    if ([self.delegate respondsToSelector:@selector(touchAtlasButtonReturnCover:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate touchAtlasButtonReturnCover:img];
            [self actionQuit];
        });
    }
//    [g_navigation dismissViewController:self animated:YES];
}
- (void)didImageView:(UIGestureRecognizer *)sender{
    if ([self.delegate respondsToSelector:@selector(selectImage: toView:)]) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate selectImage:((UIImageView *)sender.view).image toView:self];
//        });
    }
//    [g_navigation dismissViewController:self animated:YES];
    [self actionQuit];
}
- (void)createImageViewWithImage:(UIImage *)img frame:(CGRect )frame index:(NSInteger)index{
    UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
    imgV.frame = frame;
    imgV.tag = index;
    imgV.userInteractionEnabled = YES;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didImageView:)];
    [imgV addGestureRecognizer:ges];
    [self.tableBody addSubview:imgV];
}


@end

//
//  ImageSelectorViewController.m
//  shiku_im
//
//  Created by 1 on 17/1/19.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "ImageSelectorViewController.h"
#import "ImageSelectorCollectionCell.h"

static NSString* const imageSelectCellID = @"imageSelectCellID";

@interface ImageSelectorViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    CGRect _initFrame;
}

@property (nonatomic, strong) JXCollectionView * collectionView;
@property (nonatomic, assign) NSInteger selectIndex;


@end

@implementation ImageSelectorViewController


- (instancetype)init{
    self = [super init];
    if (self) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = JX_SCREEN_BOTTOM;
        self.isGotoBack = YES;
        self.isFreeOnClose = YES;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = THEMEBACKCOLOR;
        self.tableBody.scrollEnabled = YES;
        _selectIndex = 0;
        [self customView];
        
//        [g_notify addObserver:self selector:@selector(changeSelectCell:) name:@"ImageSelectirCollectionCellSetSelected" object:nil];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@.dealloc",NSStringFromClass([self class]));
//    [g_notify removeObserver:self name:@"ImageSelectirCollectionCellSetSelected" object:nil];
//    [super dealloc];
}
-(void)actionQuit{
    self.imageFileNameArray = nil;
    [super actionQuit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)customView{

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[JXCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableBody.frame.size.width, self.tableBody.frame.size.height) collectionViewLayout:layout];
//    [layout release];
    _collectionView.allowsSelection = YES;
    _collectionView.backgroundColor = THEMEBACKCOLOR;
    _collectionView.contentSize = CGSizeMake(0, self.tableBody.frame.size.height+10);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.userInteractionEnabled = YES;
    [_collectionView registerClass:[ImageSelectorCollectionCell class] forCellWithReuseIdentifier:imageSelectCellID];
    [self.tableBody addSubview:_collectionView];
//    [_collectionView release];

    
    UIButton * submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.frame = CGRectMake((JX_SCREEN_WIDTH-130)/2, JX_SCREEN_HEIGHT+(JX_SCREEN_BOTTOM-38)/2-JX_SCREEN_BOTTOM, 130, 38);
    [submitButton setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [submitButton setTitle:Localized(@"JX_Confirm") forState:UIControlStateHighlighted];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [submitButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [submitButton setBackgroundColor:THEMECOLOR];
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [submitButton setBackgroundImage:img forState:UIControlStateHighlighted];
    submitButton.layer.cornerRadius = 3;
    [submitButton addTarget:self action:@selector(submitImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imageFileNameArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((JX_SCREEN_WIDTH - 30)/2, (JX_SCREEN_WIDTH - 30)/2);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageSelectorCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageSelectCellID forIndexPath:indexPath];
    cell.didImageView = @selector(didImageView:);
    cell.didSelectView = @selector(didSelectView:);
    cell.delegate = self;
    cell.index = indexPath.row;
    cell.isSelected = [self cellIsSelectedIndex:indexPath.item];
    [cell refreshCellWithImagePath:_imageFileNameArray[indexPath.item]];
    return cell;
}

-(BOOL)cellIsSelectedIndex:(long)index{
    return index == _selectIndex;
}

-(void) showFullScreenViewImage:(UIImage*)image{
    UIImageView *zoomView = [[UIImageView alloc] initWithFrame:_initFrame];
    zoomView.image = image;
    zoomView.backgroundColor = [UIColor blackColor];
    zoomView.contentMode = UIViewContentModeScaleAspectFit;
    zoomView.userInteractionEnabled = YES;
    [self.view addSubview:zoomView];
//    [zoomView release];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenFullScreenImage:)];
    [zoomView addGestureRecognizer:tap];
//    [tap release];
    
    [UIView animateWithDuration:0.3 animations:^{
        zoomView.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    }];
}

-(void)hiddenFullScreenImage:(UITapGestureRecognizer *)tapGesture{
    [UIView animateWithDuration:0.3 animations:^{
        tapGesture.view.frame = _initFrame;
    } completion:^(BOOL finished) {
        [tapGesture.view removeFromSuperview];
    }];
}

-(void)submitImage{
    if (_selectIndex) {
        //
    }
    if (_imgDelegete && [_imgDelegete respondsToSelector:@selector(imageSelectorDidiSelectImage:)]) {
        NSObject *obj = _imageFileNameArray.count > 0 ? _imageFileNameArray[_selectIndex] : nil;
        [_imgDelegete performSelector:@selector(imageSelectorDidiSelectImage:) withObject:obj];
    }
    [self deleteOtherImage];
    [self actionQuit];
}

-(void)deleteOtherImage{
    for (int i=0; i<_imageFileNameArray.count; i++) {
        if (i != _selectIndex) {
            BOOL b = [[NSFileManager defaultManager] removeItemAtPath:_imageFileNameArray[i] error:nil];
            if (!b)
                NSLog(@"文件删除失败");
        }
    }
}

-(void)didSelectView:(UIView*)sender{
    [self changeCell:_selectIndex selected:NO];
    [self changeCell:sender.tag selected:YES];
    _selectIndex = sender.tag;
}

-(void)didImageView:(UIView*)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    ImageSelectorCollectionCell * cell = (ImageSelectorCollectionCell*)[_collectionView cellForItemAtIndexPath:indexPath];
    _initFrame = [cell.contentView convertRect:cell.imageView.frame toView:self.view];
    UIImage * image = [cell.imageView image];
    [self showFullScreenViewImage:image];
}

-(void)changeCell:(long)index selected:(BOOL)value{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    ImageSelectorCollectionCell * cell = (ImageSelectorCollectionCell*)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = value;
    if(value)
        cell.selectView.image = [UIImage imageNamed:@"selected_true"];
    else
        cell.selectView.image = [UIImage imageNamed:@"selected_fause"];
    
}

@end

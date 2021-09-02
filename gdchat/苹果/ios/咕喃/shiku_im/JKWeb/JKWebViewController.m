//
//  JKWebViewController.m
//  shiku_im
//
//  Created by DJK on 2020/12/26.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JKWebViewController.h"


#import "JXConnection.h"
//#import<WebKit/WKWebView.h>
//**********************  设备的 宽高 ******************************//
// 设备全屏高
#define SCREEN_FULL_HEIGHT  [[UIScreen mainScreen] bounds].size.height
// 设备全屏宽
#define SCREEN_FULL_WIDTH [[UIScreen mainScreen] bounds].size.width

//按钮间的间隔

@interface JKWebViewController ()<JXConnectionDelegate,UIScrollViewDelegate>
{

    int _selectIndex;
    
    int _lastContentOffset;
    
    UIButton *_btnLeft;
    UIButton *_btnRight;
    
//    NSMutableArray *_btnArr;
        NSMutableArray *_titleArr;
        NSMutableArray *_urlArr;

//    UIView *viewSlider;

    
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIScrollView *scrollViewNavi;
//@property (strong, nonatomic) UIView *viewSlider;

//@property (strong, nonatomic) NSMutableArray  *arrBtns;
@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic ,strong) UISegmentedControl *segment;

@end

@implementation JKWebViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _array = [NSMutableArray new];
        _titleArr = [NSMutableArray new];
        _urlArr = [NSMutableArray new];
//        _btnArr = [NSMutableArray new];
//        [self getServerData ];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self getServerData];

    [self creatSegment];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//_selectIndex
//    for (UIButton *btn in _btnArr) {
//        if (btn.tag == _selectIndex) {
//            [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//
//        }
        
//    }
//    viewSlider.backgroundColor = THEMECOLOR;

}

- (void)creatSegment{
    _segment = [[UISegmentedControl alloc] initWithItems:_titleArr];
    _segment.frame = CGRectMake(SCREEN_FULL_WIDTH/2-_titleArr.count*35, 34, _titleArr.count*70, 30);
    [_segment setTitleTextAttributes:@{NSForegroundColorAttributeName:THEMECOLOR} forState:UIControlStateSelected];
          //设置未选中的字体颜色为白色
      [_segment setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} forState:UIControlStateNormal];

    [self.view addSubview:_segment];
    [self.view bringSubviewToFront:_segment];
    
    UIColor *greenColor = THEMECOLOR;
        NSDictionary *colorAttr = [NSDictionary dictionaryWithObject:greenColor forKey:UITextAttributeTextColor];
        [_segment setTitleTextAttributes:colorAttr forState:UIControlStateNormal];
    
    _segment.selectedSegmentIndex = 0;
    [_segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];

}

- (void)segmentChange:(UISegmentedControl *)segment{
    [segment setTitleTextAttributes:@{NSForegroundColorAttributeName:THEMECOLOR} forState:UIControlStateSelected];
          //设置未选中的字体颜色为白色
      [segment setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} forState:UIControlStateNormal];
    
    NSInteger index = segment.selectedSegmentIndex;

    _scrollView.contentOffset = CGPointMake(index*SCREEN_FULL_WIDTH, 0);
    
}


//初始化 顶部按钮的ScrollView

//JXUserObject *user = _array[indexPath.row];
//cell.title = user.userNickname;
//cell.userId = user.userId;
//[cell.lbTitle setText:cell.title];
//[cell headImageViewImageWithUserId:nil roomId:nil];

//初始化 内容的ScrollView
-(void)initwebView
{
//    int navigationHeight = 64;
    
     CGRect rectOfStatusbar = [[UIApplication sharedApplication] statusBarFrame]; NSLog(@"statusbar height: %f", rectOfStatusbar.size.height); // 高度
    CGFloat StatusbarH = rectOfStatusbar.size.height;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_FULL_WIDTH, SCREEN_FULL_HEIGHT)];
    scrollView.tag = 1;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    self.scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    
    scrollView.contentSize = CGSizeMake(SCREEN_FULL_WIDTH*_urlArr.count, SCREEN_FULL_HEIGHT);
    [self.view addSubview:scrollView];

    
    for (int i=0; i<_urlArr.count; i++) {
        
//        int xr = 1+arc4random() % 256;
//        int xg = 1+arc4random() % 256;
//        int xb = 1+arc4random() % 256;
//        //放内容的View
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i*SCREEN_FULL_WIDTH, 0, SCREEN_FULL_WIDTH, SCREEN_FULL_HEIGHT-64)];
//        view.backgroundColor = [UIColor colorWithRed:xr*1.0/255 green:xg*1.0/255 blue:xb*1.0/255 alpha:1];
        UITabBarController *tab = [[UITabBarController alloc] init];
        CGFloat tabH = tab.tabBar.height;
        UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(i*SCREEN_FULL_WIDTH, StatusbarH, SCREEN_FULL_WIDTH, SCREEN_FULL_HEIGHT-StatusbarH - tabH)];
        web.backgroundColor = [UIColor whiteColor];

           //2.要打开的网址
           NSString *openURL = _urlArr[i];
           NSURL *URL = [NSURL URLWithString:openURL];
           NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
           
           //3。加载内容
           [web loadRequest:requestURL];
           
        [scrollView addSubview:web];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getServerData {
    [g_server getDiscoverWebList:@"" toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    if( [aDownload.action isEqualToString:act_GetDiscoveryWebList] ){
        
        NSLog(@"------%@",array1);
        
        for (NSDictionary *arr in array1) {
            [_titleArr addObject:arr[@"title"]];
            [_urlArr addObject:arr[@"url"]];

        }
        [self initwebView];

        [self creatSegment];

//        NSMutableArray *arr = [[NSMutableArray alloc] init];
//            [_array removeAllObjects];
//            for (int i = 0; i < array1.count; i++) {
//                JXUserObject *user = [[JXUserObject alloc] init];
//                [user getDataFromDict:array1[i]];
//                [arr addObject:user];
//            }
//            [_array addObjectsFromArray:arr];
//                NSLog(@"------%@",_array);
//        [self reloadWebData];
        

    }

}

- (void)reloadWebData{
    
    
    //初始化 内容的ScrollView
    _titleArr = [NSMutableArray arrayWithArray:@[@"百度百度",@"百度百度",@"百度百度"]];

    
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

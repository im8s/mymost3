//
//  photosViewController.m
//  sjvodios
//
//  Created by  on 12-6-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "photosViewController.h"
#import "JXImageView.h"
#import "JXServer.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXConnection.h"
#import "UIFactory.h"

@implementation photosViewController
@synthesize photos;
@synthesize page=_page;

+(photosViewController*)showPhotos:(NSArray*)a{
    if([a count]<=0)
        return nil;
    photosViewController* vc = [photosViewController alloc];
    vc.photos = [a mutableCopy];
    vc = [vc init];
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
    return vc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        _array = [[NSMutableArray alloc]init];
        
        //self.view.frame = g_window.bounds;

        sv = [[UIScrollView alloc] initWithFrame:self.view.frame];
        sv.pagingEnabled = YES;
        sv.scrollEnabled = YES;
        sv.delegate = self;
        sv.showsVerticalScrollIndicator = NO;
        sv.showsHorizontalScrollIndicator = NO;
        sv.backgroundColor = [UIColor blackColor];
        sv.userInteractionEnabled = YES;
        sv.minimumZoomScale = 1;
        sv.maximumZoomScale = 1;
        sv.tag = 1;
        [self.view addSubview:sv];
//        [sv release];
        
        _iv = [[JXImageView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-41,0,41,41)];
        _iv.image = [UIImage imageNamed:@"playback_close"];
        _iv.didTouch = @selector(actionQuit);
        _iv.delegate = self;
        [self.view addSubview:_iv];
//        [_iv release];
        
        [self showImages];
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"photosViewController.dealloc");
    [UIApplication sharedApplication].statusBarHidden = NO;
    [_array removeAllObjects];
//    [_array release];
    self.photos = nil;
//    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
}

-(void)showImages{
    _photoCount = (int)[photos count];
    if(_photoCount<=0)
        return;
    sv.contentSize = CGSizeMake(sv.frame.size.width*_photoCount, sv.frame.size.height);
    for(int i=0;i<_photoCount;i++){
        UIScrollView* vi = [[UIScrollView alloc] initWithFrame:CGRectMake(i*sv.frame.size.width,0, sv.frame.size.width,sv.frame.size.height)];
        vi.pagingEnabled = NO;
        vi.scrollEnabled = YES;
        vi.delegate = self;
        vi.showsVerticalScrollIndicator = NO;
        vi.showsHorizontalScrollIndicator = NO;
        vi.backgroundColor = [UIColor blackColor];
        vi.userInteractionEnabled = YES;
        vi.minimumZoomScale = 1;
        vi.maximumZoomScale = 5;
        //UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(i*sv.frame.size.width,0, sv.frame.size.width,sv.frame.size.height)];
        [sv addSubview:vi];
//        [vi release];
        
        JXLabel* lb;
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(0, sv.frame.size.height*0.45, sv.frame.size.width, 20)];
        lb.textColor    = [UIColor whiteColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.font = g_factory.font13;
        lb.textAlignment = NSTextAlignmentCenter;
        lb.text  = [NSString stringWithFormat:@"%@%d%@..",Localized(@"photosViewController_Reading1"),i+1,Localized(@"photosViewController_Reading2")];
        [vi addSubview:lb];
//        [lb release];
        
        JXImageView* iv = [[JXImageView alloc]initWithFrame:CGRectMake(0, 0, sv.frame.size.width, sv.frame.size.height)];
        iv.userInteractionEnabled = YES;
        iv.didTouch = @selector(actionImage);
        iv.delegate = self;
        iv.changeAlpha = NO;
        [vi addSubview:iv];
//        [iv release];
        [_array addObject:iv];

        NSString* url = [(NSDictionary *)[photos objectAtIndex:i] objectForKey:@"oUrl"];
        [g_server getImage:url imageView:iv];
    }
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setPage
{   
	sv.contentOffset = CGPointMake(JX_SCREEN_WIDTH*_page, 0.0f);
    NSString* url = [(NSDictionary *)[photos objectAtIndex:_page] objectForKey:@"oUrl"];
    [g_server getImage:url imageView:[_array objectAtIndex:_page]];
}

- (void)setPage:(int)value{
    _page = value;
    if(_page<0)
        _page=0;
    if(_page >= _photoCount)
        _page = 0;
    [self setPage];
}

-(void)actionLast{
    _page--;
    if(_page<0)
        _page=0;
    [self setPage];
}

-(void)actionNext{
    _page++;
    if(_page >= _photoCount)
        _page = 0;
    [self setPage];
}

-(void)actionQuit{
    [UIFactory onGotoBack:self];
}

-(void)actionImage{
    _iv.hidden = !_iv.hidden;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView.tag != 1)
        return;
    int index = scrollView.contentOffset.x/JX_SCREEN_WIDTH;
    int mod   = fmod(scrollView.contentOffset.x,JX_SCREEN_WIDTH);
    if( mod >= 160)
        index++;
//    NSLog(@"%f,%f,%f",scrollView.contentOffset.x,index,mod);
    _page = index;
    [self setPage];    
    [self doReadNext];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self doReadNext];
}

-(void) doReadNext{
    if(_page<_photoCount-1){
        NSString* url = [(NSDictionary *)[photos objectAtIndex:_page+1] objectForKey:@"oUrl"];
        [g_server getImage:url imageView:[_array objectAtIndex:_page+1]];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if(scrollView.tag == 1)
        return nil;
    return [_array objectAtIndex:_page];
}

@end

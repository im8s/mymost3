#import "gifViewController.h"
#import "SCGIFImageView.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@implementation gifViewController
@synthesize delegate=_delegate,faceArray,imageArray;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor darkGrayColor];
    self.backgroundColor = HEXCOLOR(0xF2F2F2);
    
	imageArray = [[NSMutableArray alloc] init];
    faceArray  = [[NSMutableArray alloc] init];
    margin = 18;
//    tempN = (JX_SCREEN_WIDTH <= 320) ? 8:10;
    tempN = JX_SCREEN_WIDTH / (60 + margin);

    if (((tempN + 1) * 60 + tempN * margin) <= JX_SCREEN_WIDTH) {
        tempN += 1;
    }

    [self getGifFiles];
    [self create];
    
    return self;
}

-(void)getGifFiles{
    
    NSString* dir = gifImageFilePath;
    NSString* Path;
    NSString* ext;
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString *aPath in contentOfFolder) {
        Path = [dir stringByAppendingPathComponent:aPath];
        ext  = [aPath pathExtension];

        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir] && !isDir)
        {
            if( [ext isEqualToString:@"gif"] ){
                SCGIFImageView* iv = [[SCGIFImageView alloc] initWithGIFFile:Path];
                [imageArray addObject:[iv getFrameAsImageAtIndex:0]];
                [faceArray addObject:[Path lastPathComponent]];
//                [iv release];
            }
        }
    }

    int n = fmod([faceArray count], (tempN * 2));
    maxPage = [faceArray count]/(tempN*2);
    if(n != 0)
        maxPage++;
}

- (void)dealloc {
//    [faceArray release];
//    [imageArray release];
//    [_gifIv release];
//    [super dealloc];
}

-(void)create{
    _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
    _sv.contentSize = CGSizeMake(WIDTH_PAGE*maxPage, self.frame.size.height-20);
    _sv.pagingEnabled = YES;
    _sv.scrollEnabled = YES;
    _sv.delegate = self;
    _sv.showsVerticalScrollIndicator = NO;
    _sv.showsHorizontalScrollIndicator = NO;
    _sv.userInteractionEnabled = YES;
    _sv.minimumZoomScale = 1;
    _sv.maximumZoomScale = 1;
    _sv.decelerationRate = 0.01f;
    _sv.backgroundColor = [UIColor clearColor];
    [self addSubview:_sv];
//    [_sv release];
    

    int n = 0;
    int startX = (JX_SCREEN_WIDTH - tempN * 60 - (tempN - 1) * margin) / 2;
    
    for(int i=0;i<maxPage;i++){
        int x=WIDTH_PAGE*i + startX,y=0;
        for(int j=0;j<tempN * 2;j++){
            if(n>=[faceArray count])
                break;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x, y+10, 60, 60);
            button.tag = n;
            [button setBackgroundImage:[imageArray objectAtIndex:n] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionSelect:)forControlEvents:UIControlEventTouchUpInside];
            [_sv addSubview:button];
            
            if ((j + 1) % tempN == 0) {
                x = WIDTH_PAGE*i + startX;
                y += 70;
            }else {
                x += 60 + margin;
            }
            
//            if(fmod(i*tempN+j+1, tempN/2)==0.0f && j >= (tempN/2-1)){
//                x = WIDTH_PAGE*i + startX;
//                y += 70;
//            }else
//                x += 60;
            
            n++;
        }
    }
    
    _pc = [[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-30, JX_SCREEN_WIDTH-200, 30)];
    _pc.numberOfPages  = maxPage;
    _pc.pageIndicatorTintColor = [UIColor grayColor];
    _pc.currentPageIndicatorTintColor = [UIColor blackColor];
    [_pc addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pc];
//    [_pc release];
}


-(void)actionSelect:(UIView*)sender
{
    NSString* s = [faceArray objectAtIndex:sender.tag];
    NSString *text = [s lastPathComponent];
    if ([self.delegate respondsToSelector:@selector(selectGifWithString:)]) {
        [self.delegate selectGifWithString:text];
    }
    
//    NSString* s = [faceArray objectAtIndex:sender.tag];
//    if( [_delegate isKindOfClass:[UITextField class]] ){
//        UITextField* p = _delegate;
//        int old = p.tag;
//        p.tag = kWCMessageTypeGif;
//        p.text = [s lastPathComponent];
//        if(p.delegate)
//            [p.delegate textFieldShouldReturn:p];
//        p.tag = old;
//        p = nil;
//    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/JX_SCREEN_WIDTH;
    int mod   = fmod(scrollView.contentOffset.x,JX_SCREEN_WIDTH);
    if( mod >= JX_SCREEN_WIDTH/2)
        index++;
    _pc.currentPage = index;
    //    [self setPage];
}

- (void) setPage
{
	_sv.contentOffset = CGPointMake(WIDTH_PAGE*_pc.currentPage, 0.0f);
//    NSLog(@"setPage:%d,%f",_sv.contentOffset,_pc.currentPage);
    [_pc setNeedsDisplay];
}

-(void)actionPage{
    [self setPage];
}

@end

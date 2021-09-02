#import "FaceViewController.h"
#import "SCGIFImageView.h"
#import "JXMessageObject.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@implementation FaceViewController
@synthesize delegate=_delegate,shortNameArrayC,shortNameArrayE;

#define PAGE_COUNT 1

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
//    self.backgroundColor = [UIColor darkGrayColor];
    self.backgroundColor = HEXCOLOR(0xF2F2F2);

    /*
    faceArray = [[NSArray alloc]initWithObjects:@"[微笑]",@"[撇嘴]",@"[色]",@"[发呆]",@"[得意]",@"[流泪]",@"[害羞]",@"[闭嘴]",@"[睡]",@"[大哭]",
                 @"[尴尬]",@"[发怒]",@"[调皮]",@"[龇牙]",@"[惊讶]",@"[难过]",@"[严肃]",@"[冷汗]",@"[抓狂]",@"[吐]",@"[偷笑]",@"[可爱]",@"[白眼]",@"[傲慢]",
                 @"[饥饿]",@"[困]",@"[惊恐]",@"[流汗]",@"[憨笑]",@"[大兵]",@"[奋斗]",@"[咒骂]",@"[疑问]",@"[嘘]",@"[晕]",@"[折磨]",@"[衰]",@"[骷髅]",
                 @"[敲打]",@"[再见]",@"[擦汗]",@"[抠鼻]",@"[鼓掌]",@"[糗大了]",@"[坏笑]",@"[左哼哼]",@"[右哼哼]",@"[哈欠]",@"[鄙视]",@"[委屈]",@"[快哭了]",
                 @"[阴险]",@"[亲嘴]",@"[吓]",@"[可怜]",@"[菜刀]",@"[西瓜]",@"[啤酒]",@"[篮球]",@"[乒乓]",@"[咖啡]",@"[饭]",@"[猪头]",@"[玫瑰]",@"[凋谢]",
                 @"[示爱]",@"[爱心]",@"[心碎]",@"[蛋糕]",@"[闪电]",@"[炸弹]",@"[刀]",@"[足球]",@"[瓢虫]",@"[便便]",@"[拥抱]",@"[月亮]",@"[太阳]",@"[礼物]",
                 @"[强]",@"[弱]",@"[握手]",@"[胜利]",@"[抱拳]",@"[勾引]",@"[拳头]",@"[差劲]",@"[爱你]",@"[NO]",@"[OK]",@"[苹果]",@"[可爱狗]",@"[小熊]",@"[彩虹]",@"[皇冠]",@"[钻石]",nil];
    */
//#warning 表情
//    faceArray = [[NSArray alloc]initWithObjects:Localized(@"[Smiley]"),Localized(@"[Proud]"),Localized(@"[Shy]"),Localized(@"[Sweat]"),Localized(@"[Grinning]"),Localized(@"[Shocked]"),Localized(@"[Happy]"),Localized(@"[Crying]"),Localized(@"[Vomiting]"),Localized(@"[Kiss]"),Localized(@"[Horny]"),Localized(@"[Sick]"),Localized(@"[Angry]"),Localized(@"[Cool]"),Localized(@"[Aggrieved]"),Localized(@"[Serious]"),Localized(@"[Doubt]"),Localized(@"[Dizzy]"),nil];
    
//    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
//    faceArray = [FileInfo getFilesName:bundlePath];
    
//    NSLog(@"faceArray = %@", faceArray);
    
    //@"[微笑]",@"[得意]",@"[害羞]",@"[汗]",@"[奸笑]",@"[惊呆了]",@"[开心]",@"[哭]",@"[呕吐]",@"[亲亲]",@"[色眯眯]",@"[生病]",@"[生气]",@"[爽]",@"[委屈]",@"[严肃]",@"[疑问]",@"[晕]"
//Localized(@"[Smile]"),Localized(@"[Proud]"),Localized(@"[Shy]"),Localized(@"[Sweat]"),Localized(@"[Smirking]"),Localized(@"[Shocked]"),Localized(@"[Happy]"),Localized(@"[Cry]"),Localized(@"[Sick]"),Localized(@"[Kiss]"),Localized(@"[Yasisi]"),Localized(@"[Ill]"),Localized(@"[Angry]"),Localized(@"[Cool]"),Localized(@"[Grievance]"),Localized(@"[Serious]"),Localized(@"[Doubt]"),Localized(@"[Halo]")
//    @"[Smile]",@"[Proud]",@"[Shy]",@"[Sweat]",@"[Smirking]",@"[Shocked]",@"[Happy]",@"[Cry]",@"[Sick]",@"[Kiss]",@"[Yasisi]",@"[Ill]",@"[Angry]",@"[Cool]",@"[Grievance]",@"[Serious]",@"[Doubt]",@"[Halo]"
//	imageArrayC = [[NSMutableArray alloc] init];
//    imageArrayE = [[NSMutableArray alloc] init];
    shortNameArrayC = [[NSMutableArray alloc] init];
    shortNameArrayE = [[NSMutableArray alloc] init];
    self.imageArray = [[NSMutableArray alloc] init];
//    for (int i = 0;i<[faceArray count];i++){
////        NSString* s = [NSString stringWithFormat:@"f%.3d.png",i];
//        NSString* s = [faceArray objectAtIndex:i];
//        NSRange r;
//        r.length = [s length]-2;
//        r.location = 1;
//        s = [NSString stringWithFormat:@"%@.png",[s substringWithRange:r]];
//        [imageArray addObject:s];
//    }
//    NSString *firstStr = @"";
//    //英文
//    firstStr = @"e-";
//    for (int i = 0;i<[faceArray count];i++){
//        //        NSString* s = [NSString stringWithFormat:@"f%.3d.png",i];
//        NSString* s = [faceArray objectAtIndex:i];
//        NSString *str = [s substringToIndex:2];
//        if ([str isEqualToString:firstStr]) {
//            
//            [imageArrayE addObject:s];
//        }
//    }
//    
//    for (int i = 0; i < imageArrayE.count; i ++) {
//        NSString *s = imageArrayE[i];
//        NSRange range1 = [s rangeOfString:@"_"];
//        NSRange range2 = [s rangeOfString:@"@"];
//        NSInteger length = range2.location - range1.location;
//        NSString *str = [s substringWithRange:NSMakeRange(range1.location + 1, length - 1)];
//        NSString *string = [NSString stringWithFormat:@"[%@]",str];
//        [shortNameArrayE addObject:string];
//    }
//    
//    firstStr = @"c-";
//    for (int i = 0;i<[faceArray count];i++){
//        //        NSString* s = [NSString stringWithFormat:@"f%.3d.png",i];
//        NSString* s = [faceArray objectAtIndex:i];
//        NSString *str = [s substringToIndex:2];
//        if ([str isEqualToString:firstStr]) {
//            
//            [imageArrayC addObject:s];
//        }
//    }
//    
//    for (int i = 0; i < imageArrayC.count; i ++) {
//        NSString *s = imageArrayC[i];
//        NSRange range1 = [s rangeOfString:@"_"];
//        NSRange range2 = [s rangeOfString:@"@"];
//        NSInteger length = range2.location - range1.location;
//        NSString *str = [s substringWithRange:NSMakeRange(range1.location + 1, length - 1)];
//        NSString *string = [NSString stringWithFormat:@"[%@]",str];
//        [shortNameArrayC addObject:string];
//    }
    
    // 文件名
    for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
        NSDictionary *dic = g_constant.emojiArray[i];
        NSString *str = dic[@"filename"];
        [self.imageArray addObject:str];
        
        // 英文短名
        str = [NSString stringWithFormat:@"[%@]",dic[@"english"]];
        [shortNameArrayE addObject:str];
        
        // 中文短名
        str = [NSString stringWithFormat:@"[%@]",dic[@"chinese"]];
        [shortNameArrayC addObject:str];
    }
//    // 英文短名
//    for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
//        NSDictionary *dic = g_constant.emojiArray[i];
//    }
//    // 中文短名
//    for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
//        NSDictionary *dic = g_constant.emojiArray[i];
//        NSString *str = [NSString stringWithFormat:@"[%@]",dic[@"chinese"]];
//        [shortNameArrayC addObject:str];
//    }
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage rangeOfString:@"zh-"].location == NSNotFound) {    //如果不是中文就返回
//        self.imageArray = imageArrayE;
        self.shortNameArray = shortNameArrayE;
    }else{
//        self.imageArray = imageArrayC;
        self.shortNameArray = shortNameArrayC;
    }
    
    
    
    [self create];
    return self;
}

- (void)dealloc {
//    [faceArray removeAllObjects];
    [_imageArray removeAllObjects];
//    [imageArrayC removeAllObjects];
//    [imageArrayE removeAllObjects];
//    [faceArray release];
//    [self.imageArray release];
//    [super dealloc];
}

-(void)create{
    int iconWith = 32;
    int margin = 17;
    int tempN = JX_SCREEN_WIDTH / (iconWith+margin);
//    int tempN = 8;
    NSInteger pageCount = self.imageArray.count / (tempN * 3 - 1);
    if (self.imageArray.count % (tempN * 3 - 1) != 0) {
        pageCount = pageCount + 1;
    }
    _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
    _sv.contentSize = CGSizeMake(WIDTH_PAGE*pageCount, self.frame.size.height-20);
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

//    int tempN = (JX_SCREEN_WIDTH <= 320) ? 8:((JX_SCREEN_WIDTH >= 414) ? 10:9);
    
    int startX = (JX_SCREEN_WIDTH - tempN * iconWith - (tempN + 1) * margin) / 2;
    int n = 0;
//    UIImage *tempImage;
    NSString* s;

    for(int i=0;i<pageCount;i++){
        int x=WIDTH_PAGE*i + startX,y=0;
        for(int j=0;j<tempN * 3 - 1;j++){
            if(n>=[self.imageArray count])
                break;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x+margin, y+10, iconWith, iconWith);
            button.tag = n;
            
                s = [self.imageArray objectAtIndex:n];
                [button addTarget:self action:@selector(actionSelect:)forControlEvents:UIControlEventTouchUpInside];
                
                if( (j+1) % tempN == 0){
                    x = WIDTH_PAGE*i + startX;
                    y += 50;
                }else
                    x += (iconWith+margin);
            n++;
            UIImage * emojiImage = [UIImage imageNamed:s];
            if (!emojiImage)
                NSLog(@"kong:%@",s);
            [button setBackgroundImage:emojiImage forState:UIControlStateNormal];
            [_sv addSubview:button];
            
        }
        
        s = @"im_delete_button_press";
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionDelete:)forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(_sv.frame.size.width * (i + 1) - 33-15, 115, 33, 23);
        [button setBackgroundImage:[UIImage imageNamed:s] forState:UIControlStateNormal];
        [_sv addSubview:button];
    }
    
    _pc = [[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-30, JX_SCREEN_WIDTH-200, 30)];
    _pc.numberOfPages  = pageCount;
    _pc.pageIndicatorTintColor = [UIColor grayColor];
    _pc.currentPageIndicatorTintColor = [UIColor blackColor];
    [_pc addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pc];
//    [_pc release];
}


-(void)actionSelect:(UIView*)sender
{
    NSString *imageName = self.imageArray[sender.tag];
    NSString* shortName = [self.shortNameArrayE objectAtIndex:sender.tag];
    if ([self.delegate respondsToSelector:@selector(selectImageNameString:ShortName:isSelectImage:)]) {
        [self.delegate selectImageNameString:imageName ShortName:shortName isSelectImage:YES];
    }
//    NSString* s = [self.shortNameArray objectAtIndex:sender.tag];
//    if( [_delegate isKindOfClass:[UITextField class]] ){
//        UITextField* p = _delegate;
//        p.tag = kWCMessageTypeText;
//        NSString* t = @"";
//        if([p.text length]<=0)
//            p.text = t;
//        p.text = [p.text stringByAppendingString:s];
//        [p setNeedsDisplay];
//        p = nil;
//    }
}

-(IBAction)actionDelete:(UIView*)sender{
    if ([self.delegate respondsToSelector:@selector(faceViewDeleteAction)]) {
        [self.delegate faceViewDeleteAction];
    }
//    if( [_delegate isKindOfClass:[UITextField class]] ){
//        UITextField* p = _delegate;
//        NSString* s = p.text;
//
//        if([s length]<=0)
//            return;
//        int n=-1;
//        if( [s characterAtIndex:[s length]-1] == ']'){
//            for(int i=[s length]-1;i>=0;i--){
//                if( [s characterAtIndex:i] == '[' ){
//                    n = i;
//                    break;
//                }
//            }
//        }
//        if(n>=0)
//            p.text = [s substringWithRange:NSMakeRange(0,n)];
//        else
//            p.text = [s substringToIndex:[s length]-1];
//        p = nil;
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/320;
    int mod   = fmod(scrollView.contentOffset.x,320);
    if( mod >= 160)
        index++;    
    _pc.currentPage = index;
//    [self setPage];
}

- (void) setPage
{
	_sv.contentOffset = CGPointMake(WIDTH_PAGE*_pc.currentPage, 0.0f);
//    NSLog(@"setPage:%d,%ld",_sv.contentOffset,_pc.currentPage);
    [_pc setNeedsDisplay];
}

-(void)actionPage{
    [self setPage];
}

/*
-(void)createRecognizer{
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    //限定操作的触点数
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1];
    //将手势添加到draggableObj里
    [self addGestureRecognizer:panGR];
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint offset = [sender translationInView:g_App.window];
        if(offset.y>20 || offset.y<-20)
            return;
        if(offset.x>0)
            _pc.currentPage++;
        else
            _pc.currentPage--;
        [self setPage];
    }
}*/

@end

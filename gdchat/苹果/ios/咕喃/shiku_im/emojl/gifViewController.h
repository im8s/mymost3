#import <UIKit/UIKit.h>

@class SCGIFImageView;

@protocol gifViewControllerDelegate <NSObject>

- (void) selectGifWithString:(NSString *) str;

@end

@interface gifViewController : UIView <UIScrollViewDelegate>{
	NSMutableArray            *_phraseArray;
    UIScrollView              *_sv;
    UIPageControl* _pc;
    SCGIFImageView* _gifIv;
    BOOL pageControlIsChanging;
    NSInteger maxPage;
    
    int tempN;
    int margin;
}

@property (nonatomic, weak) id <gifViewControllerDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *faceArray;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

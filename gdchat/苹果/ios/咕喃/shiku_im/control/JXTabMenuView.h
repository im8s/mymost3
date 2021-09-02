//
//  JXTabMenuView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@interface JXTabMenuView : UIImageView{
    NSMutableArray*    _arrayBtns;
    
}
//@property (nonatomic,strong)  NSArray* arrayBtns;
@property (nonatomic,strong)  NSArray* items;
@property (nonatomic,strong)  NSArray* imagesNormal;
@property (nonatomic,strong)  NSArray* imagesSelect;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		onClick;
@property (nonatomic, assign) SEL		onDragout;
@property (nonatomic, assign) int       height;
@property (nonatomic, assign) NSInteger selected;
@property (nonatomic, assign) BOOL      isTabMenu;
@property (nonatomic, strong) NSString *backgroundImageName;

-(void)unSelectAll;
-(void)selectOne:(int)n;
-(void)setTitle:(int)n title:(NSString*)s;
-(void)setBadge:(int)n title:(NSString*)s;
-(void)setBadge:(int)n title:(NSString*)s isSmall:(BOOL )isSmall;
@end

//
//  JXTopMenuView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//
#define MAX_MENU_ITEM 20

#import <UIKit/UIKit.h>

@interface JXTopMenuView : UIImageView{
    BOOL       _showMore[MAX_MENU_ITEM];
    NSMutableArray* arrayBage;
}
@property (nonatomic,strong)  NSMutableArray* arrayBtns;
@property (nonatomic,strong)  NSArray* items;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		onClick;
@property (nonatomic, assign) int       selected;

-(void)unSelectAll;
-(void)selectOne:(int)n;
-(void)setBadge:(int)n title:(NSString*)s;
-(void)setTitle:(int)n title:(NSString*)s;
-(void)showMore:(int)index onSelected:(SEL)onSelected;
@end

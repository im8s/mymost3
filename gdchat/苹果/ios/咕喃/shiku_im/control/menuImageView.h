//
//  menuImageView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@interface menuImageView : UIImageView{
    NSMutableArray*    _arrayBtns;

}
@property (nonatomic,strong)  NSMutableArray* arrayBtns;
@property (nonatomic,strong)  NSArray* items;
@property (nonatomic,strong)  UIFont*  menuFont;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		onClick;
@property (nonatomic, assign) int		type;
@property (nonatomic, assign) int       offset;
@property (nonatomic, assign) int		itemWidth;
@property (nonatomic, assign) int       selected;
@property (nonatomic, assign) BOOL      showSelected;

-(void)reset;
-(void)draw;
-(void)unSelectAll;
-(void)selectOne:(int)n;
-(void)setTitle:(int)n title:(NSString*)s;
@end

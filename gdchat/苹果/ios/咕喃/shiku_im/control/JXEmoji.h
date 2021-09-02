//
//  JXEmoji.h
//  sjvodios
//
//  Created by jixiong on 13-7-9.
//
//
#import "JXLabel.h"
#import <UIKit/UIKit.h>

@interface JXEmoji : JXLabel<UIActionSheetDelegate>{
    NSMutableArray *data;
    int _top;
    int _size;
}
@property(nonatomic,assign)int faceHeight;
@property(nonatomic,assign)int faceWidth;
@property(nonatomic,assign)int maxWidth;
@property(nonatomic,assign)int offset;

//特殊文本的范围
@property(nonatomic, strong) NSArray* matches;

@property(nonatomic, strong) NSSet* lastTouches;

@property(nonatomic,strong)  NSString * copyText;

@property(nonatomic,assign)  BOOL contentEmoji;


-(void) setText:(NSString *)text;

@end

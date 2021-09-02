//
//  JXEmoji.h
//  sjvodios
//
//  Created by jixiong on 13-7-9.
//
//
#import "JXLabel.h"
#import <UIKit/UIKit.h>

@interface JXEmoji : JXLabel {
    NSMutableArray *data;
    int _top;
    int _size;
}
@property(nonatomic,assign)int faceHeight;
@property(nonatomic,assign)int faceWidth;
@property(nonatomic,assign)int maxWidth;
@property(nonatomic,assign)int offset;

//特殊文本的范围
@property(nonatomic, strong) NSMutableArray* matches;

@property(nonatomic, strong) NSSet* lastTouches;

@property(nonatomic,strong)  NSString * textCopy;

@property(nonatomic,assign)  BOOL contentEmoji;

@property(nonatomic, strong) NSString *atUserIdS;

@property(nonatomic,assign)  BOOL contentAt;

// 是否将号码作为特殊样式显示
@property (nonatomic, assign) BOOL isShowNumber;

-(void) setText:(NSString *)text;

@end

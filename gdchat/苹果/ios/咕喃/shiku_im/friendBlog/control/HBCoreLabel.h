//
//  HBCoreLabel.h
//  CoreTextMagazine
//
//  Created by weqia on 13-10-27.
//  Copyright (c) 2013年 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchParser.h"
@class HBCoreLabel;
@protocol HBCoreLabelDelegate <NSObject>
@optional
-(void)coreLabel:(HBCoreLabel*)coreLabel linkClick:(NSString*)linkStr;
-(void)coreLabel:(HBCoreLabel *)coreLabel phoneClick:(NSString *)linkStr;
-(void)coreLabel:(HBCoreLabel *)coreLabel mobieClick:(NSString *)linkStr;

@end

@interface HBCoreLabel : UILabel
{
    MatchParser* _match;
    
    BOOL touch;
    
    id<MatchParserDelegate> _data;
    
    NSString * _linkStr;
    
    NSString * _linkType;
    
    BOOL _copyEnableAlready;
    
    BOOL _attributed;
}
@property(nonatomic,strong ) MatchParser * match;
@property(nonatomic,weak) IBOutlet id<HBCoreLabelDelegate> delegate;
@property(nonatomic) BOOL linesLimit;
-(void)registerCopyAction;
-(void)setAttributedText:(NSString *)attributedText;
@end

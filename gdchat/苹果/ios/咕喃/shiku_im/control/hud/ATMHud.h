/*
 *  ATMHud.h
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import <UIKit/UIKit.h>
@class ATMHudView, ATMSoundFX, ATMHudQueueItem;
@protocol ATMHudDelegate;

typedef enum {
	ATMHudAccessoryPositionTop = 0,
	ATMHudAccessoryPositionRight,
	ATMHudAccessoryPositionBottom,
	ATMHudAccessoryPositionLeft
} ATMHudAccessoryPosition;

@interface ATMHud : UIViewController {
	CGFloat margin;
	CGFloat padding;
	CGFloat alpha;
	CGFloat appearScaleFactor;
	CGFloat disappearScaleFactor;
	CGFloat progressBorderRadius;
	CGFloat progressBorderWidth;
	CGFloat progressBarRadius;
	CGFloat progressBarInset;
	
	CGPoint center;
	
	BOOL shadowEnabled;
	BOOL blockTouches;
	BOOL allowSuperviewInteraction;
	
	NSString *showSound;
	NSString *updateSound;
	NSString *hideSound;
	
	ATMHudAccessoryPosition accessoryPosition;
	
	@private
	ATMHudView *__view;
	ATMSoundFX *sound;
	NSMutableArray *displayQueue;
	NSInteger queuePosition;
}

@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat appearScaleFactor;
@property (nonatomic, assign) CGFloat disappearScaleFactor;
@property (nonatomic, assign) CGFloat progressBorderRadius;
@property (nonatomic, assign) CGFloat progressBorderWidth;
@property (nonatomic, assign) CGFloat progressBarRadius;
@property (nonatomic, assign) CGFloat progressBarInset;

@property (nonatomic, assign) CGPoint center;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL shadowEnabled;
@property (nonatomic, assign) BOOL blockTouches;
@property (nonatomic, assign) BOOL allowSuperviewInteraction;

@property (nonatomic, strong) NSString *showSound;
@property (nonatomic, strong) NSString *updateSound;
@property (nonatomic, strong) NSString *hideSound;

@property (nonatomic, weak) id <ATMHudDelegate> delegate;
@property (nonatomic, assign) ATMHudAccessoryPosition accessoryPosition;

@property (nonatomic, strong) ATMHudView *__view;
@property (nonatomic, strong) ATMSoundFX *sound;
@property (nonatomic, strong) NSMutableArray *displayQueue;
@property (nonatomic, assign) NSInteger queuePosition;

+ (NSString *)buildInfo;
+(ATMHud*)sharedInstance;

- (id)initWithDelegate:(id)hudDelegate;

- (void)setCaption:(NSString *)caption;
- (void)setImage:(UIImage *)image;
- (void)setActivity:(BOOL)activity;
- (void)setActivityStyle:(UIActivityIndicatorViewStyle)activityStyle;
- (void)setFixedSize:(CGSize)fixedSize;
- (void)setProgress:(CGFloat)progress;

- (void)addQueueItem:(ATMHudQueueItem *)item;
- (void)addQueueItems:(NSArray *)items;
- (void)clearQueue;
- (void)startQueue;
- (void)showNextInQueue;
- (void)showQueueAtIndex:(NSInteger)index;

- (void)show:(UIView*)parent;
- (void)stop;
- (void)start;
- (void)start:(NSString*)s;
- (void)start:(NSString*)s inView:(UIView *)parent;
- (void)start:(NSString*)s delay:(int)delay;
- (void)startWithClearColor;
- (void)show;
- (void)update;
- (void)hide;
- (void)hideAfter:(NSTimeInterval)delay;
- (void)startWithouAnimation;
- (void)startWithouAnimation:(NSString*)s;
- (void)startWithouAnimation:(NSString*)s delay:(int)delay;
- (void)hideWithoutAnimation;

- (void)playSound:(NSString *)soundPath;

@end

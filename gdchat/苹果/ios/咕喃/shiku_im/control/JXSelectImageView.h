//
//  JXSelectImageView.h
//
//  Created by Reese on 13-8-22.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXGroupHeplerModel.h"

@protocol WCShareMoreDelegate <NSObject>

@optional
@end


@interface JXSelectImageView :  UIView <UIScrollViewDelegate>

@property (nonatomic,weak) id delegate;
@property(assign) SEL onImage;
@property(assign) SEL onVideo;
@property(assign) SEL onFile;
@property(assign) SEL onCard;
@property(assign) SEL onLocation;
@property(assign) SEL onVideoChat;
@property(assign) SEL onAudioChat;
@property(assign) SEL onGift;
@property(assign) SEL onCamera;
@property(assign) SEL onShake;
@property(assign) SEL onCollection;
@property(assign) SEL onTransfer;
@property(assign) SEL onAddressBook;
@property(assign) SEL onGroupHelper;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isGroupMessages;
@property (nonatomic, assign) BOOL isDevice;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIScrollView *helperScrollV;
@property (nonatomic, assign) BOOL isGroupHelper;
@property (nonatomic, assign) BOOL isWin; // YES：群主 
@property (nonatomic, strong) NSArray *helpers;

@property(assign) SEL onGroupHelperList;
@property(assign) SEL onDidView;
@property (nonatomic, assign) BOOL isDidSet; // YES:点击设置图片 NO:点击整个view
@property (nonatomic, assign) NSInteger viewIndex;


- (void)resetPageControl;

@end




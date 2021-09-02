//
//  JXMsgViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXTableViewController.h"
#import <UIKit/UIKit.h>

@interface JXMsgViewController : JXTableViewController <UIScrollViewDelegate>{
//    NSMutableArray *_array;
    int _refreshCount;
    int _recordCount;
    float lastContentOffset;
    int upOrDown;
    JXAudioPlayer* _audioPlayer;
}
@property(nonatomic,assign) int msgTotal;
@property (nonatomic, strong) NSMutableArray *array;

- (void)cancelBtnAction;
- (void)getTotalNewMsgCount;

@end

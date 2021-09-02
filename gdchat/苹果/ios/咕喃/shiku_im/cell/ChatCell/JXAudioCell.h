//
//  JXAudioCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
#import <AVFoundation/AVFoundation.h>
@class JXChatViewController;

@interface JXAudioCell : JXBaseChatCell{
//    JXAudioPlayer* _audioPlayer;
}

@property (nonatomic,strong) UILabel * timeLen;
@property (nonatomic,strong) UIImageView * voice;
@property (nonatomic,strong) NSArray * array;
@property (nonatomic,strong) JXAudioPlayer* audioPlayer;
@property (nonatomic,copy)   NSString *oldFileName;

- (void)timeGo:(NSString *)fileName;
@end

//
//  JXRequestChatKeyCell.h
//  shiku_im
//
//  Created by p on 2019/9/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXBaseChatCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXRequestChatKeyCell : JXBaseChatCell

@property (nonatomic, strong) UIImageView * imageBackground;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *sendBtn;

- (void)updateChatKey;

@end

NS_ASSUME_NONNULL_END

//
//  FavoritesVC.h
//  shiku_im
//
//  Created by p on 2017/9/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

@protocol FavoritesVCDelegate <NSObject>

// 发送
- (void) selectFavoritWithString:(NSString *) str;
// 删除
- (void) deleteFavoritWithString:(NSString *) str;

@end

#import <UIKit/UIKit.h>

@interface FavoritesVC : UIViewController

@property (nonatomic, weak) id<FavoritesVCDelegate>delegate;

@end

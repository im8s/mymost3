//
//  UIWebView+JXSearchWebView.h
//  shiku_im
//
//  Created by 1 on 2019/3/13.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (JXSearchWebView)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str index:(NSInteger)index;
- (void)removeAllHighlights;


@end

NS_ASSUME_NONNULL_END

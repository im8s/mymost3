//
//  UIWebView+JXSearchWebView.m
//  shiku_im
//
//  Created by 1 on 2019/3/13.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "UIWebView+JXSearchWebView.h"

@implementation UIWebView (JXSearchWebView)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str index:(NSInteger)index
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@', '%d')",str,index];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}

- (void)removeAllHighlights
{
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

@end

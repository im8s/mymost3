//
//  ImageBrowserViewController.h
//  ImageBrowser
//
//  Created by msk on 16/9/1.
//  Copyright © 2016年 msk. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 跳转方式
 */
typedef NS_ENUM(NSUInteger,PhotoBroswerVCType) {
    
    //modal
    PhotoBroswerVCTypePush=0,
    
    //push
    PhotoBroswerVCTypeModal,
    
    //zoom
    PhotoBroswerVCTypeZoom,
};

@protocol ImageBrowserVCDelegate <NSObject>

- (void)imageBrowserVCQRCodeAction:(NSString *)stringValue;

- (void)dismissImageBrowserVC;

@end

@interface ImageBrowserViewController : UIViewController
@property (nonatomic,assign)BOOL isShow;
@property (nonatomic, weak)id<ImageBrowserVCDelegate> delegate;
@property (nonatomic, assign)SEL seeOK;
@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic,assign)BOOL isReadDel; // 阅后即焚消息

/**
 *  显示图片
 */

+(void)show:(UIViewController *)handleVC delegate:(id)delegate isReadDel:(BOOL)isReadDel type:(PhotoBroswerVCType)type contentArray:(NSMutableArray *)contentArray index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock;
-(void)hideScanImageVC;
@end

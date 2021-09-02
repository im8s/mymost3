//
//  JXCustomShareVC.h
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXCustomShareVC : UIViewController

-(void) didServerNetworkResultSucces:(JXNetwork*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1;
-(int) didServerNetworkResultFailed:(JXNetwork*)aDownload dict:(NSDictionary*)dict;
-(int) didServerNetworkError:(JXNetwork*)aDownload error:(NSError *)error;
-(void) didServerNetworkStart:(JXNetwork*)aDownload;

@end

NS_ASSUME_NONNULL_END

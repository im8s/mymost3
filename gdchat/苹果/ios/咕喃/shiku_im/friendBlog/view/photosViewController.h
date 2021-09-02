//
//  photosViewController.h
//  sjvodios
//
//  Created by  on 12-6-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@protocol JXServerResult;
@class JXImageView;

@interface photosViewController : UIViewController<UIScrollViewDelegate>{
    int _page;
    UIScrollView* sv;
    int      _photoCount;
    JXImageView* _iv;
    NSMutableArray* _array;
}
@property(nonatomic,retain) NSMutableArray* photos;
@property(nonatomic) int page;
+(photosViewController*)showPhotos:(NSArray*)a;

@end

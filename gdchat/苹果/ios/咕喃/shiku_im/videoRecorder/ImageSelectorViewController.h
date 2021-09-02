//
//  ImageSelectorViewController.h
//  shiku_im
//
//  Created by 1 on 17/1/19.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "admobViewController.h"

@protocol ImageSelectorViewDelegate <NSObject>

-(void)imageSelectorDidiSelectImage:(NSString *)imagePath;

@end

@interface ImageSelectorViewController : admobViewController


@property (nonatomic,strong) NSArray * imageFileNameArray;
@property (nonatomic, weak) id<ImageSelectorViewDelegate> imgDelegete;

@end

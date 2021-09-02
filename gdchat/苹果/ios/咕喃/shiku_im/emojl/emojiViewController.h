//
//  emojiViewController.h
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceViewController.h"
#import "FavoritesVC.h"
@class menuImageView;
@class gifViewController;

@interface emojiViewController : UIView{
    menuImageView* _tb;
    FaceViewController* _faceView;
    gifViewController* _gifView;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) FaceViewController* faceView;
@property (nonatomic, strong) FavoritesVC *favoritesVC;

-(void)selectType:(int)n;
@end

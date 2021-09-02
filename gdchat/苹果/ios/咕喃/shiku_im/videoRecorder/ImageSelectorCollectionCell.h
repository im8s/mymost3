//
//  ImageSelectorCollectionCell.h
//  shiku_im
//
//  Created by 1 on 17/1/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSelectorCollectionCell : UICollectionViewCell{
    NSInteger indexpath;
    JXImageView* _yellow;
}
@property (nonatomic,assign,setter=setIndex:) long index;
@property (nonatomic,assign,setter=setIsSelected:) BOOL isSelected;
@property (nonatomic,assign,setter=setDelegate:) id        delegate;
@property (nonatomic,strong) JXImageView * imageView;
@property (nonatomic,strong) JXImageView * selectView;
@property (nonatomic, assign) SEL		didImageView;
@property (nonatomic, assign) SEL		didSelectView;

-(void)refreshCellWithImagePath:(NSString *)imagePath;

@end

//
//  ImageSelectorCollectionCell.m
//  shiku_im
//
//  Created by 1 on 17/1/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "ImageSelectorCollectionCell.h"

@interface ImageSelectorCollectionCell()

@property (nonatomic,assign) NSInteger cellIndex;
@end

@implementation ImageSelectorCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customViewWithFrame:frame];
    }
    return self;
}

- (void)customViewWithFrame:(CGRect)frame{
    _imageView = [[JXImageView alloc] init];
    _imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
//    [_imageView release];

    _selectView = [[JXImageView alloc] init];
    _selectView.frame = CGRectMake(frame.size.width-33-5, 5, 33, 33);
    _selectView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_selectView];
//    [_selectView release];
}

-(void)refreshCellWithImagePath:(NSString *)imagePath{
    _yellow.didTouch = self.didImageView;
    _imageView.didTouch = self.didImageView;
    _selectView.didTouch = self.didSelectView;
    
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    if (!_imageView.image) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"Default_Gray"]];
    }
}

-(void)dealloc{
//    [super dealloc];
}

-(void)setIsSelected:(BOOL)value{
    if (value){
        _imageView.layer.borderWidth = 3;
        _imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
        _selectView.image = [UIImage imageNamed:@"selected_true"];
    }
    else{
        _imageView.layer.borderWidth = 0;
        _selectView.image = [UIImage imageNamed:@"selected_fause"];
    }
}

-(void)setDelegate:(id)value{
    _delegate = value;
    
    _selectView.delegate = _delegate;
    _imageView.delegate = _delegate;
    _yellow.delegate = _delegate;
}

-(void)setIndex:(long)value{
    _index = value;
    
    _selectView.tag = _index;
    _imageView.tag = _index;
    _yellow.tag = _index;
}

@end

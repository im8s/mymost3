//
//  JXShareFileTableViewCell.h
//  shiku_im
//
//  Created by 1 on 17/7/6.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXShareFileObject;

@interface JXShareFileTableViewCell : UITableViewCell


@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * fileTitleLabel;
@property (strong, nonatomic) UILabel * sizeLabel;
@property (strong, nonatomic) UILabel * fromLabel;
@property (strong, nonatomic) JXLabel * fromUserLabel;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UIImageView * didDownView;
@property (strong, nonatomic) UIProgressView * progressView;
@property (strong, nonatomic) UIButton * downloadStateBtn;

@property (strong, nonatomic) JXShareFileObject *shareFile;

-(void)setShareFileListCellWith:(JXShareFileObject *)shareFileObjcet indexPath:(NSIndexPath *) indexPath;
@end

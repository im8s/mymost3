//
//  JXNearMarkCell.h
//  shiku_im
//
//  Created by MacZ on 16/8/25.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JXPlaceMarkModel.h"

#define NEAERMAEK_CELL_HEIGHT 50

@interface JXNearMarkCell : UITableViewCell

@property (nonatomic,strong) UIImageView *markImgView;
@property (nonatomic,strong) UILabel *markName;
@property (nonatomic,strong) UILabel *markPlace;
@property (nonatomic,strong) UIImageView *selFlag;

- (void)refreshWith:(MKMapItem *)item;

- (void)refreshWithModel:(JXPlaceMarkModel *)model;

@end

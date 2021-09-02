//
//  JXTelAreaCell.h
//  shiku_im
//
//  Created by daxiong on 17/4/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TELAREA_CELL_HEIGHT 42

@interface JXTelAreaCell : UITableViewCell{
    UILabel *_countryName;
    UILabel *_areaNum;
}

@property (nonatomic,strong) UIView *bottomLine;

- (void)doRefreshWith:(NSDictionary *)dict language:(NSString *)language;

@end

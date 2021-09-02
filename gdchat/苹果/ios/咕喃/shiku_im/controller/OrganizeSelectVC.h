//
//  OrganizeSelectVC.h
//  shiku_im
//
//  Created by IMAC on 2019/8/14.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "admobViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class OrganizeSelectVC;
@protocol OrganizeSelectVCDelegate <NSObject>

- (void)selectOrganizeVC:(OrganizeSelectVC *)selectVC selectArray:(NSMutableArray *)array;

@end
@interface OrganizeSelectVC : admobViewController
@property (nonatomic,strong) NSMutableArray *seletedArray;
@property (nonatomic,weak) id<OrganizeSelectVCDelegate> delegate;
@end

NS_ASSUME_NONNULL_END

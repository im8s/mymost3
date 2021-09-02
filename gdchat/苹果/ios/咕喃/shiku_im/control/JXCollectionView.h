//
//  JXCollectionView.h
//  shiku_im
//
//  Created by MacZ on 2016/10/27.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXTableView.h"

@interface JXCollectionView : UICollectionView

- (void)showEmptyImage:(EmptyType)emptyType;
- (void)hideEmptyImage;

@end

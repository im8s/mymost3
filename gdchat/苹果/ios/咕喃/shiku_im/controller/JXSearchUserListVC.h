//
//  JXSearchUserListVC.h
//  shiku_im
//
//  Created by p on 2018/4/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "admobViewController.h"

@interface JXSearchUserListVC : JXTableViewController

@property (nonatomic,strong)searchData *search;
@property (nonatomic, assign) BOOL isUserSearch;  // 是否搜索好友  YES：好友搜索  NO：公众号搜索
@property (nonatomic, strong) NSString *keyWorld;  // 搜索关键字

@end

//
//  JXAddressBookVC.h
//  shiku_im
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXTableViewController.h"

@interface JXAddressBookVC : JXTableViewController

@property(nonatomic,strong)NSMutableArray *array;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong)NSMutableArray *abUreadArr;

@end

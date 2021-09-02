//
//  MJRefreshConst.h
//  MJRefresh
//
//  Created by mj on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#ifdef DEBUG
//#define MJLog(...) NSLog(__VA_ARGS__)
#else
#define MJLog(...)
#endif

// 文字颜色
#define MJRefreshLabelTextColor [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]

extern const CGFloat MJRefreshViewHeight;
extern const CGFloat MJRefreshAnimationDuration;

extern NSString *const MJRefreshBundleName;
#define kSrcName(file) [MJRefreshBundleName stringByAppendingPathComponent:file]

#define MJRefreshFooterPullToRefresh Localized(@"MJRefreshConst_UpLoadData")
#define MJRefreshFooterReleaseToRefresh Localized(@"MJRefreshConst_ReleseLoadData")
#define MJRefreshFooterRefreshing Localized(@"MJRefreshConst_Loading")

#define MJRefreshHeaderPullToRefresh Localized(@"MJRefreshConst_DropDown")
#define MJRefreshHeaderReleaseToRefresh Localized(@"MJRefreshConst_ReleaseRefresh")
#define MJRefreshHeaderRefreshing Localized(@"MJRefreshConst_Refreshing")
#define MJRefreshHeaderTimeKey @"MJRefreshHeaderView"

extern NSString *const MJRefreshContentOffset;
extern NSString *const MJRefreshContentSize;

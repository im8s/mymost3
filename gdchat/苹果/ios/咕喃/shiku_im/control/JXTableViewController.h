//
//  JXTableViewController.h
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "JXTableView.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"

@class JXLabel;
@class JXTableView;
@protocol JXTableViewDelegate;

@interface JXTableViewController : UIViewController<JXTableViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    BOOL _isLoading;
    //refresh一次page＋1
    int  _page;
    
    JXTableView* _table;
    
    int _tableHeight;    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    ATMHud* _wait;
//    JXTableViewController* _pSelf;
    int _oldRowCount;//翻页之前的行数
}

@property (nonatomic, strong) JXTableView* tableView;

@property(nonatomic,assign) BOOL isGotoBack;
@property(nonatomic,assign) BOOL isFreeOnClose;
@property(nonatomic,assign) BOOL isShowHeaderPull;
@property(nonatomic,assign) BOOL isShowFooterPull;
@property(nonatomic,strong) UIView *tableHeader;
@property(nonatomic,strong) UIView *tableFooter;
@property(nonatomic,assign) int heightHeader;
@property(nonatomic,assign) int heightFooter;
@property(nonatomic,strong) UIButton *footerBtnMid;
@property(nonatomic,strong) UIButton *footerBtnLeft;
@property(nonatomic,strong) UIButton *footerBtnRight;
@property(nonatomic,strong) JXLabel  *headerTitle;
@property(nonatomic,strong) MJRefreshFooterView *footer;
@property(nonatomic,strong) MJRefreshHeaderView *header;
@property (nonatomic, strong) UIButton *gotoBackBtn;

@property (nonatomic, assign) NSTimeInterval lastScrollTime;

@property (nonatomic, assign) BOOL isAutoLoad;  // 上拉自动加载
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;


-(void)setupStrings;
-(void)stopLoading;
-(void)createHeadAndFoot;
-(void)scrollToPageUp;
-(void)scrollToPageDown;
-(void)getServerData;
-(void)actionQuit;
-(void)onGotoHome;
-(void)doQuit;
-(void)actionTitle:(JXLabel*)sender;
-(void)doAutoScroll:(NSIndexPath*)indexPath;

//获取_table
- (JXTableView *)getTableView;
- (void)moveSelfViewToLeft;
- (void)resetViewFrame;
@end

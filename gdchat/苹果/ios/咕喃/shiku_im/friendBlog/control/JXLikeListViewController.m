//
//  JXLikeListViewController.m
//  shiku_im
//
//  Created by 1 on 2018/12/19.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXLikeListViewController.h"
#import "JXUserInfoVC.h"
#import "JXCell.h"

@interface JXLikeListViewController ()
@property (nonatomic, strong) NSArray *data;

@end

@implementation JXLikeListViewController

- (instancetype)init {
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        [self createHeadAndFoot];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%d%@",self.weibo.praiseCount,Localized(@"WeiboData_PerZan1")];
    if (self.weibo.praises.count > 20) {
        self.weibo.praises = [NSMutableArray arrayWithArray:[self.weibo.praises subarrayWithRange:NSMakeRange(0, 20)]];
    }
}

- (void)getServerData {
    [g_server listPraise:self.weibo.messageId pageIndex:_page pageSize:20 praiseId:nil toView:self];
}

- (void)scrollToPageDown {
    [super scrollToPageDown];
}


#pragma mark - Table view     --------代理--------     data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.weibo.praises.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"JXLikeListCell";
    JXCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    WeiboReplyData *data = self.weibo.praises[indexPath.row];
    cell.title = data.userNickName;
    cell.index = (int)indexPath.row;
    cell.delegate = self;
//    cell.didTouch = @selector(onHeadImage:);
    cell.timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH - 120-20, 9, 115, 20);
    cell.userId = data.userId;
    [cell.lbTitle setText:cell.title];
    
    [cell headImageViewImageWithUserId:nil roomId:nil];
    cell.isSmall = YES;
    [self doAutoScroll:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WeiboReplyData *data = self.weibo.praises[indexPath.row];
    JXUserInfoVC *userVC = [JXUserInfoVC alloc];
    userVC.userId = data.userId;
    userVC.fromAddType = 6;
    userVC = [userVC init];
    [g_navigation pushViewController:userVC animated:YES];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [self stopLoading];
    [g_wait stop];
    if ([aDownload.action isEqualToString:act_PraiseList]) {
        if (_page == 0) {
            [self.weibo.praises removeAllObjects];
        }
        for (int i = 0; i < array1.count; i++) {
            WeiboReplyData * reply=[[WeiboReplyData alloc]init];
            reply.type=reply_data_praise;
            [reply getDataFromDict:[array1 objectAtIndex:i]];
            [self.weibo.praises addObject:reply];
        }
        [_table reloadData];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [g_wait stop];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [g_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [g_wait start:nil];
}


@end

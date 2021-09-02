//
//  JXBlogRemindVC.m
//  shiku_im
//
//  Created by p on 2017/7/4.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXBlogRemindVC.h"
#import "JXBlogRemind.h"
#import "JXBlogRemindCell.h"
#import "WeiboViewControlle.h"

@interface JXBlogRemindVC ()

@property (nonatomic, assign) BOOL isHaveMore;

@end

@implementation JXBlogRemindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = Localized(@"JX_NewMessage");
    self.isHaveMore = YES;
    self.isGotoBack = YES;
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    [self createHeadAndFoot];
    self.isShowFooterPull = NO;
    
    CGSize size = [Localized(@"JX_Clear") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
    
    UIButton* btn = [UIFactory createButtonWithTitle:Localized(@"JX_Clear") titleFont:[UIFont systemFontOfSize:15] titleColor:[UIColor whiteColor] normal:nil highlight:nil];
    [btn setTitleColor:THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, JX_SCREEN_TOP - 30, size.width, 15);
    [self.tableHeader addSubview:btn];
    
    if (self.isShowAll) {
        self.remindArray = [[JXBlogRemind sharedInstance] doFetch];
        self.isHaveMore = NO;
        [_table reloadData];
    }
    
    [g_notify addObserver:self selector:@selector(remindNotif:) name:kXMPPMessageWeiboRemind object:nil];
}

- (void) remindNotif:(NSNotification *)notif {

    _remindArray = [[JXBlogRemind sharedInstance] doFetchUnread];

    [_table reloadData];
}

- (void) onClear {
    [[JXBlogRemind sharedInstance] deleteAllMsg];
    [self.remindArray removeAllObjects];
    self.isHaveMore = NO;
    [_table reloadData];
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.remindArray.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellName"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
        label.textColor = [UIColor grayColor];
        label.font = g_factory.font14;
        label.text = Localized(@"JX_GetPreviousMessage");
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
        return cell;
    }
    
    NSString* cellName = [NSString stringWithFormat:@"JXBlogRemindCell"];
    
    JXBlogRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell==nil){
        cell = [[JXBlogRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];;
    }
    
    JXBlogRemind *br = self.remindArray[indexPath.row];
    [cell doRefresh:br];
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isHaveMore) {
        return self.remindArray.count + 1;
    }else {
        return self.remindArray.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.remindArray.count) {
        return 85;
    }
    
    JXBlogRemind *br = self.remindArray[indexPath.row];
    NSString *content = br.content;
    if (br.toUserName.length > 0)
        content = [NSString stringWithFormat:@"%@%@: %@", Localized(@"JX_Reply"),br.toUserName, br.content];
    CGSize size = [content boundingRectWithSize:CGSizeMake(JX_SCREEN_WIDTH - 60 - 10 - 85, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(15)} context:nil].size;
    if (size.height > 20) {
        return 85 - 20 + size.height;
    }
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.remindArray.count) {
        self.remindArray = [[JXBlogRemind sharedInstance] doFetch];
        self.isHaveMore = NO;
        [_table reloadData];
        
        return;
    }
    
    JXBlogRemind *br = self.remindArray[indexPath.row];
    
    WeiboViewControlle *weibo = [WeiboViewControlle alloc];
    weibo.detailMsgId = br.objectId;
    weibo.isDetail = YES;
    weibo = [weibo init];
//    [g_window addSubview:weibo.view];
    [g_navigation pushViewController:weibo animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

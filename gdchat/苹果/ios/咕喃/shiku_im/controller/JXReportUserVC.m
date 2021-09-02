//
//  JXReportUserVC.m
//  shiku_im
//
//  Created by 1 on 17/6/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXReportUserVC.h"

@interface JXReportUserVC ()<UITextViewDelegate, UIAlertViewDelegate>
@property (nonatomic,strong) UITextView * reasonView;
@property (nonatomic,strong) UILabel * placeLabel;
@property (nonatomic, strong) NSArray *array;

@property (nonatomic, strong) NSDictionary *currentReason;

@end

@implementation JXReportUserVC

-(instancetype)init{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        
        self.isGotoBack = YES;
        self.title = Localized(@"JXUserInfoVC_Report");
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.isShowHeaderPull = NO;
    self.isShowFooterPull = NO;
    if ([self.user.roomFlag intValue] > 0  || self.user.roomId.length > 0) {
        _array = @[
                   @{@"reasonId":@200, @"reasonStr":Localized(@"JX_HaveGamblingBehavior")},
                   @{@"reasonId":@210, @"reasonStr":Localized(@"JX_CheatedMoney")},
                   @{@"reasonId":@220, @"reasonStr":Localized(@"JX_Harassment")},
                   @{@"reasonId":@230, @"reasonStr":Localized(@"JX_SpreadRumors")}
                   ];
    }
    else if (self.isUrl) {
        _array = @[
                   @{@"reasonId":@300, @"reasonStr":Localized(@"JX_WebPagesContainFraudulentInformation")},
                   @{@"reasonId":@301, @"reasonStr":Localized(@"JX_WebPagesContainPornographicInformation")},
                   @{@"reasonId":@302, @"reasonStr":Localized(@"JX_WebPagesContainViolentTerrorInformation")},
                   @{@"reasonId":@303, @"reasonStr":Localized(@"JX_WebPagesContainPoliticallySensitiveInformation")},
                   @{@"reasonId":@304, @"reasonStr":Localized(@"JX_WebPagesAreIncludedInCollectingPersonalPrivacyInformation")},
                   @{@"reasonId":@305, @"reasonStr":Localized(@"JX_WebPagesContainContentThatInducesSharing/attention")},
                   @{@"reasonId":@306, @"reasonStr":Localized(@"JX_WebPagesMayContainRumorInformation")},
                   @{@"reasonId":@307, @"reasonStr":Localized(@"JX_PageContainsGamblingInformation")},
                   ];
    }
    else {
        _array = @[
                   @{@"reasonId":@100, @"reasonStr":Localized(@"JX_InappropriateContent")},
                   @{@"reasonId":@101, @"reasonStr":Localized(@"JX_Pornography")},
                   @{@"reasonId":@102, @"reasonStr":Localized(@"JX_Posting_illegal")},
                   @{@"reasonId":@103, @"reasonStr":Localized(@"JX_Gambling")},
                   @{@"reasonId":@104, @"reasonStr":Localized(@"JX_PoliticalRumors")},
                   @{@"reasonId":@105, @"reasonStr":Localized(@"JX_Nuisance")},
                   @{@"reasonId":@106, @"reasonStr":Localized(@"JX_Other_illegal_content")},
                   @{@"reasonId":@120, @"reasonStr":Localized(@"JX_FraudToCheatMoney")},
                   @{@"reasonId":@130, @"reasonStr":Localized(@"JX_HaveBeenStolen")},
                   @{@"reasonId":@140, @"reasonStr":Localized(@"JX_Infringement")},
                   @{@"reasonId":@150, @"reasonStr":Localized(@"JX_ReleaseCounterfeitInformation")},
                   ];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}


#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reportCell"];
        
        
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-15-7, (50-13)/2, 7, 13)];
        iv.image = [UIImage imageNamed:@"new_icon_>"];
        [cell.contentView addSubview:iv];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 49.5, JX_SCREEN_WIDTH, LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [cell.contentView addSubview:line];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 25-8, JX_SCREEN_WIDTH-15 - 7- 5 - 10, 16)];
        label.tag = 100;
        label.font = SYSFONT(16);
        label.textColor = HEXCOLOR(0x333333);
        [cell.contentView addSubview:label];

    }
    UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:100];
    NSDictionary *dict = _array[indexPath.row];
    titleLabel.text = dict[@"reasonStr"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = _array[indexPath.row];
    _currentReason = dict;
    
    [g_App showAlert:Localized(@"JX_ConfirmReportInformation") delegate:self tag:2457 onlyConfirm:NO];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(report:reasonId:)]) {
            [_delegate report:_user reasonId:_currentReason[@"reasonId"]];
            if (self.isUrl) {
                [self.view removeFromSuperview];
            }else {
                [self actionQuit];
            }
        }
    }
}

//-(void)report{
//    if (_reasonView.text.length <= 0) {
//        [g_App showAlert:Localized(@"JX_ContentEmpty")];
//        return;
//    }
//    if (_delegate && [_delegate respondsToSelector:@selector(report:text:)]) {
//        [_delegate report:_user text:_reasonView.text];
//        [self actionQuit];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView{
    _placeLabel.hidden = YES;
}

@end

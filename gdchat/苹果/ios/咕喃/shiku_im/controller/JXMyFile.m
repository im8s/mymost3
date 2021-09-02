//
//  JXMyFile.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXMyFile.h"
//#import "JXChatViewController.h"
//#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
//#import "JXCell.h"
//#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "QCheckBox.h"
//#import "XMPPRoom.h"
//#import "JXRoomObject.h"
#import "FileListCell.h"

@interface JXMyFile ()

@end

@implementation JXMyFile

- (id)init
{
    self = [super init];
    if (self) {
        self.title = Localized(@"JXMyFileVC_SelFile");
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
        //self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        self.isShowFooterPull = NO;
        _selMenu = 0;
        
        //添加文件的确定按钮，无用
//        UIButton* _btn;
//        _btn = [UIFactory createCommonButton:@"确定" target:self action:@selector(onAdd)];
//        _btn.frame = CGRectMake(JX_SCREEN_WIDTH - 70, 20+10, 60, 24);
//        [self.tableHeader addSubview:_btn];
    }
    return self;
}


- (void)onAdd{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array=[[NSMutableArray alloc] init];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListCell *cell=nil;
//    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%d",_refreshCount,indexPath.row];
    NSString* cellName = [NSString stringWithFormat:@"FileListCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
//        cell = [FileListCell alloc];
//        cell.bottomTitle = [TimeUtil formatDate:user.timeCreate format:@"MM-dd HH:mm"];
        cell = [[NSBundle mainBundle] loadNibNamed:@"FileListCell" owner:self options:nil][0];
    }
    NSString *s=_array[indexPath.row];
    
    [_table addToPool:cell];
    cell.title.text = [s lastPathComponent];
    cell.subtitle.text = [s pathExtension];
    cell.headImage.image = [UIImage imageNamed:@"im_file_button_normal"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSString *s=_array[indexPath.row];
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelect])
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:s waitUntilDone:NO];
    
    [self actionQuit];
//    _pSelf = nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [cell retain];
    [_table delFromPool:cell];
}

- (void)dealloc {
    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}
//读到聊天记录里面的图片
-(void)getArrayData{
    //获取路径下的所有文件
    _array=[FileInfo getFiles:myTempFilePath];
}

-(void)refresh{
    [self stopLoading];
    _refreshCount++;
    [_array removeAllObjects];
//    [_array release];
    [self getArrayData];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)scrollToPageUp{
    [self refresh];
}

@end

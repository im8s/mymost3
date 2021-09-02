
//
//  selectTreeVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "selectTreeVC.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
//#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "JXConstant.h"
#import "selectValueVC.h"

#define row_height 40

@interface selectTreeVC ()

@end

@implementation selectTreeVC
@synthesize parentId,parentName;
@synthesize selected;
@synthesize delegate;
@synthesize didSelect;
@synthesize selValue;
@synthesize selNumber;

- (id)init
{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.isShowFooterPull = NO;
        self.isShowHeaderPull = NO;
        
        _table.backgroundColor = [UIColor whiteColor];
        
        _ids = [[NSMutableArray alloc]init];
        _names = [[NSMutableArray alloc]init];
        _selIds = [[NSMutableArray alloc]init];
        _selNames = [[NSMutableArray alloc]init];
        _typeIds = [[NSMutableArray alloc]init];
        _typeNames = [[NSMutableArray alloc]init];
        
        [g_constant getNameValues:parentId name:_typeNames value:_typeIds];
        for(int i=0;i<[_typeIds count];i++){
            NSMutableArray* p1 = [[NSMutableArray alloc]init];
            NSMutableArray* p2 = [[NSMutableArray alloc]init];
            int n = [[_typeIds objectAtIndex:i] intValue];
//            NSLog(@"%d",n);
            [g_constant getNameValues:n name:p1 value:p2];
            [_names addObject:p1];
            [_ids addObject:p2];
//            [p1 release];
//            [p2 release];
        }
    }
    return self;
}

- (void)dealloc {
    [_ids removeAllObjects];
    [_names removeAllObjects];
    [_typeIds removeAllObjects];
    [_typeNames removeAllObjects];
    [_selIds removeAllObjects];
    [_selNames removeAllObjects];

    self.parentName = nil;
    self.selValue = nil;
    self.selNames = nil;
    self.selIds = nil;
    
//    [_ids release];
//    [_names release];
//    [_typeIds release];
//    [_typeNames release];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return [_typeNames count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* p = [_names objectAtIndex:section];
    return [p count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, row_height)];
    v.backgroundColor = [UIColor grayColor];
    v.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
    p.text = [_typeNames objectAtIndex:section];
    p.font = g_factory.font15;
    p.textColor = [UIColor grayColor];
    [v addSubview:p];
//    [p release];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0,row_height-LINE_WH,JX_SCREEN_WIDTH,LINE_WH)];
    line.backgroundColor = THE_LINE_COLOR;
    [v addSubview:line];
//    [line release];
    
    [_table addToPool:v];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld_%ld",_refreshCount,indexPath.row,indexPath.section];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        cell = [UITableViewCell alloc];
        [_table addToPool:cell];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
        p.font = g_factory.font15;
        [cell addSubview:p];
//        [p release];

        NSArray* a = [_names objectAtIndex:indexPath.section];
        p.text = [a objectAtIndex:indexPath.row];
        a = nil;

        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(18,row_height-LINE_WH,300,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [cell addSubview:line];
//        [line release];
        
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_flag"]];
        iv.frame = CGRectMake(JX_SCREEN_WIDTH-20, (row_height-13)/2, 7, 13);
        [cell addSubview:iv];
//        [iv release];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if(self.hasSubtree){
        [_selNames removeAllObjects];
        [_selIds removeAllObjects];
        
        int n = [[[_ids objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
        [g_constant getNameValues:n name:_selNames value:_selIds];
        
        selectValueVC* vc = [selectValueVC alloc];
        vc.values = _selNames;
        vc.selNumber = selNumber;
        vc.numbers   = _selIds;
        vc.didSelect = @selector(doSelect:);
        vc.delegate = self;
        vc.quickSelect = YES;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
    }else{
        self.selected = (int)indexPath.row;
        
        NSArray* a = [_names objectAtIndex:indexPath.section];
        self.selValue = [a objectAtIndex:indexPath.row];
        
        a = [_ids objectAtIndex:indexPath.section];
        self.selNumber = [[a objectAtIndex:indexPath.row] intValue];
        
//        NSLog(@"选中%@,%d",self.selValue,self.selected);
        if (delegate && [delegate respondsToSelector:didSelect])
//            [delegate performSelector:didSelect withObject:self];
            [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
        [self actionQuit];
    }
    return;
}

-(void)doSelect:(selectValueVC*)sender{
    self.selValue = sender.selValue;
    self.selected = sender.selected;
    self.selNumber = sender.selNumber;

//    NSLog(@"选中%@,%d,%d",self.selValue,self.selected,selNumber);
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    [self actionQuit];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return row_height;
}

@end

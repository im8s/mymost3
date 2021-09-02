//
//  JXReadListVC.m
//  shiku_im
//
//  Created by p on 2017/9/2.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXReadListVC.h"
#import "JXReadListCell.h"

@interface JXReadListVC ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation JXReadListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM);
    [self createHeadAndFoot];
    
    self.title = Localized(@"JX_ReadList");
    _array = [NSMutableArray array];

    
    [self getLocData];
}

- (void) getLocData {
    _array = [self.msg fetchReadList];

    
    [self.tableView reloadData];
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    NSString* cellName = [NSString stringWithFormat:@"readListCell"];
    JXReadListCell *readListCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!readListCell) {
        readListCell = [[JXReadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    readListCell.room = _room;
    JXUserObject * obj = _array[indexPath.row];
    [readListCell setData:obj];
    
    return readListCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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

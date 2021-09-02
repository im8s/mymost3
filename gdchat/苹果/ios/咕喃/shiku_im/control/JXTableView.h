//
//  JXTableView.h
//  shiku_im
//
//  Created by flyeagleTang on 14-5-27.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JXTableViewDelegate <NSObject>
@optional

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end


typedef enum : NSUInteger {
    EmptyTypeNoData,
    EmptyTypeNetWorkError,
    EmptyTypeNoMsg,
} EmptyType;

@interface  JXTableView : UITableView
{
    UILabel *_tipLabel;
    UIButton *_tipBtn;
@private
//    id _touchDelegate;
    NSMutableArray* _pool;
}

@property (nonatomic,weak) id<JXTableViewDelegate> touchDelegate;
@property (nonatomic,strong) UIImageView *empty;

- (void)gotoLastRow:(BOOL)animated;
- (void)gotoFirstRow:(BOOL)animated;
- (void)gotoRow:(int)n;

- (void)showEmptyImage:(EmptyType)emptyType;
- (void)hideEmptyImage;
- (void)onAfterLoad;

-(void)addToPool:(id)p;
-(void)delFromPool:(id)p;
//-(void)clearPool:(BOOL)delObj;

-(void)reloadRow:(int)n section:(int)section;//刷新一行
-(void)insertRow:(int)n section:(int)section;//增加一行
-(void)deleteRow:(int)n section:(int)section;//删除一行
@end

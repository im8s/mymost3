//
//  JXTopSiftJobView.m
//  shiku_im
//
//  Created by MacZ on 16/5/19.
//  Copyright (c) 2016年 Reese. All rights reserved.
//

#import "JXTopSiftJobView.h"

#define ITEMBTN_WIDTH (self.frame.size.width-50)/3
#define ITEMBTN_HEIGHT 40

@interface JXTopSiftJobView (){
    CGFloat _moreParaBtnWidth;
}
@property (nonatomic, assign) CGFloat itemBtnWidth;

@property (nonatomic, strong) NSMutableArray * btnArray;

@end

@implementation JXTopSiftJobView

- (void)dealloc
{
//    [_dataArray release];
    _dataArray = nil;
//    [_paraDataArray release];
    _paraDataArray = nil;
    
    _btnArray = nil;
    
//    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    if(_dataArray != dataArray){
        _dataArray = dataArray;
        _btnArray = [[NSMutableArray alloc] init];
        
        if (self.isShowMoreParaBtn) {
            //更多筛选条件按钮
            UIButton *moreParaBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 0, 50, ITEMBTN_HEIGHT)];
            [moreParaBtn setImage:[UIImage imageNamed:@"ic_filter_display"] forState:UIControlStateNormal];
            [moreParaBtn addTarget:self action:@selector(moreParaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moreParaBtn];
            
            UIView *leftVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(0,0,LINE_WH,ITEMBTN_HEIGHT)];
            leftVerticalLine.backgroundColor = THE_LINE_COLOR;
            [moreParaBtn addSubview:leftVerticalLine];
        }
        
        self.itemBtnWidth = 0;
        if (self.isShowMoreParaBtn) {
            self.itemBtnWidth = (self.frame.size.width-50)/self.dataArray.count;
        }else {
            self.itemBtnWidth = self.frame.size.width / self.dataArray.count;
        }
        
        [_btnArray removeAllObjects];
        for (int i=0; i<_dataArray.count; i++) {
            UIButton *itemBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.itemBtnWidth*i, 0, self.itemBtnWidth, ITEMBTN_HEIGHT)];
            itemBtn.tag = i+100;
            [itemBtn setTitle:_dataArray[i] forState:UIControlStateNormal];
            itemBtn.titleLabel.font = SYSFONT(16);
            [itemBtn setTitleColor:self.titleNormalColor ? self.titleNormalColor : [UIColor lightGrayColor] forState:UIControlStateNormal];
            [itemBtn setTitleColor:self.titleSelectedColor ? self.titleSelectedColor : [UIColor grayColor] forState:UIControlStateSelected];
            [itemBtn addTarget:self action:@selector(itemBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:itemBtn];
            [_btnArray addObject:itemBtn];
            if (i == _preferred) {
                itemBtn.selected = YES;
            }
        }
        
        if (self.isShowBottomLine) {
            //底部滑动线条
            _bottomSlideLine = [[UIView alloc] initWithFrame:CGRectMake(0, ITEMBTN_HEIGHT-2, self.itemBtnWidth, 2)];
            _bottomSlideLine.backgroundColor = THEMECOLOR;
            [self addSubview:_bottomSlideLine];
        }
        
        [self resetBottomLineIndex:_preferred];
        
    }
}
-(void)setPreferred:(NSUInteger)preferred{
    if(_preferred != preferred){
        _preferred = preferred;
    }
}

- (void)moveBottomSlideLine:(CGFloat)offsetX{
    CGRect frame = _bottomSlideLine.frame;
    frame.origin.x = offsetX/(JX_SCREEN_WIDTH*2)*self.itemBtnWidth*2;
    _bottomSlideLine.frame = frame;
}

- (void)resetBottomLineIndex:(NSUInteger)index{
    if (index >= _dataArray.count) {
        return;
    }
    UIButton * btn = _btnArray[index];
    CGRect frame = _bottomSlideLine.frame;
    frame.origin.x = btn.frame.origin.x;
    _bottomSlideLine.frame = frame;
    
    for (UIButton * button in _btnArray) {
        button.selected = NO;
    }
    btn.selected = YES;
    
    
}

- (void)itemBtnClick:(UIButton *)btn{
    if (btn.selected) {  //重复点击按钮
        return;
    }else{
        [self.delegate performSelector:@selector(topItemBtnClick:) withObject:btn];
    }
    
    for (UIView *view in self.subviews) {
        if (view.tag >=100 && view.tag <= 102) {
            UIButton *tempBtn = (UIButton *)view;
            if (tempBtn.tag == btn.tag) {
                tempBtn.selected = YES;
            }else{
                tempBtn.selected = NO;
            }
        }
    }
    
    //移动底部线条
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _bottomSlideLine.frame;
        frame.origin.x = btn.frame.origin.x;
        _bottomSlideLine.frame = frame;
    }];
}

//显示更多筛选条件
- (void)moreParaBtnClick:(UIButton *)btn{
    if (_moreParaView == nil) {
        [self initMoreParaView];
    }
    
    [self showMoreParaView:YES];
}

//初始化更多筛选条件面板
- (void)initMoreParaView{
    
}

- (void)hideMoreParaBtnClick:(UIButton *)btn{
    [self showMoreParaView:NO];
}

//条件按钮点击
- (void)paraItemBtnClick:(UIButton *)btn{
    [UIView animateWithDuration:0.5 animations:^{
        btn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
    _paraSelIndex = btn.tag;
    
    [self.delegate performSelector:@selector(paraItemBtnClick:) withObject:btn];
}

//显示、隐藏更多筛选条件面板
- (void)showMoreParaView:(BOOL)show{
    CGRect frame = _moreParaView.frame;
    if (show) {
        frame.origin.x = 0;
    }else{
        frame.origin.x = self.frame.size.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _moreParaView.frame = frame;
    }];
}

//scrollView滑动结束，改变顶部item按钮选中状态
- (void)resetItemBtnWith:(CGFloat)offsetX{
    for (UIView *view in self.subviews) {
        if (view.tag >= 100 && view.tag <= 102) {
            UIButton *btn = (UIButton *)view;
            if (view.tag == offsetX/JX_SCREEN_WIDTH+100) {
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }
        }
    }
}

//重置选中的参数按钮状态
- (void)resetSelParaBtnTransform{
    for (UIView *view in _moreParaView.subviews) {
        if (view.tag == _paraSelIndex) {
            UIButton *btn = (UIButton *)view;
            btn.imageView.transform = CGAffineTransformIdentity;
        }
    }
}

//选中某个筛选条件后改变按钮文案
- (void)resetWithIndex:(NSInteger)index itemId:(int)itemId itemValue:(NSString *)value{
    for (UIView *view in _moreParaView.subviews) {
        if (view.tag == index) {
            UIButton *btn = (UIButton *)view;
            if (itemId == 0) {
                [btn setTitle:Localized(@"JXTopSiftJobView_Default") forState:UIControlStateNormal];
                btn.selected = NO;
            }else{
                [btn setTitle:value forState:UIControlStateNormal];
                btn.selected = YES;
            }
            
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width, 0, -btn.titleLabel.frame.size.width)];
        }
    }
}

//选中薪水筛选条件后改变按钮文案
- (void)resetWithIndex:(NSInteger)index min:(NSInteger)min max:(NSInteger)max{
    for (UIView *view in _moreParaView.subviews) {
        if (view.tag == index) {
            UIButton *btn = (UIButton *)view;
            if (min == 0 && max == 0) {
                [btn setTitle:Localized(@"JXTopSiftJobView_FaceToFace") forState:UIControlStateNormal];
                btn.selected = NO;
            }else{
                if (min >= 1000 && max >= 1000) {
                    min = min/1000;
                    max = max/1000;
                    [btn setTitle:[NSString stringWithFormat:@"%ldk-%ldk",min,max] forState:UIControlStateNormal];
                }else{
                    [btn setTitle:[NSString stringWithFormat:@"%ld-%ld",min,max] forState:UIControlStateNormal];
                }
                btn.selected = YES;
            }
            
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width, 0, -btn.titleLabel.frame.size.width)];
        }
    }
}

- (void)resetAllParaBtn{
    for (UIView *view in _moreParaView.subviews) {
        if (view.tag >= 200 && view.tag <= 202) {
            UIButton *btn = (UIButton *)view;
            btn.imageView.transform = CGAffineTransformIdentity;
            btn.selected = NO;
            [btn setTitle:[_paraDataArray objectAtIndex:btn.tag-200] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width, 0, -btn.titleLabel.frame.size.width)];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

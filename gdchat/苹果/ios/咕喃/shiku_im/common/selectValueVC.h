//
//  selectValueVC.h
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "admobViewController.h"

@protocol JXServerResult;

@interface selectValueVC : admobViewController{
    int h1;
}
-(void)getValuesfromArray:(NSArray*)a name:(NSString*)name;
@property(nonatomic,strong) NSMutableArray* values;
@property(nonatomic,strong) NSMutableArray* numbers;
@property(nonatomic,assign) int selected;//选中的索引号
@property(nonatomic,strong) NSString* selValue;//选中的字符串
@property(nonatomic,assign) int selNumber;//选中的数值
@property(nonatomic,weak) id delegate;
@property(assign) SEL didSelect;
@property(assign) BOOL quickSelect;//是否快速选择,不需要完成按钮
@end

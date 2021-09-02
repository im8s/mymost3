//
//  SkinManage.h
//  shiku_im
//
//  Created by 1 on 17/10/23.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SkinType_PeaGreen  =   0,  //浅豆绿
    SkinType_ClearBlue,        //清水蓝
    SkinType_CoralRed,         //珊瑚红
    SkinType_NephelinePowder,  //流霞粉
    SkinType_CobaltPaleGreen,  //默认淡钴绿
    SkinType_DarkPurple,       //葡萄紫
    SkinType_BusinessBlue,     //商务蓝
    SkinType_ComposedRed,      //经典红
    
//    SkinType_simple_Red,      //极简红
//    SkinType_simple_Blue,     //极简蓝
//    SkinType_simple_Pink,     //极简粉
//    SkinType_Green,           //淡钴绿
//    SkinType_LeafGreen,       //粉叶绿
//    SkinType_PowderAzure,     //粉天蓝
//    SkinType_BusinessBlue,    //商务蓝
//    SkinType_Blue,            //大海蓝
//    SkinType_Pink,            //感性粉
//    SkinType_Red,             //中国红
//    SkinType_AmberYellow,     //琥珀黄
//    SkinType_Orange,          //橘黄色
//    SkinType_LightCoffee,     //浅咖色
//    SkinType_BlueGray,        //蓝灰色
//    SkinType_BurntUmber,      //深茶色
} SkinType;

typedef NSString * SkinDictKey NS_STRING_ENUM;
extern SkinDictKey const SkinDictKeyName;
extern SkinDictKey const SkinDictKeyColor;
extern SkinDictKey const SkinDictKeyIndex;

@interface SkinManage : NSObject

/**
 主题皮肤颜色
 */
@property (readonly, nonatomic, strong) UIColor * themeColor;

/**
 主题皮肤名称
 */
@property (readonly, nonatomic, copy) NSString * themeName;

/**
 主题皮肤索引
 */
@property (readonly, nonatomic, assign) NSUInteger themeIndex;

/**
 主题列表
 */
@property (readonly, nonatomic, strong) NSArray<NSDictionary<SkinDictKey,id> *> * skinList;

/**
 主题皮肤名列表
 */
@property (readonly, nonatomic, strong) NSArray<NSString *> * skinNameList;

/**
 skin管理器单例对象

 @return skinManage
 */
+(instancetype)sharedInstance;

/**
 切换主题皮肤

 @param index 皮肤主题的索引type
 */
-(void)switchSkinIndex:(NSUInteger)index;

/**
 主题皮肤image对象

 @param imageName 图片文件名
 @return 主题皮肤图片
 */
-(UIImage *)themeImage:(NSString *)imageName;

/**
 图片名转换为当前主题皮肤的图片名
 eg. ic_find@2x ->ic_find_2@2x
 @param imageName 图片文件名
 @return 主题皮肤图片名
 */
-(NSString *)themeImageName:(NSString *)imageName;

/**
 生成主题色的图片

 @param imageName 图片文件名
 @return 渲染过的图片
 */
-(UIImage *)themeTintImage:(NSString *)imageName;

// 重置
-(void)resetInstence;

@end

//
//  SkinManage.m
//  shiku_im
//
//  Created by 1 on 17/10/23.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "SkinManage.h"
#import "UIImage+Tint.h"

//#define skinName    @"skinName"
//#define skinColor   @"skinColor"
//#define skinIndex   @"skinIndex"

SkinDictKey const SkinDictKeyName    = @"skinName";
SkinDictKey const SkinDictKeyColor   = @"skinColor";
SkinDictKey const SkinDictKeyIndex   = @"skinIndex";

static SkinManage * _shareInstance = nil;

@interface SkinManage ()

@property (nonatomic, strong) UIImage *navImage;

@end

@implementation SkinManage

+(instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[SkinManage alloc] init];
    });
    return _shareInstance;
}

-(instancetype)init{
    if (self = [super init]) {
        [self makeThemeList];
        
        NSNumber * current = [g_default objectForKey:SkinDictKeyIndex];
        if (current == nil) {
            [g_default setObject:[NSNumber numberWithUnsignedInteger:SkinType_BusinessBlue] forKey:SkinDictKeyIndex];
            [g_default synchronize];
            current = [NSNumber numberWithUnsignedInteger:SkinType_BusinessBlue];
        }
        
        NSDictionary * skinDict = [self searchSkinByIndex:[current unsignedIntegerValue]];
        if(skinDict){
            _themeName = skinDict[SkinDictKeyName];
            _themeColor = skinDict[SkinDictKeyColor];
            _themeIndex = [skinDict[SkinDictKeyIndex] unsignedIntegerValue];
        }
        
    }
    return self;
}

-(void)makeThemeList{
    NSMutableArray * skinList = [NSMutableArray array];

    // 以前的黑色 0x4FC557
    // 极简风格
    [skinList addObject:[self makeASkin:Localized(@"JX_LightBeanGreen") color:HEXCOLOR(0x61D999) index:SkinType_PeaGreen]];//浅豆绿
    [skinList addObject:[self makeASkin:Localized(@"JX_ClearWaterBlue") color:HEXCOLOR(0x80BFFF) index:SkinType_ClearBlue]];//清水蓝
    [skinList addObject:[self makeASkin:Localized(@"JX_CoralRed") color:HEXCOLOR(0xFF8080) index:SkinType_CoralRed]];//珊瑚红
    [skinList addObject:[self makeASkin:Localized(@"JX_LiuxiaPowder") color:HEXCOLOR(0xFFA5C9) index:SkinType_NephelinePowder]];//流霞粉
    
    //普通风格
    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_ViridianGreen") color:HEXCOLOR(0x55BEB7) index:SkinType_CobaltPaleGreen]];//淡钴绿 默认
    [skinList addObject:[self makeASkin:Localized(@"JX_GrapePurple") color:HEXCOLOR(0x6C53AB) index:SkinType_DarkPurple]];//葡萄紫
    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_BusinessBlue") color:RGB(55, 137, 250) index:SkinType_BusinessBlue]];//商务蓝
    [skinList addObject:[self makeASkin:Localized(@"JX_ClassicRed") color:HEXCOLOR(0xfd504e) index:SkinType_ComposedRed]];//经典红

    
    
    
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_LeafGreen") color:HEXCOLOR(0xBAE019) index:SkinType_LeafGreen]];//粉叶绿
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_PowderAzure") color:HEXCOLOR(0x7ED1FB) index:SkinType_PowderAzure]];//粉天蓝
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_BusinessBlue") color:HEXCOLOR(0x3C589B) index:SkinType_BusinessBlue]];//商务蓝
//    [skinList addObject:[self makeASkin:Localized(@"JXTheme_Blue") color:HEXCOLOR(0x099fde) index:SkinType_Blue]];//大海蓝
//    [skinList addObject:[self makeASkin:Localized(@"JXTheme_Pink") color:HEXCOLOR(0xFA99A0) index:SkinType_Pink]];//感性粉
//    [skinList addObject:[self makeASkin:Localized(@"JXTheme_Red") color:HEXCOLOR(0xDE3031) index:SkinType_Red]];//中国红
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_AmberYellow") color:HEXCOLOR(0xFFC400) index:SkinType_AmberYellow]];// 琥珀黄
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_Orange") color:HEXCOLOR(0xFE7B21) index:SkinType_Orange]];//橘黄色
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_LightCoffee") color:HEXCOLOR(0xC17E61) index:SkinType_LightCoffee]];//浅咖色
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_BlueGray") color:HEXCOLOR(0x547A8C) index:SkinType_BlueGray]];//蓝灰色
//    [skinList addObject:[self makeASkin:Localized(@"JX_Theme_BurntUmber") color:HEXCOLOR(0x4E2505) index:SkinType_BurntUmber]];//深茶色
    // 粉色替换了，这是之前的粉色:0xff9ffe
    NSMutableArray * skinNameList = [NSMutableArray array];
    for (NSDictionary * skinDict in skinList) {
        [skinNameList addObject:skinDict[SkinDictKeyName]];
    }
    
    _skinNameList = skinNameList;
    _skinList = skinList;
}

-(NSDictionary *)makeASkin:(NSString *)name color:(UIColor *)color index:(SkinType)skinType{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:SkinDictKeyName];
    [dict setObject:color forKey:SkinDictKeyColor];
    [dict setObject:[NSNumber numberWithUnsignedInteger:skinType] forKey:SkinDictKeyIndex];
    
    return dict;
}

-(NSDictionary *)searchSkinByIndex:(NSInteger)index{
    for (int i = 0; i<_skinList.count; i++) {
        NSDictionary * skinDict = _skinList[i];
        if ([skinDict[SkinDictKeyIndex] unsignedIntegerValue] == index) {
            
            return skinDict;
        }
    }
    return nil;
}


-(void)switchSkinIndex:(NSUInteger)index{
    NSDictionary * skinDict = [self searchSkinByIndex:index];
    if(skinDict){
        _themeName = skinDict[SkinDictKeyName];
        _themeColor = skinDict[SkinDictKeyColor];
        _themeIndex = [skinDict[SkinDictKeyIndex] unsignedIntegerValue];
        self.navImage = nil;
        [g_default setObject:[NSNumber numberWithUnsignedInteger:_themeIndex] forKey:SkinDictKeyIndex];
        [g_default synchronize];
    }
}

-(UIImage *)themeImage:(NSString *)imageName{
    NSString * imageStr = [imageName copy];
    if ([imageName rangeOfString:@"@2x"].location != NSNotFound) {
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }else if ([imageName rangeOfString:@"@3x"].location != NSNotFound){
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
    }
    
    if(_themeIndex != 0){
        imageStr = [NSString stringWithFormat:@"%@_%tu",imageStr,_themeIndex];
    }
    UIImage * img = [UIImage imageNamed:imageStr];
    if (img) {
        return img;
    }else{
        return [UIImage imageNamed:imageName];
    }
        
}

-(NSString *)themeImageName:(NSString *)imageName{
    NSString * imageStr;
    if ([imageName rangeOfString:@"@2x"].location != NSNotFound) {
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }else if ([imageName rangeOfString:@"@3x"].location != NSNotFound){
        imageStr = [imageName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
    }
    
    imageStr = [NSString stringWithFormat:@"%@_%tu",imageStr,_themeIndex];
   
    return imageStr;
}

-(UIImage *)themeTintImage:(NSString *)imageName{
    
    if ([imageName isEqualToString:@"navBarBackground"] && self.navImage) {
        return self.navImage;
    }else {

        UIImage * tintImage = [[UIImage imageNamed:imageName] imageWithTintColor:self.themeColor];
        if ([imageName isEqualToString:@"navBarBackground"] && !self.navImage) {
            self.navImage = tintImage;
        }
        return tintImage;
    }
}


-(void)resetInstence{
    _shareInstance = [self init];
}

@end

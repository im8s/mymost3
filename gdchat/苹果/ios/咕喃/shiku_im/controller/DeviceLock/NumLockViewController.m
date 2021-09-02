//
//  NumLockViewController.m
//  numLockTest
//
//  Created by banbu01 on 15-2-5.
//  Copyright (c) 2015年 com.koochat.test0716. All rights reserved.
//

#import "NumLockViewController.h"
#import "NumLockButton.h"
#define __MainScreen_Height [[UIScreen mainScreen] bounds].size.height

@interface NumLockViewController ()
{
    NSMutableString * _numlockStr;
    NSString * _rightStr;
    NSString * _oldStr;
    UIView * _dropV;
    UILabel * _hintLa;
}
@end

@implementation NumLockViewController

- (void)dealloc
{
    _numlockStr = nil;
    _rightStr = nil;
    _dropV = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _numlockStr = [[NSMutableString alloc] initWithCapacity:6];
//    _rightStr = [[NSMutableString alloc] initWithString:@"123456"];
//    self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.5 blue:0.2 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNumLockKeyboard];
    [self initSmallDrop];
    _hintLa = [[UILabel alloc] initWithFrame:CGRectMake(0, (__MainScreen_Height - 218)/2 - 80, JX_SCREEN_WIDTH, 23)];
    _hintLa.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_hintLa];
    UIButton * deleteBu = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBu setFrame:CGRectMake(JX_SCREEN_WIDTH - 100, __MainScreen_Height - 100, 80, 20)];
    [deleteBu setTitle:Localized(@"JX_Delete") forState:UIControlStateNormal];
    [deleteBu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBu addTarget:self action:@selector(deleteNumlock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBu];

    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"title_back_black_big"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    _rightStr = [g_default stringForKey:kDeviceLockPassWord];
    if (_rightStr.length > 0) {
        _hintLa.text = Localized(@"JX_PassWord");
        if (!self.isSet && !self.isClose) {
            cancelBtn.hidden = YES;
        }
    }else {
        _hintLa.text = Localized(@"JX_SetPassword");
        cancelBtn.hidden = NO;
    }
}

- (void)cancelBtnAction {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
}

- (void)deleteNumlock
{
    if (_numlockStr.length > 0)
    {
        NSString * numStr = [_numlockStr substringToIndex:_numlockStr.length - 1];
        [_numlockStr setString:numStr];
        UIImageView * dropImg = (UIImageView *)[self.view viewWithTag:_numlockStr.length + 2000];
        
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 0.4;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionFade;
        [dropImg setImage:[UIImage imageNamed:@"drop"]];
        [[dropImg layer] addAnimation:animation forKey:@"animation"];
        dropImg.backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark - 初始化数字密码键盘

- (void)initNumLockKeyboard
{
    
    for (int i = 0; i < 10; i++)
    {
        
        NumLockButton * numBu;
        if (i == 0)
        {
            numBu = [[NumLockButton alloc] initWithNumber:i letters:@""];
            [numBu setFrame:CGRectMake((JX_SCREEN_WIDTH - 64) / 2, (__MainScreen_Height - 218)/2 + 228, 64, 64)];
        }
        else
        {
            numBu = [[NumLockButton alloc] initWithNumber:i letters:[self lettersForNum:i]];
            CGFloat x = 0;
            if ((i - 1) % 3 == 0) {
                x = (JX_SCREEN_WIDTH - 272) / 2;
            }else {
                x = (i-1)%3*104 + ((JX_SCREEN_WIDTH - 272) / 2);
            }
            [numBu setFrame:CGRectMake(x, (__MainScreen_Height - 218)/2+(i-1)/3*76, 64, 64)];
        }
        numBu.tag = 1000 + i;
        [numBu addTarget:self action:@selector(numButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:numBu];
        
    }
}

- (NSString *)lettersForNum:(NSUInteger)num
{
    switch (num)
    {
        case 1:
        {
            return @" ";
            break;
        }
        case 2:
        {
            return @"ABC";
            break;
        }
        case 3:
        {
            return @"DEF";
            break;
        }
        case 4:
        {
            return @"GHI";
            break;
        }
        case 5:
        {
            return @"JKL";
            break;
        }
        case 6:
        {
            return @"MNO";
            break;
        }
        case 7:
        {
            return @"PQRS";
            break;
        }
        case 8:
        {
            return @"TUV";
            break;
        }
        case 9:
        {
            return @"WXYZ";
            break;
        }
        default:
        {
            return @"";
        }
    
    }
    return nil;
}


#pragma mark - 初始化密码小圆点
- (void)initSmallDrop
{
    _dropV = [[UIView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH - 160) / 2, (__MainScreen_Height - 218)/2 - 40, 160, 12)];
    _dropV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_dropV];
    for (int i = 0; i < 6; i ++)
    {
        UIImageView *dropImg = [[UIImageView alloc] initWithFrame:CGRectMake(i * 32, 0, 12, 12)];
        [_dropV addSubview:dropImg];
        dropImg.tag = 2000 + i;
        [dropImg setImage:[UIImage imageNamed:@"drop"]];
        dropImg.backgroundColor = [UIColor whiteColor];
        dropImg.layer.cornerRadius = dropImg.frame.size.width / 2;
        dropImg.layer.masksToBounds = YES;
        dropImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
        dropImg.layer.borderWidth = 1.0;
    }
}

- (void)numButtonPressed:(UIButton *)sender
{
    if (_numlockStr.length < 6)
    {
        [_numlockStr appendFormat:@"%lu",sender.tag - 1000];
        NSLog(@"%@",_numlockStr);
        UIImageView * dropImg = (UIImageView *)[self.view viewWithTag:_numlockStr.length + 2000 - 1];
    
        CATransition *animation = [CATransition animation];
        animation.delegate = self;
        animation.duration = 0.4;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionFade;
        [dropImg setImage:[UIImage imageNamed:@"drop_selected"]];
        [[dropImg layer] addAnimation:animation forKey:@"animation"];
        dropImg.backgroundColor = [UIColor lightGrayColor];
        if (_numlockStr.length == 6)
        {
            if ([_numlockStr isEqualToString:_rightStr])
            {
                if (self.isSet) {
                    _hintLa.text = Localized(@"JX_ResetPassword");
                    _rightStr = @"";
                    [_numlockStr setString:@""];
                }else {
                    if ([self.delegate respondsToSelector:@selector(numLockVCSetSuccess:)]) {
                        [self.delegate numLockVCSetSuccess:self];
                    }
                    g_App.isShowDeviceLock = NO;
//                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.view removeFromSuperview];
                }
            }
            else
            {
                if (_rightStr.length > 0) {
                    
                    [self startShake:_dropV];
                    _hintLa.text = Localized(@"JX_PasswordError");
                    [_numlockStr setString:@""];
                }else {
                    if (_oldStr.length > 0) {
                        if ([_numlockStr isEqualToString:_oldStr]) {
                            [g_server showMsg:Localized(@"JX_SetUpSuccess") delay:.5];
                            [g_default setObject:_numlockStr forKey:kDeviceLockPassWord];
                            [g_default synchronize];
                            if ([self.delegate respondsToSelector:@selector(numLockVCSetSuccess:)]) {
                                [self.delegate numLockVCSetSuccess:self];
                            }
//                            [self dismissViewControllerAnimated:YES completion:nil];
                            [self.view removeFromSuperview];
                            
                        }else {
                            
                            _hintLa.text = Localized(@"JX_NotMatch");
                            _oldStr = @"";
                            [_numlockStr setString:@""];
                            [self startShake:_dropV];
                        }
                    }else {
                        _oldStr = [_numlockStr copy];
                        _hintLa.text = Localized(@"JX_PleaseEnterAgain");
                        [_numlockStr setString:@""];
                    }
                }
                
            }
            
            for (int i = 0; i < 6; i ++)
            {
                UIImageView *dropImg = (UIImageView *)[self.view viewWithTag:2000 + i];
                [dropImg setImage:[UIImage imageNamed:@"drop"]];
                dropImg.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

#pragma mark - 拖动晃动
- (void)startShake:(UIView* )imageV
{
    // 晃动次数
    static int numberOfShakes = 4;
    // 晃动幅度（相对于总宽度）
    static float vigourOfShake = 0.04f;
    // 晃动延续时常（秒）
    static float durationOfShake = 0.5f;
    
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // 方法一：绘制路径
    CGRect frame = imageV.frame;
    // 创建路径
    CGMutablePathRef shakePath = CGPathCreateMutable();
    // 起始点
    CGPathMoveToPoint(shakePath, NULL, CGRectGetMidX(frame), CGRectGetMidY(frame));
    for (int index = 0; index < numberOfShakes; index++)
    {
        // 添加晃动路径,固定路径
        CGPathAddLineToPoint(shakePath, NULL, CGRectGetMidX(frame) - 20.0f,CGRectGetMidY(frame));
        CGPathAddLineToPoint(shakePath, NULL,  CGRectGetMidX(frame) + 20.0f,CGRectGetMidY(frame));

//         // 添加晃动路径 幅度由大变小
//         CGPathAddLineToPoint(shakePath, NULL, CGRectGetMidX(frame) - frame.size.width * vigourOfShake*(1-(float)index/numberOfShakes),CGRectGetMidY(frame));
//         CGPathAddLineToPoint(shakePath, NULL,  CGRectGetMidX(frame) + frame.size.width * vigourOfShake*(1-(float)index/numberOfShakes),CGRectGetMidY(frame));
    }
     // 闭合
     CGPathCloseSubpath(shakePath);
     shakeAnimation.path = shakePath;
     shakeAnimation.duration = durationOfShake;
     // 释放
     CFRelease(shakePath);
    [imageV.layer addAnimation:shakeAnimation forKey:kCATransition];
    
//    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    shakeAnimation.duration = 0.08;
//    shakeAnimation.autoreverses = YES;
//    shakeAnimation.repeatCount = 5;
//    shakeAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(imageV.frame.origin.x - 50, imageV.frame.origin.y, imageV.frame.size.width, imageV.frame.size.height)];//[NSValue valueWithCATransform3D:CATransform3DRotate(imageV.layer.transform, -0.06, 0, 0, 1)];
//    shakeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(imageV.frame.origin.x - 50, imageV.frame.origin.y, imageV.frame.size.width, imageV.frame.size.height)];//[NSValue valueWithCATransform3D:CATransform3DRotate(imageV.layer.transform, 0.06, 0, 0, 1)];
//    [imageV.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
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

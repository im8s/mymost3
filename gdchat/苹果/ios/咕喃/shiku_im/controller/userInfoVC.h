//
//  userInfoVC.h
//  sjvodios
//
//  Created by  on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "admobViewController.h"

@protocol JXServerResult;

@interface userInfoVC : admobViewController<JXServerResult>{
    JXImageView* _head;
    UIImage* _image;
}
@property(nonatomic,strong) JXUserObject* user;
@property(nonatomic,strong) NSString* userId;
@end

//
//  JXLabel.h
//  sjvodios
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXLabel : UILabel {
    NSObject	*_delegate;
}
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) BOOL      changeAlpha;
@property (nonatomic, assign) int       line;


@end

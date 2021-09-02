//
//  JXGroupHeplerModel.m
//  shiku_im
//
//  Created by 1 on 2019/5/29.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXGroupHeplerModel.h"

@implementation JXGroupHeplerModel

- (void)getDataWithDict:(NSDictionary *)dict {
    self.helperModel = [JXHelperModel initWithDict:[dict objectForKey:@"helper"]];
    self.helperId = [dict objectForKey:@"helperId"];
    self.groupHelperId = [dict objectForKey:@"id"];
    self.roomId = [dict objectForKey:@"roomId"];
    self.roomJid = [dict objectForKey:@"roomJid"];
    self.userId = [dict objectForKey:@"userId"];
    if ([dict objectForKey:@"keywords"]) {
        self.keywords = [dict objectForKey:@"keywords"];
    }
}

@end

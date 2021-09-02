//
//  JXMapData.m
//  CustomMKAnnotationView
//
//  Created by JianYe on 14-2-8.
//  Copyright (c) 2014年 Jian-Ye. All rights reserved.
//

#import "JXMapData.h"

@implementation JXMapData
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.latitude = [dictionary objectForKey:@"latitude"];
        self.longitude = [dictionary objectForKey:@"longitude"];
        self.title = [dictionary objectForKey:@"title"];
        self.subtitle = [dictionary objectForKey:@"subtitle"];
//        self.imageUrl = ;
    }
    return self;
}

-(CLLocationCoordinate2D)coordinate2D{
    double latitude = [self.latitude doubleValue];
    double longitude = [self.longitude doubleValue];
    CLLocationCoordinate2D coor = (CLLocationCoordinate2D){latitude,longitude};
    return coor;
}
@end

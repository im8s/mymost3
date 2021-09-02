//
//  MapView.m
//
//
//  Created by Jian-Ye on 12-10-16.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import "JXMapView.h"
#import "CallOutAnnotationView.h"
#import "CalloutMapAnnotation.h"
#import "BasicMapAnnotation.h"


@interface JXMapView ()<MKMapViewDelegate,CallOutAnnotationViewDelegate>

@property (nonatomic,strong)id<JXMapViewDelegate> delegate;

@property (nonatomic,strong)CalloutMapAnnotation *calloutAnnotation;
@end

@implementation JXMapView

@synthesize mapView = _mapView;
@synthesize delegate = _delegate;

- (id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.bounds];
         mapView.delegate = self;
        [self addSubview:mapView];
        self.mapView =  mapView;

        self.span = 40000;
    }
    return self;
}

- (id)initWithDelegate:(id<JXMapViewDelegate>)delegate
{
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    self.mapView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [super setFrame:frame];
}

- (void)beginLoad
{
    for (int i = 0; i < [_delegate numbersWithCalloutViewForMapView]; i++) {
        
        CLLocationCoordinate2D location = [_delegate coordinateForMapViewWithIndex:i];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location,_span ,_span );
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
        [_mapView setRegion:adjustedRegion animated:YES];
        
        BasicMapAnnotation *  annotation=[[BasicMapAnnotation alloc] initWithLatitude:location.latitude andLongitude:location.longitude tag:i];
        [_mapView   addAnnotation:annotation];
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if ([view.annotation isKindOfClass:[BasicMapAnnotation class]]) {
        
        BasicMapAnnotation *annotation = (BasicMapAnnotation *)view.annotation;
        
        if (_calloutAnnotation.coordinate.latitude == annotation.latitude&&
            _calloutAnnotation.coordinate.longitude == annotation.longitude)
        {
            return;
        }
        if (_calloutAnnotation) {
            [mapView removeAnnotation:_calloutAnnotation];
            self.calloutAnnotation = nil;
        }
        self.calloutAnnotation = [[CalloutMapAnnotation alloc]
                              initWithLatitude:annotation.latitude
                              andLongitude:annotation.longitude
                                  tag:annotation.tag];
        [mapView addAnnotation:_calloutAnnotation];
        
        [mapView setCenterCoordinate:_calloutAnnotation.coordinate animated:YES];
	}
}

- (void)didSelectAnnotationView:(CallOutAnnotationView *)view
{
    CalloutMapAnnotation *annotation = (CalloutMapAnnotation *)view.annotation;
    if([_delegate respondsToSelector:@selector(calloutViewDidSelectedWithIndex:)])
    {
        [_delegate calloutViewDidSelectedWithIndex:annotation.tag];
    }
    
    [self mapView:_mapView didDeselectAnnotationView:view];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_calloutAnnotation)
    {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude)
        {
            [mapView removeAnnotation:_calloutAnnotation];
            self.calloutAnnotation = nil;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[CalloutMapAnnotation class]])
    {
        CalloutMapAnnotation *calloutAnnotation = (CalloutMapAnnotation *)annotation;
        
        CallOutAnnotationView *annotationView = (CallOutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutView"];
        if (!annotationView)
        {
            annotationView = [[CallOutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CalloutView" delegate:self];
        }
        for (UIView *view in  annotationView.contentView.subviews) {
            [view removeFromSuperview];
        }
        [annotationView.contentView addSubview:[_delegate mapViewCalloutContentViewWithIndex:calloutAnnotation.tag]];
        return annotationView;
	} else if ([annotation isKindOfClass:[BasicMapAnnotation class]])
    {
        BasicMapAnnotation *basicMapAnnotation = (BasicMapAnnotation *)annotation;
        MKAnnotationView *annotationView =[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:@"CustomAnnotation"];
            annotationView.canShowCallout = NO;
            annotationView.image = [_delegate baseMKAnnotationViewImageWithIndex:basicMapAnnotation.tag];
        }
		
		return annotationView;
    }
	return nil;
}

@end






#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol JXMapViewDelegate;
@interface JXMapView : UIView

@property (nonatomic,strong)MKMapView *mapView;
@property (nonatomic,assign)double span;//default 40000

- (id)initWithDelegate:(id<JXMapViewDelegate>)delegate;
- (void)beginLoad;
@end


@protocol JXMapViewDelegate <NSObject>

- (NSInteger)numbersWithCalloutViewForMapView;
- (CLLocationCoordinate2D)coordinateForMapViewWithIndex:(NSInteger)index;
- (UIView *)mapViewCalloutContentViewWithIndex:(NSInteger)index;
- (UIImage *)baseMKAnnotationViewImageWithIndex:(NSInteger)index;

@optional
- (void)calloutViewDidSelectedWithIndex:(NSInteger)index;

@end
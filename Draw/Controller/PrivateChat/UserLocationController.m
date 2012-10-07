//
//  UserLocationController.m
//  Draw
//
//  Created by haodong on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserLocationController.h"
#import "UserAnnotation.h"

@interface UserLocationController ()

@property (retain, nonatomic) CLLocationManager *locationManager;
//@property (assign, nonatomic) 

@end

@implementation UserLocationController
@synthesize userMapView = _userMapView;
@synthesize titleLabel = _titleLabel;
@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_userMapView release];
    [_locationManager release];
    [_titleLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMap];
    [self updateLocation];
}

- (void)viewDidUnload
{
    [self setUserMapView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initMap
{
    self.userMapView.delegate = self;
    self.userMapView.mapType = MKMapTypeStandard;  
    self.userMapView.showsUserLocation = NO;
}

- (void)updateLocation
{
    if (_locationManager == nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        _locationManager.delegate = self;
    }
    _locationManager.desiredAccuracy = 100.0;
    _locationManager.distanceFilter = 1000.0;
    [_locationManager startUpdatingLocation];
}

- (void)showUserMapWithLatitude:(double)latitude longitude:(double)longitude
{
    MKCoordinateRegion newRegion;
    CLLocationCoordinate2D coordinate= CLLocationCoordinate2DMake(latitude, longitude);
    newRegion.center = coordinate;
    newRegion.span.latitudeDelta = 0.004000;
    newRegion.span.longitudeDelta = 0.004000;
    [self.userMapView setRegion:newRegion animated:YES];
    
    UserAnnotation *annotation = [[[UserAnnotation alloc] initWithCoordinate:coordinate] autorelease];
    [self.userMapView addAnnotation:annotation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    PPDebug(@"get location fail:%@",error);
    
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    PPDebug(@"didUpdateToLocation %f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [manager stopUpdatingLocation];
    
    [self showUserMapWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    UIAlertView *sendAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"kSendLocation" delegate:self cancelButtonTitle:@"kCancel" otherButtonTitles:@"kSure", nil];
    [sendAlertView show];
    [sendAlertView release];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"customAnnotationView";
    MKPinAnnotationView *customView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (customView == nil) {
        customView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
        customView.pinColor = MKPinAnnotationColorRed;
    }
    
    return customView;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    } else {
        if ([_delegate respondsToSelector:@selector(didClickSendLocation:longitude:)]) {
            //[_delegate didClickSendLocation:<#(double)#> longitude:<#(long)#>];
        }
    }
}


@end

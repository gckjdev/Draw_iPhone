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
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinate;
@property (assign, nonatomic) UserLocationType type;
@property (assign, nonatomic) int messageType;
@property (retain, nonatomic) NSString *reqMessageId;

@end

@implementation UserLocationController
@synthesize userMapView = _userMapView;
@synthesize titleLabel = _titleLabel;
@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
@synthesize userCoordinate = _userCoordinate;
@synthesize type = _type;
@synthesize messageType = _messageType;
@synthesize reqMessageId = _reqMessageId;

- (void)dealloc
{
    [_userMapView release];
    [_locationManager release];
    [_titleLabel release];
    [_reqMessageId release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setUserMapView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (id)initWithType:(UserLocationType)type
          latitude:(double)latitude
         longitude:(double)longitude
       messageType:(int)messageType
{
    self = [super init];
    if (self) {
        self.type = type;
        if (type == LocationTypeShow) {
            self.userCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        } else {
            self.messageType = messageType;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMap];
    
    if (_type == LocationTypeFind) {
        [self findMyLocation];
    } else {
        [self showUserMap];
    }
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

- (void)findMyLocation
{
    if (_locationManager == nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        _locationManager.delegate = self;
    }
    _locationManager.desiredAccuracy = 100.0;
    _locationManager.distanceFilter = 1000.0;
    [_locationManager startUpdatingLocation];
}

- (void)showUserMap
{
    MKCoordinateRegion newRegion;
    newRegion.center = _userCoordinate;
    newRegion.span.latitudeDelta = 0.004000;
    newRegion.span.longitudeDelta = 0.004000;
    [self.userMapView setRegion:newRegion animated:YES];
    
    UserAnnotation *annotation = [[[UserAnnotation alloc] initWithCoordinate:_userCoordinate] autorelease];
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
    self.userCoordinate = newLocation.coordinate;
    [manager stopUpdatingLocation];
    
    [self showUserMap];
    
    UIAlertView *sendAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLS(@"kSendLocation") delegate:self cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOK"), nil];
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
- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    } else {
        if ([_delegate respondsToSelector:@selector(didClickSendLocation:longitude:messageType:)]) {
            [_delegate didClickSendLocation:_userCoordinate.latitude longitude:_userCoordinate.longitude messageType:_messageType];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end

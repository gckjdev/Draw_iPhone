//
//  UserLocationController.m
//  Draw
//
//  Created by haodong on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserLocationController.h"
#import "UserAnnotation.h"
#import "ChatMessage.h"

@interface UserLocationController ()

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinate;
@property (assign, nonatomic) UserLocationType type;
@property (assign, nonatomic) int messageType;
@property (retain, nonatomic) NSString *reqMessageId;
@property (assign, nonatomic) BOOL hasGetLocation;
@property (assign, nonatomic) BOOL isMe;

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
@synthesize hasGetLocation;
@synthesize isMe = _isMe;

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
              isMe:(BOOL)isMe
          latitude:(double)latitude
         longitude:(double)longitude
       messageType:(int)messageType
{
    self = [super init];
    if (self) {
        self.type = type;
        self.isMe = isMe;
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
    
    NSString *title = nil;
    if (_type == LocationTypeFind) {
        if (_messageType == MessageTypeAskLocation) {
            title = NSLS(@"kAskLocationTitle");
        } else if (_messageType  == MessageTypeReplyLocation) {
            title = NSLS(@"kReplyLocationTitle");
        }
    } else {
        if (_isMe) {
            title = NSLS(@"kShowMyLocationTitle");
        } else {
            title = NSLS(@"kShowFriendLocationTitle");
        }
    }
    [self.titleLabel setText:title];
    
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
    hasGetLocation = NO;
    
    [self showActivityWithText:NSLS(@"kGetingLocation")];
    [_locationManager startUpdatingLocation];
}

- (void)showUserMap
{
    MKCoordinateRegion newRegion;
    newRegion.center = _userCoordinate;
    newRegion.span.latitudeDelta = 0.01000;
    newRegion.span.longitudeDelta = 0.01000;
    [self.userMapView setRegion:newRegion animated:YES];
    
    UserAnnotation *annotation = [[[UserAnnotation alloc] initWithCoordinate:_userCoordinate] autorelease];
    [self.userMapView addAnnotation:annotation];
}

#pragma mark - CLLocationManagerDelegate method
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    PPDebug(@"get location fail:%@",error);
    [self hideActivity];
    [manager stopUpdatingLocation];
    [self popupHappyMessage:NSLS(@"kGetLocationFail") title:nil];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    PPDebug(@"didUpdateToLocation %f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [self hideActivity];
    [manager stopUpdatingLocation];
    self.userCoordinate = newLocation.coordinate;
    [self showUserMap];
    
    if (hasGetLocation == NO) {
        hasGetLocation = YES;
        
        NSString *alertString = nil;
        if(_messageType == MessageTypeAskLocation){
            alertString = NSLS(@"kAskLocationAlert");
        } else if (_messageType == MessageTypeReplyLocation){
            alertString = NSLS(@"kReplyLocationAlert");
        }
        
        UIAlertView *sendAlertView = [[UIAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOK"), nil];
        [sendAlertView show];
        [sendAlertView release];
    }
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

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
@property (retain, nonatomic) CLLocation *userLocation;
@property (assign, nonatomic) UserLocationType type;
@property (assign, nonatomic) MessageType messageType;
@property (retain, nonatomic) NSString *reqMessageId;
@property (assign, nonatomic) BOOL hasGetLocation;
@property (assign, nonatomic) BOOL isMe;
@property (nonatomic, retain) CLGeocoder *geocoder;
@property (nonatomic, retain) NSString *userAddress;

@end

@implementation UserLocationController
@synthesize userMapView = _userMapView;
@synthesize titleLabel = _titleLabel;
@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
@synthesize userLocation = _userLocation;
@synthesize type = _type;
@synthesize messageType = _messageType;
@synthesize reqMessageId = _reqMessageId;
@synthesize hasGetLocation;
@synthesize isMe = _isMe;
@synthesize geocoder = _geocoder;
@synthesize userAddress = _userAddress;

- (void)dealloc
{
    [_userMapView release];
    [_locationManager release];
    [_titleLabel release];
    [_reqMessageId release];
    [_geocoder release];
    [_userAddress release];
    [_userLocation release];
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
       messageType:(MessageType)messageType
      reqMessageId:(NSString *)reqMessageId
{
    self = [super init];
    if (self) {
        self.geocoder = [[[CLGeocoder alloc] init] autorelease];
        self.type = type;
        self.isMe = isMe;
        if (type == LocationTypeShow) {
            self.userLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
        } else {
            self.messageType = messageType;
            if (messageType == MessageTypeLocationResponse) {
                self.reqMessageId = reqMessageId;
            }
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = nil;
    if (_type == LocationTypeFind) {
        if (_messageType == MessageTypeLocationRequest) {
            title = NSLS(@"kAskLocationTitle");
        } else if (_messageType  == MessageTypeLocationResponse) {
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
        [self findAddress];
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

- (void)findAddress
{
    [_geocoder reverseGeocodeLocation:_userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            PPDebug(@"<UserLocationController> reverseGeocodeLocation error:%@",error);
        }else {
            PPDebug(@"<UserLocationController>  reverseGeocodeLocation success");
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if ( placemark.subThoroughfare == nil) {
                 self.userAddress = [NSString stringWithFormat:@"%@%@%@", placemark.locality, placemark.subLocality, placemark.thoroughfare];
            } else {
                 self.userAddress = [NSString stringWithFormat:@"%@%@%@%@", placemark.locality, placemark.subLocality, placemark.thoroughfare,  placemark.subThoroughfare];
            }
           
        }
        [self showUserMap];
    }];
    
}

- (void)showSendTips
{
    NSString *alertString = nil;
    if(_messageType == MessageTypeLocationRequest){
        alertString = NSLS(@"kAskLocationAlert");
    } else if (_messageType == MessageTypeLocationResponse){
        alertString = NSLS(@"kReplyLocationAlert");
    }
    
    UIAlertView *sendAlertView = [[UIAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:NSLS(@"kCancel") otherButtonTitles:NSLS(@"kOK"), nil];
    [sendAlertView show];
    [sendAlertView release];
}

- (void)showUserMap
{
    [self hideActivity];
    
    MKCoordinateRegion newRegion;
    newRegion.center = _userLocation.coordinate;
    newRegion.span.latitudeDelta = 0.01000;
    newRegion.span.longitudeDelta = 0.01000;
    [self.userMapView setRegion:newRegion animated:YES];
    
    UserAnnotation *annotation = [[[UserAnnotation alloc] initWithCoordinate:_userLocation.coordinate title:_userAddress subtitle:nil] autorelease];
    
    [self.userMapView addAnnotation:annotation];
    [self.userMapView selectAnnotation:annotation animated:YES];
    
    if (_type == LocationTypeFind) {
        if (hasGetLocation == NO) {
            hasGetLocation = YES;
            
            [self performSelector:@selector(showSendTips) withObject:nil afterDelay:0.5];
        }
    }
}

#pragma mark - CLLocationManagerDelegate method
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    PPDebug(@"<UserLocationController>  get location fail:%@",error);
    [self hideActivity];
    [manager stopUpdatingLocation];
    [self popupHappyMessage:NSLS(@"kGetLocationFail") title:nil];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    PPDebug(@"<UserLocationController>  didUpdateToLocation %f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [manager stopUpdatingLocation];
    self.userLocation = newLocation;
    
    [self findAddress];
}


- (void)selectAnnotation:(id <MKAnnotation>)annotation
{
    [self.userMapView selectAnnotation:annotation animated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"customAnnotationView";
    MKPinAnnotationView *customView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (customView == nil) {
        customView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
        customView.pinColor = MKPinAnnotationColorRed;
        customView.canShowCallout = YES;
        
        [self performSelector:@selector(selectAnnotation:) withObject:annotation afterDelay:0.3f];
    }
    
    return customView;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self == nil) {
        return;
    }
    
    if (buttonIndex == 0) {
        return;
    } else {
        if ([_delegate respondsToSelector:@selector(didClickSendLocation:longitude:messageType:reqMessageId:)]) {
            [_delegate didClickSendLocation:_userLocation.coordinate.latitude longitude:_userLocation.coordinate.longitude messageType:_messageType reqMessageId:_reqMessageId];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end

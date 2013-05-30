//
//  UserLocationController.h
//  Draw
//
//  Created by haodong on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PPMessage.h"

typedef enum {
    LocationTypeFind,
    LocationTypeShow,
} UserLocationType ;

@protocol UserLocationControllerDelegate <NSObject>

@optional
- (void)didClickSendLocation:(double)latitude
                   longitude:(double)longitude
                 messageType:(MessageType)messageType
                reqMessageId:(NSString *)reqMessageId;
@end

@interface UserLocationController : PPViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet MKMapView *userMapView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) id<UserLocationControllerDelegate> delegate;

- (id)initWithType:(UserLocationType)type
              isMe:(BOOL)isMe
          latitude:(double)latitude
         longitude:(double)longitude
       messageType:(MessageType)messageType
      reqMessageId:(NSString *)reqMessageId;

@end

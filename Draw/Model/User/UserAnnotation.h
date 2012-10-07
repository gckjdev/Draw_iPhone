//
//  UserAnnotation.h
//  Draw
//
//  Created by haodong on 12-10-6.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end

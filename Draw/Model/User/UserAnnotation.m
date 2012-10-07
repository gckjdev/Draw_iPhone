//
//  UserAnnotation.m
//  Draw
//
//  Created by haodong on 12-10-6.
//
//

#import "UserAnnotation.h"

@implementation UserAnnotation
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        coordinate.longitude = coord.longitude;
        coordinate.latitude = coord.latitude;
    }
    
    return self;
}


@end

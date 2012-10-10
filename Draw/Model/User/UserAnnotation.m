//
//  UserAnnotation.m
//  Draw
//
//  Created by haodong on 12-10-6.
//
//

#import "UserAnnotation.h"

@interface UserAnnotation()

@property (retain, nonatomic) NSString *customTile;
@property (retain, nonatomic) NSString *customSubtitle;

@end

@implementation UserAnnotation
@synthesize coordinate;
@synthesize customTile = _customTile;
@synthesize customSubtitle = _customSubtitle;

- (void)dealloc
{
    [_customTile release];
    [_customSubtitle release];
    [super dealloc];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        coordinate.longitude = coord.longitude;
        coordinate.latitude = coord.latitude;
        self.customTile = title;
        self.customSubtitle = subtitle;
    }
    
    return self;
}

- (NSString *)title
{
    return _customTile;
}

- (NSString *)subtitle
{
    return _customSubtitle;
}


@end

//
//  GeographyService.h
//  Draw
//
//  Created by Kira on 13-4-6.
//
//

#import "CommonService.h"

@protocol GeographyServiceDelegate <NSObject>

- (void)findCityDone:(int)result cityName:(NSString*)city provinceName:(NSString*)provinceName countryCode:(int)countryCode;


@end

@interface GeographyService : CommonService

- (void)findCityWithLatitude:(double)latitude
                   longitude:(double)longitude
                    delegate:(id<GeographyServiceDelegate>)delegate;
+ (GeographyService*)defaultService;
@end

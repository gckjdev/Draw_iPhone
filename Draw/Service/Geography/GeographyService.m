//
//  GeographyService.m
//  Draw
//
//  Created by Kira on 13-4-6.
//
//

#import "GeographyService.h"
#import "GoogleAddressComponent.h"
#import "CommonNetworkClient.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "SynthesizeSingleton.h"
#import "LocaleUtils.h"

@implementation GeographyService

SYNTHESIZE_SINGLETON_FOR_CLASS(GeographyService)

- (void)findCityWithLatitude:(double)latitude
                   longitude:(double)longitude
                    delegate:(id<GeographyServiceDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CommonNetworkOutput *output = [GameNetworkRequest queryGeocodeWithLatitude:latitude longitude:longitude language:[LocaleUtils getLanguageCode]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *countryCode = nil;
            NSString *cityName = nil;
            NSString *province = nil;
            
            if (output.resultCode == ERROR_SUCCESS) {
                countryCode = [[GACManager defaultManager] countryCode:output.jsonDataDict];
                cityName = [[GACManager defaultManager] cityName:output.jsonDataDict];
                province = [[GACManager defaultManager] provinceName:output.jsonDataDict];
                
                PPDebug(@"findCity city:%@ country:%@", cityName, countryCode);
            } else {
                PPDebug(@"findCity failed");
            }
            
            if ([delegate respondsToSelector:@selector(findCityDone:cityName:provinceName:countryCode:)]){
                [delegate findCityDone:output.resultCode cityName:cityName provinceName:province countryCode:countryCode];
            }
        });
    });
}


@end

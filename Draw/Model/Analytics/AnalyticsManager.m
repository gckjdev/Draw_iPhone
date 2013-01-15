//
//  AnalyticsManager.m
//  Draw
//
//  Created by qqn_pipi on 12-12-29.
//
//

#import "AnalyticsManager.h"
#import "SynthesizeSingleton.h"
#import "MobClick.h"

@implementation AnalyticsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AnalyticsManager)



- (void)reportClickHomeMenu:(NSString*)menuName
{
    [MobClick event:HOME_CLICK label:menuName acc:1];
}

- (void)reportClickHomeElements:(NSString*)elementName
{
    [MobClick event:HOME_CLICK label:elementName acc:1];    
}


- (void)reportRegistration:(NSString*)snsName
{
    [MobClick event:REGISTRATION_CLICK label:snsName acc:1];
}

- (void)reportRegistrationResult:(int)errorCode
{
    [MobClick event:REGISTRATION_RESULT label:[NSString stringWithFormat:@"%d", errorCode] acc:1];
}


- (void)reportTopTabClicks:(NSString*)tabName
{
    [MobClick event:TOP_TAB_CLICK label:tabName acc:1];
}

- (void)reportTopDrawClicks:(NSString*)tabName
{
    [MobClick event:TOP_TAB_OPUS_CLICK label:tabName acc:1];    
}

- (void)reportDrawDetailsActionClicks:(NSString*)actionName
{
    [MobClick event:TOP_TAB_OPUS_CLICK label:actionName acc:1];
}

- (void)reportShareActionClicks:(NSString*)actionName
{
    [MobClick event:SHARE_ACTION_CLICK label:actionName acc:1];
}

- (void)reportContestHomeClicks:(NSString*)name
{
    [MobClick event:CONTEST_HOME_CLICK label:name acc:1];    
}

- (void)reportFreeCoins:(NSString*)freeCoinTypeName
{
    [MobClick event:FREE_COIN_CLICK label:freeCoinTypeName acc:1];    
}

@end

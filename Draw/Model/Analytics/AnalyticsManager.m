//
//  AnalyticsManager.m
//  Draw
//
//  Created by qqn_pipi on 12-12-29.
//
//

#import "AnalyticsManager.h"
#import "SynthesizeSingleton.h"
#import "MobClickUtils.h"

@implementation AnalyticsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AnalyticsManager)

- (void)reportClickHomeMenu:(NSString*)menuName
{
    [MobClick event:HOME_CLICK label:menuName];
}

- (void)reportClickHomeElements:(NSString*)elementName
{
    [MobClick event:HOME_CLICK label:elementName];
}


- (void)reportRegistration:(NSString*)snsName
{
    [MobClick event:REGISTRATION_CLICK label:snsName];
}

- (void)reportRegistrationResult:(int)errorCode
{
    [MobClick event:REGISTRATION_RESULT label:[NSString stringWithFormat:@"%d", errorCode]];
}


- (void)reportTopTabClicks:(NSString*)tabName
{
    [MobClick event:TOP_TAB_CLICK label:tabName];
}

- (void)reportTopDrawClicks:(NSString*)tabName
{
    [MobClick event:TOP_TAB_OPUS_CLICK label:tabName];
}

- (void)reportDrawDetailsActionClicks:(NSString*)actionName
{
    [MobClick event:TOP_TAB_OPUS_CLICK label:actionName];
}

- (void)reportShareActionClicks:(NSString*)actionName
{
    [MobClick event:SHARE_ACTION_CLICK label:actionName];
}

- (void)reportContestHomeClicks:(NSString*)name
{
    [MobClick event:CONTEST_HOME_CLICK label:name];
}

- (void)reportFreeCoins:(NSString*)freeCoinTypeName
{
    [MobClick event:FREE_COIN_CLICK label:freeCoinTypeName];
}

- (void)reportSelectWord:(NSString*)wordType
{
    [MobClick event:SELECT_WORD_CLICK label:wordType];
}

- (void)reportDrawClick:(NSString*)name
{
    [MobClick event:DRAW_CLICK label:name];
    
}


@end

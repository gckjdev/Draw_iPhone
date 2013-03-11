//
//  GameConfigDataManager.m
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import "GameConfigDataManager.h"
#import "Config.pb.h"
#import "GameConfigData.h"
#import "PPSmartUpdateDataUtils.h"

#define DEFAULT_CONFIG_FILE     @"default_config.pb"

@interface GameConfigDataManager()
{
    GameConfigData* _defaultConfigData;
}

@end

@implementation GameConfigDataManager

static GameConfigDataManager* _defaultConfigInstance = nil;
static dispatch_once_t onceToken;

+ (GameConfigDataManager*)defaultInstance
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultConfigInstance = [[GameConfigDataManager alloc] init];
    });
    
    return _defaultConfigInstance;
}

+ (GameConfigDataManager*)defaultManager
{
    return [GameConfigDataManager defaultInstance];
}

- (id)init
{
    self = [super init];    
    _defaultConfigData = [[GameConfigData alloc] initWithName:DEFAULT_CONFIG_FILE];
    [_defaultConfigData autoUpdate];
    return self;
}
                          
- (void)dealloc
{
    [_defaultConfigData release];
    [super dealloc];
}

- (PBConfig*)defaultConfig
{
    return _defaultConfigData.config;
}

+ (void)createTestConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:DEFAULT_CONFIG_FILE];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:DEFAULT_CONFIG_FILE]];

    PBConfig_Builder* builder = [PBConfig builder];                                
                                 
    NSArray* amount = @[@"10000", @"18000", @"66000", @"180000"];
    NSArray* prices = @[@"1.99", @"2.99", @"9.99", @"24.99"];
    NSArray* saves = @[@"0", @"15", @"33", @"50"];
    NSArray* productIds = @[@"com.orange.dice.coins1200", @"com.orange.dice.coins2400", @"com.orange.dice.coins6000", @"com.orange.dice.coins20000"];
    for (int i=0; i<amount.count; i++){
        PBPrice_Builder* priceBuilder = [PBPrice builder];
        [priceBuilder setAmount:[amount objectAtIndex:i]];
        [priceBuilder setPrice:[prices objectAtIndex:i]];
        [priceBuilder setSavePercent:[saves objectAtIndex:i]];
        [priceBuilder setProductId:[productIds objectAtIndex:i]];
        
        [builder addCoinPrices:[priceBuilder build]];
    }
    
    PBZJHConfig_Builder* zjhBuilder = [PBZJHConfig builder];
    [builder setZjhConfig:[zjhBuilder build]];
    
    PBDiceConfig_Builder* diceBuilder = [PBDiceConfig builder];
    [builder setDiceConfig:[diceBuilder build]];

    PBDrawConfig_Builder* drawBuilder = [PBDrawConfig builder];
    [builder setDrawConfig:[drawBuilder build]];
    
    PBConfig* config = [builder build];
    NSData* data = [config data];

    [data writeToFile:path atomically:YES];
    
    NSString* version = @"1.00001";
    [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSArray*)appRewardList
{
    return [self.defaultConfig appRewardsList];
}

- (NSArray*)rewardWallList
{
    return [self.defaultConfig rewardWallsList];
}


@end

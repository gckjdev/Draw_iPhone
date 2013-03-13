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

+ (PBAppReward*)createAppReward:(NSString*)appNameCn
appId:(NSString*)appId
{
    // set name
    PBLocalizeString_Builder *str1 = [PBLocalizeString builder];
    [str1 setLanguageCode:@"zh-Hans"];
    [str1 setText:appNameCn];
    [str1 setLocalizedText:appNameCn];
    
    PBLocalizeString_Builder *str3 = [PBLocalizeString builder];
    [str3 setLanguageCode:@"en"];
    [str3 setText:appNameCn];
    [str3 setLocalizedText:[NSString stringWithFormat:@"%@(en)",appNameCn]];

    // set desc
    PBLocalizeString_Builder *str2 = [PBLocalizeString builder];
    [str2 setLanguageCode:@"zh-Hans"];
    [str2 setText:@"TEST DESC"];
    [str2 setLocalizedText:@"TEST DESC"];
    
    PBLocalizeString_Builder *str4 = [PBLocalizeString builder];
    [str4 setLanguageCode:@"en"];
    [str4 setText:@"TEST DESC en"];
    [str4 setLocalizedText:@"TEST DESC en"];
    
    PBApp_Builder* appBuilder = [PBApp builder];
    [appBuilder setAppId:appId];
    [appBuilder setDownloadUrl:@"https://itunes.apple.com/cn/app/cai-cai-hua-hua/id513819630?mt=8"];
    [appBuilder setLogo:@"http://a2.mzstatic.com/us/r1000/114/Purple2/v4/99/03/26/9903264b-c5c7-2666-03e9-fddec311e017/mzl.uzfuouyo.175x175-75.jpg"];
    [appBuilder addName:[str1 build]];
    [appBuilder addName:[str3 build]];
    [appBuilder addDesc:[str2 build]];
    [appBuilder addDesc:[str4 build]];
    
    PBAppReward_Builder* appRewardBuilder = [PBAppReward builder];
    [appRewardBuilder setApp:[appBuilder build]];
    [appRewardBuilder setRewardAmount:10];
    [appRewardBuilder setRewardCurrency:PBGameCurrencyIngot];
    
    return [appRewardBuilder build];;
}

+ (PBRewardWall*)creatRewardWall:(NSString*)cnName
                          enName:(NSString*)enName
                            type:(int)type
                            logo:(NSString*)logoUrl
{
    PBRewardWall_Builder* builder1 = [PBRewardWall builder];
    [builder1 setType:0];
    [builder1 setLogo:logoUrl];
    
    PBLocalizeString_Builder* lstb = [PBLocalizeString builder];
    [lstb setLanguageCode:@"en"];
    [lstb setText:@"kName"];
    [lstb setLocalizedText:enName];
    
    PBLocalizeString_Builder* lstb1 = [PBLocalizeString builder];
    [lstb1 setLanguageCode:@"zh-Hans"];
    [lstb1 setText:@"kName"];
    [lstb1 setLocalizedText:cnName];
    
    [builder1 addName:[lstb build]];
    [builder1 addName:[lstb1 build]];
    
    return [builder1 build];
}

+ (void)createTestConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:DEFAULT_CONFIG_FILE];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:DEFAULT_CONFIG_FILE]];

    PBConfig_Builder* builder = [PBConfig builder];
                                 
    /*
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
    */
    

    PBAppReward* diceApp = [GameConfigDataManager createAppReward:@"Dice" appId:@"1234"];

    PBAppReward* zjhApp = [GameConfigDataManager createAppReward:@"ZJH" appId:@"2234"];
    
    PBRewardWall* limei = [GameConfigDataManager creatRewardWall:@"力美"
                                                          enName:@"limei"
                                                            type:0
                                                            logo:@"http://a2.mzstatic.com/us/r1000/114/Purple2/v4/99/03/26/9903264b-c5c7-2666-03e9-fddec311e017/mzl.uzfuouyo.175x175-75.jpg"];
    PBRewardWall* youmi = [GameConfigDataManager creatRewardWall:@"有米"
                                                          enName:@"youmi"
                                                            type:1
                                                            logo:@"http://a2.mzstatic.com/us/r1000/114/Purple2/v4/99/03/26/9903264b-c5c7-2666-03e9-fddec311e017/mzl.uzfuouyo.175x175-75.jpg"];
    
    
    
    [builder addAppRewards:diceApp];
    [builder addAppRewards:zjhApp];
    [builder addRewardWalls:limei];
    [builder addRewardWalls:youmi];
     
    PBConfig* config = [builder build];
    NSData* data = [config data];

    [data writeToFile:path atomically:YES];
    
    NSString* version = @"1.00002";
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

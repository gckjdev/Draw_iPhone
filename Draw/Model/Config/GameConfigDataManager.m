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
#import "UIUtils.h"
#import "GameApp.h"

//#define DEFAULT_CONFIG_FILE     @"default_config.pb"

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
    _defaultConfigData = [[GameConfigData alloc] initWithName:[GameConfigDataManager configFileName]];
    [_defaultConfigData autoUpdate];
    return self;
}

- (void)dealloc
{
    [_defaultConfigData release];
    [super dealloc];
}

+ (NSString*)configFileName
{
    return [NSString stringWithFormat:@"default_config_%@.pb", [GameApp gameId]];
}

- (PBConfig*)defaultConfig
{
    return _defaultConfigData.config;
}

+ (PBAppReward*)createAppReward:(NSString*)appNameCn
                         nameEn:(NSString*)nameEn
                         descCn:(NSString*)descCn
                         descEn:(NSString*)descEn
                          appId:(NSString*)appId
                     appLogoURL:(NSString*)appLogoURL
                   rewardAmount:(int)rewardAmount
{
    // set name
    PBLocalizeString_Builder *str1 = [PBLocalizeString builder];
    [str1 setLanguageCode:@"zh-Hans"];
    [str1 setText:appNameCn];
    [str1 setLocalizedText:appNameCn];
    
    PBLocalizeString_Builder *str3 = [PBLocalizeString builder];
    [str3 setLanguageCode:@"en"];
    [str3 setText:nameEn];
    [str3 setLocalizedText:[NSString stringWithFormat:@"%@",nameEn]];

    // set desc
    PBLocalizeString_Builder *str2 = [PBLocalizeString builder];
    [str2 setLanguageCode:@"zh-Hans"];
    [str2 setText:descCn];
    [str2 setLocalizedText:descCn];
    
    PBLocalizeString_Builder *str4 = [PBLocalizeString builder];
    [str4 setLanguageCode:@"en"];
    [str4 setText:descEn];
    [str4 setLocalizedText:descEn];
    
    PBApp_Builder* appBuilder = [PBApp builder];
    [appBuilder setAppId:appId];
    [appBuilder setDownloadUrl:[UIUtils getAppLink:appId]];
    [appBuilder setLogo:appLogoURL];
    
    [appBuilder addName:[str1 build]];
    [appBuilder addName:[str3 build]];
    [appBuilder addDesc:[str2 build]];
    [appBuilder addDesc:[str4 build]];
    
    PBAppReward_Builder* appRewardBuilder = [PBAppReward builder];
    [appRewardBuilder setApp:[appBuilder build]];
    [appRewardBuilder setRewardAmount:rewardAmount];
    [appRewardBuilder setRewardCurrency:PBGameCurrencyIngot];
    
    return [appRewardBuilder build];;
}

+ (PBRewardWall*)creatRewardWall:(NSString*)cnName
                          enName:(NSString*)enName
                            type:(int)type
                            logo:(NSString*)logoUrl
{
    PBRewardWall_Builder* builder1 = [PBRewardWall builder];
    [builder1 setType:type];
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
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];

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
    

    PBAppReward* diceApp = [GameConfigDataManager createAppReward:@"夜店大话骰" nameEn:@"Liar Dice" descCn:@"在线多人趣味大话骰子游戏" descEn:@"Online liar dice game" appId:DICE_APP_ID appLogoURL:@"http://58.215.160.100:8080/icon/dice_114.png" rewardAmount:3];

    PBAppReward* zjhApp = [GameConfigDataManager createAppReward:@"诈金花" nameEn:@"Awesome Three Card Poker" descCn:@"刺激好玩的多人在线诈金花扑克牌游戏" descEn:@"Online three card porker game" appId:ZJH_APP_ID appLogoURL:@"http://58.215.160.100:8080/icon/zjh_512.png" rewardAmount:5];
    
    PBRewardWall* limei = [GameConfigDataManager creatRewardWall:@"力美 推荐应用"
                                                          enName:@"Li Mei"
                                                            type:PBRewardWallTypeLimei
                                                            logo:@"http://58.215.160.100:8080/icon/ad_limei.png"];
//    PBRewardWall* wanpu = [GameConfigDataManager creatRewardWall:@"万普 推荐应用"
//                                                          enName:@"Wan Pu"
//                                                            type:PBRewardWallTypeWanpu
//                                                            logo:@"http://58.215.160.100:8080/icon/ad_wanpu.png"];
    
    PBRewardWall* youmi = [GameConfigDataManager creatRewardWall:@"有米 推荐应用"
                                                          enName:@"You Mi"
                                                            type:PBRewardWallTypeYoumi
                                                            logo:@"http://58.215.160.100:8080/icon/ad_youmi.png"];
    
    PBRewardWall* ader = [GameConfigDataManager creatRewardWall:@"人人 推荐应用"
                                                          enName:@"Ren Ren Ader"
                                                            type:PBRewardWallTypeAder
                                                            logo:@"http://58.215.160.100:8080/icon/ad_renren.png"];
    
    [builder addAppRewards:zjhApp];
    [builder addAppRewards:diceApp];
    [builder addRewardWalls:limei];
    [builder addRewardWalls:youmi];
    [builder addRewardWalls:ader];
//    [builder addRewardWalls:wanpu];
    
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

//
//  FreeIngotCell.m
//  Draw
//
//  Created by Kira on 13-3-12.
//
//

#import "FreeIngotCell.h"
#import "GameBasic.pb.h"
#import "Config.pb.h"
#import "AutoCreateViewByXib.h"
#import "UIImageView+WebCache.h"
#import "ShareImageManager.h"

@implementation FreeIngotCell

AUTO_CREATE_VIEW_BY_XIB(FreeIngotCell)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSString*)getCellIdentifier
{
    return @"FreeIngotCell";
}

+ (float)getCellHeight
{
    return [DeviceDetection isIPAD]?182.0:91.0;
}

+ (id)createCell:(id)delegate
{
    return [self createView];
}

- (void)setAppImageWithURLStr:(NSString*)urlStr
{
    self.appImageView.alpha = 0;
    [self.appImageView setImageWithURL:[NSURL URLWithString:urlStr]
                      placeholderImage:nil
                               success:^(UIImage *image, BOOL cached) {
                                   if (!cached) {
                                       [UIView animateWithDuration:1 animations:^{
                                           self.appImageView.alpha = 1.0;
                                       }];
                                   }else{
                                       self.appImageView.alpha = 1.0;
                                   }
                               }
                               failure:^(NSError *error) {
                                   self.appImageView.alpha = 1;
                               }];
}

- (NSString*)getCurrentLolalizeStringFromPbLocalizeStringList:(NSArray*)list
{
    NSString* currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* defaultText = nil;
    for (PBLocalizeString* ls in list) {
        if ([ls.languageCode isEqualToString:currentLanguage]) {
            defaultText = ls.localizedText;
        }
        if ([ls.languageCode isEqualToString:@"en"] && defaultText == nil) {
            defaultText = ls.localizedText;
        }
    }
    return defaultText;
}

- (void)setCellWithPBAppReward:(PBAppReward*)pbAppReward
{
    [self setAppImageWithURLStr:pbAppReward.app.logo];
    [self.rewardCurrencyImageView setImage:[[ShareImageManager defaultManager] currencyImageWithType:pbAppReward.rewardCurrency]];
    
    
    [self.appNameLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbAppReward.app.nameList]];
    [self.appDescriptionLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbAppReward.app.descList]];
    [self.rewardCurrencyCountLabel setText:[NSString stringWithFormat:@"+%d", pbAppReward.rewardAmount]];
    
    [self.appDescriptionLabel setHidden:NO];
    [self.rewardCurrencyCountLabel setHidden:NO];
    [self.customAccessoryImageView setHidden:YES];

}

- (void)setCellWithPBRewardWall:(PBRewardWall*)pbRewardWall
{
    [self setAppImageWithURLStr:pbRewardWall.logo];
    [self.appNameLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbRewardWall.nameList]];
    [self.appNameLabel setCenter:CGPointMake(self.appNameLabel.center.x, [FreeIngotCell getCellHeight]/2)];
    
    [self.appDescriptionLabel setHidden:YES];
    [self.rewardCurrencyCountLabel setHidden:YES];
    [self.customAccessoryImageView setHidden:NO];
    

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_appImageView release];
    [_appNameLabel release];
    [_appDescriptionLabel release];
    [_rewardCurrencyCountLabel release];
    [_rewardCurrencyImageView release];
    [_customAccessoryImageView release];
    [super dealloc];
}
@end

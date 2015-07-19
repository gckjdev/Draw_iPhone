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
#import "AnimationManager.h"

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

+ (CGFloat)getCellHeight
{
    return [DeviceDetection isIPAD]?160.0:74.0;
}

+ (id)createCell:(id)delegate
{
    FreeIngotCell *cell = [self createView];
    UIView *bgView = [[[UIView alloc] initWithFrame:cell.contentView.bounds] autorelease];
    [bgView updateHeight:CGRectGetHeight(bgView.bounds)*0.82];
    [bgView updateWidth:CGRectGetWidth(bgView.bounds) * 0.92];
    bgView.center = cell.contentView.center;
    SET_VIEW_ROUND_CORNER(bgView);
    [bgView setBackgroundColor:[UIColor clearColor]];
    [bgView.layer setBorderWidth:(ISIPAD?4:2)];
    [bgView.layer setBorderColor:COLOR_YELLOW.CGColor];
    [cell.contentView insertSubview:bgView atIndex:0];
    cell.appNameLabel.textColor = COLOR_BROWN;
    cell.appDescriptionLabel.textColor = COLOR_BROWN;
    cell.rewardCurrencyCountLabel.textColor = COLOR_BROWN;
    return cell;
}

- (void)setAppImageWithURLStr:(NSString*)urlStr
{
    self.appImageView.alpha = 0;
    
//    [self.appImageView setImageWithURL:[NSURL URLWithString:urlStr]
//                      placeholderImage:nil
//                               success:^(UIImage *image, BOOL cached) {
//                                   if (!cached) {
//                                       [UIView animateWithDuration:1 animations:^{
//                                           self.appImageView.alpha = 1.0;
//                                       }];
//                                   }else{
//                                       self.appImageView.alpha = 1.0;
//                                   }
//                               }
//                               failure:^(NSError *error) {
//                                   self.appImageView.alpha = 1;
//                               }];
    
    [self.appImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        if (error == nil) {
            if (cacheType == SDImageCacheTypeNone) {
               [UIView animateWithDuration:1 animations:^{
                   self.appImageView.alpha = 1.0;
               }];
            }else{
               self.appImageView.alpha = 1.0;
            }

        }else{
            self.appImageView.alpha = 1;
        }
    }];
    
    
    
    [self.appImageView.layer setCornerRadius:self.appImageView.frame.size.width*0.1];
    [self.appImageView.layer setMasksToBounds:YES];
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
    
    
    [self.appNameLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbAppReward.app.name]];
    [self.appDescriptionLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbAppReward.app.desc]];
    [self.rewardCurrencyCountLabel setText:[NSString stringWithFormat:@"+%d", pbAppReward.rewardAmount]];
    
    [self.appDescriptionLabel setHidden:NO];
    [self.rewardCurrencyCountLabel setHidden:NO];
    [self.customAccessoryImageView setHidden:YES];

}

- (void)setCellWithPBRewardWall:(PBRewardWall*)pbRewardWall
{
    [self setAppImageWithURLStr:pbRewardWall.logo];
    [self.appNameLabel setText:[self getCurrentLolalizeStringFromPbLocalizeStringList:pbRewardWall.name]];
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

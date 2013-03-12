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
    return 62.0;
}

+ (id)createCell:(id)delegate
{
    return [self createView];
}

- (void)setCellWithPBAppReward:(PBAppReward*)pbAppReward
{
    self.appImageView.alpha = 0;
    [self.appImageView setImageWithURL:[NSURL URLWithString:pbAppReward.app.logo]
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

- (void)setCellWithPBRewardWall:(PBRewardWall*)pbRewardWall
{
    
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
    [super dealloc];
}
@end

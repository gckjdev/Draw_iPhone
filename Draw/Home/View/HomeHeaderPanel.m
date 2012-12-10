//
//  HomeHeaderView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeHeaderPanel.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "LevelService.h"
#import "AccountManager.h"
#import "AccountService.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeHeaderPanel ()
{
    
}
@property (retain, nonatomic) IBOutlet UIImageView *displayBG;
@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UIButton *coin;
@property (retain, nonatomic) IBOutlet UILabel *level;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;
- (IBAction)clickChargeButton:(id)sender;

@end

@implementation HomeHeaderPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    NSString* identifier = [HomeHeaderPanel getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    HomeCommonView<HomeCommonViewProtocol> *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
}

+ (NSString *)getViewIdentifier
{
    if (gameAppType() == GameAppTypeDraw) {
        return @"DrawHomeHeaderPanel";
    } else if (gameAppType() == GameAppTypeZJH) {
        return @"ZJHHomeHeaderPanel";
    }
    return nil;
}


- (void)updateView
{
    self.backgroundColor = [UIColor clearColor];
    
    //avatar
    [self.avatar.layer setMasksToBounds:YES];
    [self.avatar.layer setCornerRadius:(self.avatar.frame.size.width / 2)];
    [self.avatar.layer setBorderWidth:3];
    UIColor *borderColor = [UIColor colorWithRed:131./225 green:200./225 blue:43./225 alpha:1];
    [self.avatar.layer setBorderColor:borderColor.CGColor];
    
    
    UserManager *userManager = [UserManager defaultManager];
    if ([userManager avatarImage]) {
        [self.avatar setImage:[userManager avatarImage]];
    }else if([[userManager avatarURL] length] != 0){
        [self.avatar setImageWithURL:[NSURL URLWithString:[userManager avatarURL]]];
    }
    
    //nick
    [self.nickName setText:userManager.nickName];

    //level
    NSInteger level = [[LevelService defaultService] level];
    [self.level setText:[NSString stringWithFormat:@"LV %d",level]];
    
    //coin
    NSInteger coin = [[AccountManager defaultManager] account].balance.intValue;
    NSString *coinString = [NSString stringWithFormat:@"%d",coin];
    [self.coin setTitle:coinString forState:UIControlStateNormal];
    
    //charge button
}

- (void)dealloc {
    PPRelease(_displayBG);
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_coin);
    PPRelease(_level);
    PPRelease(_chargeButton);
    [super dealloc];
}
- (IBAction)clickChargeButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickChargeButton:)]) {
        [self.delegate didClickChargeButton:sender];
    }
}
@end

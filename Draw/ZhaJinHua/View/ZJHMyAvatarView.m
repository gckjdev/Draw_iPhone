//
//  ZJHMyAvatarView.m
//  Draw
//
//  Created by Kira on 12-11-3.
//
//

#import "ZJHMyAvatarView.h"
#import "AccountService.h"
#import "LevelService.h"
#import "ZJHGameService.h"
#import "UserManager.h"
#import "ZJHImageManager.h"

@implementation ZJHMyAvatarView

@synthesize levelLabel = _levelLabel;
@synthesize coinsLabel = _coinsLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)createAvatarView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ZJHMyAvatarView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (ZJHMyAvatarView*)createZJHMyAvatarView
{
    ZJHMyAvatarView* view = [ZJHMyAvatarView createAvatarView];
    
    view.roundAvatar = [[[DiceAvatarView alloc] initWithFrame:view.roundAvatarPlaceView.frame] autorelease];
    [view sendSubviewToBack:view.roundAvatar];
    //        _roundAvatar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [view.roundAvatar setProgressBarWidth:0.07];
    [view addSubview:view.roundAvatar];
    view.roundAvatar.delegate = view;
    
    [view addTapGuesture];
    view.coinsImageView.hidden = YES;
    
    return view;
}

- (void)resetAvatar
{
    [super resetAvatar];

    [self.backgroundImageView setImage:[ZJHImageManager defaultManager].noUserBigAvatarBackground];
    
    [self.levelLabel setText:nil];
    [self.coinsLabel setText:nil];
    self.coinsImageView.hidden = YES;
}

// 别人的头像用这个方法。
- (void)updateByPBGameUser:(PBGameUser *)user
{
    [super updateByPBGameUser:user];
    
    if ([[UserManager defaultManager] isMe:user.userId]) {
        [self update];
    }else{
        self.coinsImageView.hidden = NO;
        [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",[[ZJHGameService defaultService] levelOfUser:user.userId]]];
        [self.coinsLabel setText:[NSString stringWithFormat:@"x%d",[[ZJHGameService defaultService] balanceOfUser:user.userId]]];
    }
}

// 自己的头像用这个方法。
- (void)update{
    self.coinsImageView.hidden = NO;
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",[[LevelService defaultService] levelForSource:LevelSourceZhajinhua]]];
    [self.coinsLabel setText:[NSString stringWithFormat:@"x%d",[ZJHGameService defaultService].myBalance]];
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
    [_levelLabel release];
    [_coinsLabel release];
    [_coinsImageView release];
    [super dealloc];
}
@end

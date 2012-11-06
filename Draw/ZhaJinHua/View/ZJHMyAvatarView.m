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

@implementation ZJHMyAvatarView

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
    [view addSubview:view.roundAvatar];
    view.roundAvatar.delegate = view;
    
    [view addTapGuesture];
    
    return view;
}

- (void)resetAvatar
{

}


- (void)update{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",[LevelService defaultService].level]];
    [self.coinsLabel setText:[NSString stringWithFormat:@"X%d",[AccountService defaultService].getBalance]];
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
    [super dealloc];
}
@end

//
//  TopPlayerView.m
//  Draw
//
//  Created by  on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopPlayerView.h"
#import "ShareImageManager.h"
#import "PPApplication.h"
#import "HJManagedImageV.h"

@implementation TopPlayerView
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize levelInfo = _levelInfo;
@synthesize maskButton = _maskButton;
@synthesize topPlayer = _topPlayer;
@synthesize delegate = _delegate;

+ (id)createTopPlayerView:(id)delegate
{
    NSString* identifier = @"TopPlayerView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    TopPlayerView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    
    UIImage *selectedImage = [[ShareImageManager defaultManager] 
                              normalButtonImage];
//    view.maskButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    view.maskButton.frame = view.bounds;
    [view addSubview:view.maskButton];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateHighlighted];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateSelected];
    [view.maskButton setAlpha:0.8];
    return view;
}



- (void)setViewInfo:(TopPlayer *)player
{
    if (player == nil) {
        self.hidden = YES;
        return;
    }
    self.topPlayer = player;

    [self.avatar clear];
    if([_topPlayer.avatar length] != 0){
        [self.avatar setUrl:[NSURL URLWithString:_topPlayer.avatar]];
    } else{
        UIImage *image = nil;
        if (player.gender) {
            image = [[ShareImageManager defaultManager] maleDefaultAvatarImage];
        }else{
            image = [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
        }
        [self.avatar setImage:image];
    }
    [GlobalGetImageCache() manage:self.avatar];
    if (player.nickName) {
        NSString *nick = [NSString stringWithFormat:@" %@",player.nickName];
        //        [self.author setText:author];
        [self.nickName setText:nick];        
    }else{
        self.nickName.hidden = YES;
    }

    NSString *level = nil;
    NSString *genderString = player.gender ? NSLS(@"kMale") :NSLS(@"kFemale");
    
    level = [NSString stringWithFormat:@" %@  LV.%d",genderString, player.level];
    [self.levelInfo setText:level];
    
//    [self.maskButton addTarget:self action:@selector(didClickTopPlayerView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setRankFlag:(NSInteger)rank
{
    
}

- (void)setViewSeleted:(BOOL)selected
{
    self.maskButton.selected = selected;
    [self bringSubviewToFront:self.maskButton];
}

- (IBAction)clickPlayerView:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickTopPlayerView:)]){
        [self.delegate didClickTopPlayerView:self];
    }
}

+ (CGFloat)getHeight
{
    return ([DeviceDetection isIPAD] ? 255 : 106);
}

- (void)dealloc {
    PPRelease(_maskButton);
    PPRelease(_nickName);
    PPRelease(_levelInfo);
    PPRelease(_topPlayer);
    PPRelease(_avatar);
    [super dealloc];
}
@end

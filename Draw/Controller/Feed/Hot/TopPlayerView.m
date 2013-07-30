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
//#import "HJManagedImageV.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Extend.h"

@implementation TopPlayerView
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
//@synthesize levelInfo = _levelInfo;
@synthesize maskButton = _maskButton;
@synthesize cupImage = _cupImage;
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
                              highlightMaskImage];
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
    
    // set avatar image
    NSURL* url = [NSURL URLWithString:player.avatar];
    UIImage *placeHolderImage = [[ShareImageManager defaultManager] avatarImageByGender:player.gender];
    [self.avatar setImageWithUrl:url placeholderImage:placeHolderImage showLoading:YES animated:YES];

    // set nick name
    if (player.nickName) {
        NSString *nick = [NSString stringWithFormat:@" %@",player.nickName];
        //        [self.author setText:author];
        [self.nickName setText:nick];        
    }else{
        self.nickName.hidden = YES;
    }
    
    [self.genderImageView setImage:[[ShareImageManager defaultManager] userDetailGenderImage:player.gender]];
}

- (void)setRankFlag:(NSInteger)rank
{
    [self.cupImage setHidden:NO];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (rank) {
        case CupTyeGolden:
            [self.cupImage setImage:[imageManager goldenCupImage]];
             return;
        case CupTyeCopper:
            [self.cupImage setImage:[imageManager copperCupImage]];
            return;
        case CupTypeSilver:
            [self.cupImage setImage:[imageManager silverCupImage]];
            return;
        default:
            [self.cupImage setHidden:NO];
            return;
    }
    
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
    return ([DeviceDetection isIPAD] ? 256 : 106);
}

- (void)dealloc {
    PPRelease(_maskButton);
    PPRelease(_nickName);
//    PPRelease(_levelInfo);
    PPRelease(_topPlayer);
    PPRelease(_avatar);
    PPRelease(_cupImage);
    [_genderImageView release];
    [super dealloc];
}

@end

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
#import "UIImageView+WebCache.h"
#import "UIImageView+Extend.h"

@implementation TopPlayerView
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize maskControl = _maskControl;
@synthesize cupImage = _cupImage;
@synthesize topPlayer = _topPlayer;
@synthesize delegate = _delegate;

+ (id)createTopPlayerView:(id)delegate
{
    NSString* identifier = @"TopPlayerView";
    TopPlayerView *view = [self createViewWithXibIdentifier:identifier];
    [view setClipsToBounds:YES];
    view.maskControl = [[[UIControl alloc] initWithFrame:view.bounds] autorelease];
    [view.maskControl addTarget:view action:@selector(clickPlayerView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:view.maskControl];
    view.delegate = delegate;
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
    self.maskControl.selected = selected;
    [self bringSubviewToFront:self.maskControl];
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
    PPRelease(_maskControl);
    PPRelease(_nickName);
//    PPRelease(_levelInfo);
    PPRelease(_topPlayer);
    PPRelease(_avatar);
    PPRelease(_cupImage);
    PPRelease(_genderImageView);
//    [_genderImageView release];
    [super dealloc];
}

@end

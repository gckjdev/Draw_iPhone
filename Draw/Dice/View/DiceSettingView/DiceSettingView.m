//
//  DiceSettingView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceSettingView.h"
#import "DiceImageManager.h"
#import "AudioManager.h"

@interface DiceSettingView ()

@end

@implementation DiceSettingView
@synthesize bgImageView;
@synthesize musicImageView;
@synthesize audioImageView;
@synthesize musicOnButton;
@synthesize musicOffButton;
@synthesize audioOnButton;
@synthesize audioOffButton;
@synthesize closeButton;

+ (id)createDiceSettingView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceSettingView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    bgImageView.image = [[DiceImageManager defaultManager] popupBackgroundImage];
    
    musicImageView.image = [[AudioManager defaultManager] isMusicOn] ? [[DiceImageManager defaultManager] diceMusicOnImage] : [[DiceImageManager defaultManager] diceMusicOffImage];
    
    audioImageView.image = [[AudioManager defaultManager] isSoundOn] ? [[DiceImageManager defaultManager] diceAudioOnImage] : [[DiceImageManager defaultManager] diceAudioOffImage];

    musicOnButton.selected = [[AudioManager defaultManager] isMusicOn];
    musicOffButton.selected = ![[AudioManager defaultManager] isMusicOn];
    
    audioOnButton.selected = [[AudioManager defaultManager] isSoundOn];
    audioOffButton.selected = ![[AudioManager defaultManager] isSoundOn];

    musicOnButton.titleLabel.textColor = [[AudioManager defaultManager] isMusicOn] ? [UIColor whiteColor] : [UIColor blackColor];
    musicOffButton.titleLabel.textColor = [[AudioManager defaultManager] isMusicOn] ? [UIColor blackColor] : [UIColor whiteColor];
    audioOnButton.titleLabel.textColor = [[AudioManager defaultManager] isSoundOn] ? [UIColor whiteColor] : [UIColor blackColor];
    audioOffButton.titleLabel.textColor = [[AudioManager defaultManager] isSoundOn] ? [UIColor blackColor] : [UIColor whiteColor];
    
    [view addSubview:self];
    [self appear];
}


- (void)dealloc {
    [bgImageView release];
    [musicOnButton release];
    [musicOffButton release];
    [audioOnButton release];
    [audioOffButton release];
    [musicImageView release];
    [audioImageView release];
    [closeButton release];
    [super dealloc];
}

- (IBAction)clickMusicOnButton:(id)sender {
    musicOnButton.selected = YES;
    musicOffButton.selected = NO;
    musicImageView.image = [[DiceImageManager defaultManager] diceMusicOnImage];
    musicOnButton.titleLabel.textColor = [UIColor whiteColor];
    musicOffButton.titleLabel.textColor = [UIColor blackColor];
    
    [[AudioManager defaultManager] setIsMusicOn:YES];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickMusicOffButton:(id)sender {
    musicOnButton.selected = NO;
    musicOffButton.selected = YES;
    musicImageView.image = [[DiceImageManager defaultManager] diceMusicOffImage];
    musicOnButton.titleLabel.textColor = [UIColor blackColor];
    musicOffButton.titleLabel.textColor = [UIColor whiteColor];
    
    [[AudioManager defaultManager] setIsMusicOn:NO];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickAudioOnButton:(id)sender {
    audioOnButton.selected = YES;
    audioOffButton.selected = NO;
    audioImageView.image = [[DiceImageManager defaultManager] diceAudioOnImage];
    audioOnButton.titleLabel.textColor = [UIColor whiteColor];
    audioOffButton.titleLabel.textColor = [UIColor blackColor];
    
    [[AudioManager defaultManager] setIsSoundOn:YES];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickAudioOffButton:(id)sender {
    audioOnButton.selected = NO;
    audioOffButton.selected = YES;
    audioImageView.image = [[DiceImageManager defaultManager] diceAudioOffImage];
    audioOnButton.titleLabel.textColor = [UIColor blackColor];
    audioOffButton.titleLabel.textColor = [UIColor whiteColor];
    
    [[AudioManager defaultManager] setIsSoundOn:NO];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickCloseButton:(id)sender {
    [self disappear];
}

@end

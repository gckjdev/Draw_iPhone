//
//  DiceSettingView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CommonSettingView.h"
#import "AudioManager.h"
#import "AutoCreateViewByXib.h"
#import "GameApp.h"
#import "ZJHImageManager.h"
#import "ShareImageManager.h"
#import "PPResourceService.h"

@interface CommonSettingView ()

@end

@implementation CommonSettingView
@synthesize bgImageView;
@synthesize musicImageView;
@synthesize audioImageView;
@synthesize musicOnButton;
@synthesize musicOffButton;
@synthesize audioOnButton;
@synthesize audioOffButton;
@synthesize closeButton;

AUTO_CREATE_VIEW_BY_XIB(CommonSettingView)
+ (id)createSettingView
{
    return [CommonSettingView createView];
}

- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    bgImageView.image = [[GameApp getImageManager] settingsBgImage];
    [self.closeButton setBackgroundImage:[[PPResourceService defaultService] imageByName:[getGameApp() popupViewCloseBtnBgImageName] inResourcePackage:[getGameApp() resourcesPackage]]  forState:UIControlStateNormal];
    
    musicImageView.image = [[AudioManager defaultManager] isMusicOn] ? [[GameApp getImageManager] musicOn] : [[GameApp getImageManager] musicOff];
    
    audioImageView.image = [[AudioManager defaultManager] isSoundOn] ? [[GameApp getImageManager] audioOn] : [[GameApp getImageManager] audioOff];

    musicOnButton.selected = [[AudioManager defaultManager] isMusicOn];
    musicOffButton.selected = ![[AudioManager defaultManager] isMusicOn];
    
    audioOnButton.selected = [[AudioManager defaultManager] isSoundOn];
    audioOffButton.selected = ![[AudioManager defaultManager] isSoundOn];

    musicOnButton.titleLabel.textColor = [[AudioManager defaultManager] isMusicOn] ? [UIColor whiteColor] : [UIColor blackColor];
    musicOffButton.titleLabel.textColor = [[AudioManager defaultManager] isMusicOn] ? [UIColor blackColor] : [UIColor whiteColor];
    audioOnButton.titleLabel.textColor = [[AudioManager defaultManager] isSoundOn] ? [UIColor whiteColor] : [UIColor blackColor];
    audioOffButton.titleLabel.textColor = [[AudioManager defaultManager] isSoundOn] ? [UIColor blackColor] : [UIColor whiteColor];
    
    [self.audioOnButton setBackgroundImage:[[GameApp getImageManager] settingsLeftSelected] forState:UIControlStateSelected];
    [self.audioOnButton setBackgroundImage:[[GameApp getImageManager] settingsLeftUnselected] forState:UIControlStateNormal];
    [self.audioOffButton setBackgroundImage:[[GameApp getImageManager] settingsRightSelected] forState:UIControlStateSelected];
    [self.audioOffButton setBackgroundImage:[[GameApp getImageManager] settingsRightUnselected] forState:UIControlStateNormal];
    [self.musicOnButton setBackgroundImage:[[GameApp getImageManager] settingsLeftSelected] forState:UIControlStateSelected];
    [self.musicOnButton setBackgroundImage:[[GameApp getImageManager] settingsLeftUnselected] forState:UIControlStateNormal];
    [self.musicOffButton setBackgroundImage:[[GameApp getImageManager] settingsRightSelected] forState:UIControlStateSelected];
    [self.musicOffButton setBackgroundImage:[[GameApp getImageManager] settingsRightUnselected] forState:UIControlStateNormal];
    
    
    [super showInView:view];
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
    musicImageView.image = [[GameApp getImageManager] musicOn];
    musicOnButton.titleLabel.textColor = [UIColor whiteColor];
    musicOffButton.titleLabel.textColor = [UIColor blackColor];
    
    [[AudioManager defaultManager] setIsMusicOn:YES];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickMusicOffButton:(id)sender {
    musicOnButton.selected = NO;
    musicOffButton.selected = YES;
    musicImageView.image = [[GameApp getImageManager] musicOff];
    musicOnButton.titleLabel.textColor = [UIColor blackColor];
    musicOffButton.titleLabel.textColor = [UIColor whiteColor];
    
    [[AudioManager defaultManager] setIsMusicOn:NO];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickAudioOnButton:(id)sender {
    audioOnButton.selected = YES;
    audioOffButton.selected = NO;
    audioImageView.image = [[GameApp getImageManager] audioOn];
    audioOnButton.titleLabel.textColor = [UIColor whiteColor];
    audioOffButton.titleLabel.textColor = [UIColor blackColor];
    
    [[AudioManager defaultManager] setIsSoundOn:YES];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickAudioOffButton:(id)sender {
    audioOnButton.selected = NO;
    audioOffButton.selected = YES;
    audioImageView.image = [[GameApp getImageManager] audioOff];
    audioOnButton.titleLabel.textColor = [UIColor blackColor];
    audioOffButton.titleLabel.textColor = [UIColor whiteColor];
    
    [[AudioManager defaultManager] setIsSoundOn:NO];
    [[AudioManager defaultManager] saveSoundSettings];
}

- (IBAction)clickCloseButton:(id)sender {
    [self disappear];
}

@end

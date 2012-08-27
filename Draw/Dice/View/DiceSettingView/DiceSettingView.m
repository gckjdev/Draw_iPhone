//
//  DiceSettingView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceSettingView.h"

@interface DiceSettingView ()

@end

@implementation DiceSettingView
@synthesize bgImageView;
@synthesize musicOnButton;
@synthesize musicOffButton;
@synthesize audioOnButton;
@synthesize audioOffButton;

+ (id)createDiceSettingView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceHelpView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];;
}



- (void)dealloc {
    [bgImageView release];
    [musicOnButton release];
    [musicOffButton release];
    [audioOnButton release];
    [audioOffButton release];
    [super dealloc];
}

- (IBAction)clickMusicOnButton:(id)sender {
    musicOnButton.selected = YES;
    musicOffButton.selected = NO;
    
    // TODO：music on settting
}

- (IBAction)clickMusicOffButton:(id)sender {
    musicOnButton.selected = NO;
    musicOffButton.selected = YES;
    
    // TODO：music off setting
}

- (IBAction)clickAudioOnButton:(id)sender {
    audioOnButton.selected = YES;
    audioOffButton.selected = NO;
    
    // TODO：audio on setting
}

- (IBAction)clickAudioOffButton:(id)sender {
    audioOnButton.selected = NO;
    audioOffButton.selected = YES;
    
    // TODO：audio off setting
}

- (IBAction)clickCloseButton:(id)sender {
    [self disappear];
}

@end

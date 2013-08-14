//
//  UIButton+Sound.m
//  Draw
//
//  Created by 王 小涛 on 13-8-14.
//
//

#import "UIButton+Sound.h"

@implementation UIButton (Sound)

- (void)registerSound:(NSString *)soundName{
    
    AudioManager* manager = [AudioManager defaultManager];
    
    if ([manager isButtonInPlaySoundList:self]){
        return;
    }
    
    [manager addButtonToPlaySoundList:self soundName:soundName];
    
    [self addTarget:[AudioManager defaultManager] action:@selector(playButtonSound:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)unregisterSound{
    
    AudioManager* manager = [AudioManager defaultManager];
    [manager removeButtonFromPlaySoundList:self];
}

@end

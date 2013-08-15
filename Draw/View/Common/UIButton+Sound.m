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
        PPDebug(@"<registerSound> button(%d), sound(%@) but already registered", self.tag, soundName);
        return;
    }
    
    [manager addButtonToPlaySoundList:self soundName:soundName];
    
    [self addTarget:[AudioManager defaultManager] action:@selector(playButtonSound:) forControlEvents:UIControlEventTouchUpInside];
    
    PPDebug(@"<registerSound> button(%d), sound(%@)", self.tag, soundName);
}

- (void)unregisterSound{
    
    AudioManager* manager = [AudioManager defaultManager];
    [manager removeButtonFromPlaySoundList:self];

    PPDebug(@"<unregisterSound> for button(%d)", self.tag);
}

@end

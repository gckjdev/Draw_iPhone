//
//  UIButton+Sound.h
//  Draw
//
//  Created by 王 小涛 on 13-8-14.
//
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"

@interface UIButton (Sound)

- (void)registerSound:(NSString *)soundName;
- (void)unregisterSound;

@end

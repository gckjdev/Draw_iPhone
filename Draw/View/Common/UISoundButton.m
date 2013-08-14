//
//  UISoundButton.m
//  Draw
//
//  Created by 王 小涛 on 13-8-14.
//
//

#import "UISoundButton.h"

@implementation UISoundButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSoundEnabled:(BOOL)soundEnabled{
    
    _soundEnabled = soundEnabled;

}

@end

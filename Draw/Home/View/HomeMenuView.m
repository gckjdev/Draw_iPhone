//
//  HomeMenuView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMenuView.h"

@implementation HomeMenuView

- (void)updateIcon:(UIImage *)icon
             title:(NSString *)title
               tag:(NSInteger)tag
{
    [self.button setImage:icon forState:UIControlStateNormal];
    [self.button setTitle:title forState:UIControlStateNormal];
    [self setTag:tag];
}


- (void)dealloc {
    [_button release];
    [super dealloc];
}

- (IBAction)clickButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenu:tag:)]) {
        [self.delegate didClickMenu:self tag:self.tag];
    }
}
@end

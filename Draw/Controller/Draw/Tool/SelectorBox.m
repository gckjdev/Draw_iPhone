//
//  SelectorBox.m
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import "SelectorBox.h"

@implementation SelectorBox

- (void)updateViews
{
    
}

+ (id)selectorBoxWithDelegate:(id<SelectorBoxDelegate>)delegate
{
    NSUInteger index = ISIPAD ? 1 : 0;
    SelectorBox *box = [UIView createViewWithXibIdentifier:@"SelectorBox" ofViewIndex:index];
    box.delegate = delegate;
    [box updateViews];
    return box;
}
- (IBAction)clickSelector:(UIButton *)sender {
}

- (IBAction)clickCancel:(id)sender {
}

- (IBAction)clickHelp:(id)sender {
}

@end

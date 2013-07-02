//
//  ShowCopyPaintCommand.m
//  Draw
//
//  Created by Kira on 13-6-26.
//
//

#import "ShowCopyPaintCommand.h"

@implementation ShowCopyPaintCommand

- (BOOL)execute
{
    if ([self canUseItem:self.itemType]) {
        [self sendAnalyticsReport];
        [self.toolHandler handleShowCopyPaint];
        return YES;
    }
    return NO;
}

@end

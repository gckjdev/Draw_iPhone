//
//  ShowCopyPaintCommand.m
//  Draw
//
//  Created by Kira on 13-6-26.
//
//

#import "ShowCopyPaintCommand.h"
#import "OfflineDrawViewController.h"

@implementation ShowCopyPaintCommand

- (BOOL)execute
{
    if ([self canUseItem:self.itemType]) {
        OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
        [oc showCopyPaint];
        return YES;
    }
    return NO;
}

@end

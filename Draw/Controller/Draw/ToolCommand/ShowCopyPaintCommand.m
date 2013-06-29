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
    [self.toolHandler handleShowCopyPaint];
    return YES;
}

@end

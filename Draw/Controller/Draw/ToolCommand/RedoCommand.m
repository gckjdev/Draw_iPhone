//
//  RedoCommand.m
//  Draw
//
//  Created by gamy on 13-3-30.
//
//

#import "RedoCommand.h"

@implementation RedoCommand

- (BOOL)execute
{
    [self.toolHandler handleRedo];
    return YES;
}

@end


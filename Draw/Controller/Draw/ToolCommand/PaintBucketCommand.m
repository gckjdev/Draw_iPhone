//
//  PaintBucketCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "PaintBucketCommand.h"

@implementation PaintBucketCommand

- (BOOL)execute
{
    [self.toolHandler usePaintBucket];
    return YES;
}

@end

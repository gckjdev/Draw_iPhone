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
//    if ([super execute]) {
        [self.toolHandler usePaintBucket];
        return YES;
//    }
//    return NO;
}

@end

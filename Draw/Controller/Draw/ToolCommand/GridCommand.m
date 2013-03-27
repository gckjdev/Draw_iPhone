//
//  GridCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "GridCommand.h"

@implementation GridCommand

- (BOOL)execute{
    [self.toolHandler useGid:!self.toolHandler.grid];
    return YES;
}

@end

//
//  FXCommand.m
//  Draw
//
//  Created by gamy on 13-7-13.
//
//

#import "FXCommand.h"
#import "PPViewController.h"

@implementation FXCommand

- (BOOL)execute
{
    POSTMSG(NSLS(@"kFurtureFunction"));
    return YES;
}

@end

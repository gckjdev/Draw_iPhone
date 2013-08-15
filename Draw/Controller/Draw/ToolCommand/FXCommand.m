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
    PPViewController *vc = (id)[self controller];
    [vc popupHappyMessage:NSLS(@"kFurtureFunction") title:nil];
    return YES;
}

@end

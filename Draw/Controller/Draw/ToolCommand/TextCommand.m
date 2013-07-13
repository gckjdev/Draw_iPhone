//
//  TextCommand.m
//  Draw
//
//  Created by gamy on 13-7-13.
//
//

#import "TextCommand.h"
#import "UIViewUtils.h"
#import "PPViewController.h"

@implementation TextCommand

- (BOOL)execute
{
    PPViewController *vc = (id)[self theViewController];
    [vc popupHappyMessage:NSLS(@"kFurtureFunction") title:nil];
    return YES;
}

@end

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
    POSTMSG(NSLS(@"kFurtureFunction"));
    return YES;
}

@end

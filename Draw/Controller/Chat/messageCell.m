//
//  MessageCell.m
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "MessageCell.h"
#import "DeviceDetection.h"
#import "PPDebug.h"

#define HEIGHT_CELL_IPHONE 40
#define HEIGHT_CELL_IPAD ((HEIGHT_CELL_IPHONE)*2.0)
#define HEIGHT_CELL ([DeviceDetection isIPAD] ? (HEIGHT_CELL_IPAD) : (HEIGHT_CELL_IPHONE))

#define TAG_MESSAGE_BUTTON1 101
#define TAG_MESSAGE_BUTTON2 102
#define TAG_MESSAGE_BUTTON3 103

@interface MessageCell ()

@end

@implementation MessageCell

@synthesize messageCellDelegate;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    PPDebug(@"<MessageCell>cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"<MessageCell>create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"MessageCell";
}

+ (CGFloat)getCellHeight
{
    return HEIGHT_CELL;
}

- (void)setCellData:(NSArray*)messageArray
{   
    int tag = TAG_MESSAGE_BUTTON1;
    for (NSString *message in messageArray) {
        if (tag > TAG_MESSAGE_BUTTON3) {
            break;
        }
        
        UIButton *button = (UIButton*)[self viewWithTag:tag++];
        button.hidden = NO;
        [button setTitle:message forState:UIControlStateNormal];
    }
}

- (IBAction)clickMessage:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *message = [button titleForState:UIControlStateNormal];
    if (messageCellDelegate && [messageCellDelegate respondsToSelector:@selector(didSelectMessage:)]) {
        [messageCellDelegate didSelectMessage:message];
    }
}

@end

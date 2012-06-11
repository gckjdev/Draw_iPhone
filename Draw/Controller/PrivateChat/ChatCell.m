//
//  ChatCell.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatCell.h"
#import "LogUtil.h"
#import "DeviceDetection.h"

@implementation ChatCell
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize graffiti;
@synthesize messageNumberLabel;
@synthesize timeLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((ChatCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"ChatCell";
}


#define CELL_HEIGHT_IPHONE  68
#define CELL_HEIGHT_IPAD    164
+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]) {
        return CELL_HEIGHT_IPAD;
    }else {
        return CELL_HEIGHT_IPHONE;
    }
}

- (void)dealloc {
    [avatarImage release];
    [nickNameLabel release];
    [graffiti release];
    [messageNumberLabel release];
    [timeLabel release];
    [super dealloc];
}
@end

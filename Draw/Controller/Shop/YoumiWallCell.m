//
//  YoumiWallCell.m
//  Draw
//
//  Created by  on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YoumiWallCell.h"
#import "PPDebug.h"
#import "DeviceDetection.h"

@implementation YoumiWallCell
@synthesize appNameLabel;
@synthesize rewardDescLabel;
@synthesize rewardCoinsLabel;
@synthesize appImageView;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}


+ (NSString*)getCellIdentifier
{
    return @"YoumiWallCell";
}

+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]){
        return 82*2;
    }
    else{
        return 82;
    }
}

- (void)dealloc
{
    [appNameLabel release];
    [rewardDescLabel release];
    [rewardCoinsLabel release];
    [appImageView release];
    [super dealloc];
}

@end

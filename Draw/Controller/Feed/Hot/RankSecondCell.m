//
//  RankSecondCell.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RankSecondCell.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"

@implementation RankSecondCell
@synthesize secondDrawImage;
@synthesize thirdDrawImage;
@synthesize secondTitle;
@synthesize secondAuthor;
@synthesize thirdTitle;
@synthesize thirdAuthor;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"RankSecondCell";
}

+ (CGFloat)getCellHeight
{
    return 167.0f;
}

- (void)dealloc {
    [secondDrawImage release];
    [thirdDrawImage release];
    [secondTitle release];
    [secondAuthor release];
    [thirdTitle release];
    [thirdAuthor release];
    [super dealloc];
}
@end

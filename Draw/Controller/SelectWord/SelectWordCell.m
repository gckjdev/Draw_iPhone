//
//  SelectWordCell.m
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectWordCell.h"
#import "Word.h"
#import "WordManager.h"

@implementation SelectWordCell
@synthesize wordLabel;
@synthesize levelLabel;
@synthesize scoreLabel;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"SelectWordCell";
}

+ (CGFloat)getCellHeight
{
    return 44.0f;
}

- (void)setCellInfo:(Word *)word
{
    NSString *score = [NSString stringWithFormat:@"%d",word.score];
    [self.wordLabel setText:word.text];
    [self.levelLabel setText:word.levelDesc];
    [self.scoreLabel setText:score];
}

- (void)dealloc {
    [wordLabel release];
    [levelLabel release];
    [scoreLabel release];
    [super dealloc];
}
@end

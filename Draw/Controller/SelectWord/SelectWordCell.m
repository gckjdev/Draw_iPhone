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
#import "ShareImageManager.h"
#import "DeviceDetection.h"

@implementation SelectWordCell
@synthesize wordLabel;
@synthesize levelLabel;
@synthesize backgroundImage;
@synthesize scoreLabel;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
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

#define CELL_HEIGHT ([DeviceDetection isIPAD] ? 180 : 74)
+ (CGFloat)getCellHeight
{
    return CELL_HEIGHT;
}

- (void)setCellInfo:(Word *)word
{
    NSString *score = [NSString stringWithFormat:@"X%d",word.score];
    
    NSString *text = word.text;
    if ([LocaleUtils isTraditionalChinese]) {
        text = [WordManager changeToTraditionalChinese:text];
    }
    
    [self.wordLabel setText:text];
    [self.levelLabel setText:word.levelDesc];
    [self.scoreLabel setText:score];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (word.level) {
        case WordLevelLow:
            [self.backgroundImage setImage:[imageManager pickEasyWordCellImage]];
            break;
        case WordLeveLMedium:
            [self.backgroundImage setImage:[imageManager pickNormakWordCellImage]];
            break;
        case WordLevelHigh:
            [self.backgroundImage setImage:[imageManager pickHardWordCellImage]];
        default:
            break;
    }
}

- (void)dealloc {
    PPRelease(wordLabel);
    PPRelease(levelLabel);
    PPRelease(scoreLabel);
    PPRelease(backgroundImage);
    [super dealloc];
}
@end

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
    SelectWordCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier]];
    cell.delegate = delegate;
    cell.wordLabel.textColor = COLOR_BROWN;
    cell.scoreLabel.textColor = COLOR_BROWN;
    cell.levelLabel.textColor = COLOR_BROWN;
    [cell.backgroundImage setImage:nil];
    SET_VIEW_ROUND_CORNER(cell.backgroundImage);
    cell.backgroundImage.layer.borderWidth = (ISIPAD ? 4 : 2);
    cell.backgroundImage.layer.borderColor = [COLOR_YELLOW CGColor];
    cell.backgroundImage.backgroundColor = [UIColor clearColor];
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"SelectWordCell";
}

#define CELL_HEIGHT ([DeviceDetection isIPAD] ? 180 : 80)
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
    return;
    
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

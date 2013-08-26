//
//  ContestPrizeCell.m
//  Draw
//
//  Created by gamy on 13-8-26.
//
//

#import "ContestPrizeCell.h"

@implementation ContestPrizeCell

+ (id)createCell:(id)delegate
{
    ContestPrizeCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier]];
    cell.delegate = delegate;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"ContestPrizeCell";
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD ? 280: 140);
}



- (void)dealloc {
    [_opusImage release];
    [_prizeIcon release];
    [_nickButton release];
    [_avatar release];
    [super dealloc];
}
- (IBAction)clickNickButton:(id)sender {
    
}

- (void)setPrize:(ContestPrize)prize
           title:(NSString *)title
            opus:(ContestFeed *)opus
{
    
}

@end

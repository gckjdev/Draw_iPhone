//
//  GridCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "GridCommand.h"

@implementation GridCommand


- (void)handleGrid
{
    [self.drawInfo setGrid:!self.drawInfo.grid];
    [self.drawView.currentLayer setNeedsDisplay];
}

- (BOOL)execute{
    if ([super execute]) {
        [self handleGrid];
        return YES;
    }else{
        return NO;
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self handleGrid];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_GRID);
}


@end

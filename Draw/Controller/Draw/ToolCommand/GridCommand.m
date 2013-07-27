//
//  GridCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "GridCommand.h"

@implementation GridCommand

- (BOOL)execute{
    if ([super execute]) {
        [self.drawInfo setGrid:!self.drawInfo.grid];
        return YES;
    }else{
        return NO;
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.drawInfo setGrid:!self.drawInfo.grid];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_GRID);
}


@end

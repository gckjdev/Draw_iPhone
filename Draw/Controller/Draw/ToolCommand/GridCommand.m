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
        [self.toolHandler useGid:!self.toolHandler.grid];
        return YES;
    }else{
        return NO;
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.toolHandler useGid:!self.toolHandler.grid];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_GRID);
}


@end

//
//  PaintBucketCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "PaintBucketCommand.h"

@implementation PaintBucketCommand

- (BOOL)execute
{
    [self becomeActive];    
    [self.toolHandler usePaintBucket];
    if (self.toolHandler.touchActionType == TouchActionTypeShape) {
        [self.toolHandler enterShapeMode];
    }else{
        [self.toolHandler enterDrawMode];
    }

    return YES;
}

- (void)showPopTipView
{
    
}

- (void)hidePopTipView
{
    
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_PAINT_BUCKET);
}

@end

//
//  PaintBucketCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "PaintBucketCommand.h"
#import "CommonDialog.h"

@implementation PaintBucketCommand


- (void)changeBG
{
    [self becomeActive];
    [self.toolHandler usePaintBucket];
    if (self.toolHandler.touchActionType == TouchActionTypeShape) {
        [self.toolHandler enterShapeMode];
    }else{
        [self.toolHandler enterDrawMode];
    }
}
- (BOOL)execute
{
    DrawAction *lastDrawAction = [self.toolHandler.drawView lastAction];
    if (lastDrawAction && ![lastDrawAction isKindOfClass:[ChangeBackAction class]]) {
        [[CommonDialog createDialogWithTitle:NSLS(@"kChangeBackgroundTitle") message:NSLS(@"kChangeBackgroundMessage")
                                      style:CommonDialogStyleDoubleButton
                                   delegate:nil
                               clickOkBlock:^{
            [self changeBG];
        } clickCancelBlock:NULL]
         showInView:[self.control theTopView]];
    
        
    }else{
        [self changeBG];        
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

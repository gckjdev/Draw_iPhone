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
    bgAction = [ChangeBackAction actionWithColor:self.drawInfo.penColor];
    [self.drawView addDrawAction:bgAction show:YES];
    [self.drawView finishLastAction:bgAction refresh:NO];
    [self sendAnalyticsReport];
}


- (BOOL)execute
{
    DrawAction *lastDrawAction = [self.toolHandler.drawView lastAction];
    if (lastDrawAction && ![lastDrawAction isKindOfClass:[ChangeBackAction class]] && !self.toolHandler.drawView.currentClip) {
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

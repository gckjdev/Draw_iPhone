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
    DrawColor *color = [DrawColor colorWithColor:self.drawInfo.penColor];
    [color setAlpha:1];
    ChangeBackAction *bgAction = [ChangeBackAction actionWithColor:color];
    [self.drawView addDrawAction:bgAction show:YES];
    [self.drawView finishLastAction:bgAction refresh:NO];
    
    [self sendAnalyticsReport];
}


- (BOOL)execute
{
    DrawAction *lastDrawAction = [self.drawView lastAction];
    
    if (lastDrawAction && ![lastDrawAction isChangeBGAction] && ![lastDrawAction isClipAction] && lastDrawAction.clipAction == nil) {
        [[CommonDialog createDialogWithTitle:NSLS(@"kChangeBackgroundTitle") message:NSLS(@"kChangeBackgroundMessage")
                                      style:CommonDialogStyleDoubleButton
                                   delegate:nil
                               clickOkBlock:^{
            [self changeBG];
        } clickCancelBlock:NULL]
         showInView:[self.controller view]];
        
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

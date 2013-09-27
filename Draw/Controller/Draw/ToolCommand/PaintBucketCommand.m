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
    [self changeBG];
    
    /*
    // rem by Benson 2013-09-23 to support design simple animation
    DrawAction *lastDrawAction = [self.drawView lastAction];
    if (lastDrawAction && ![lastDrawAction isChangeBGAction] && ![lastDrawAction isClipAction] && lastDrawAction.clipAction == nil) {
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kChangeBackgroundTitle") message:NSLS(@"kChangeBackgroundMessage")
                                       style:CommonDialogStyleDoubleButton];
        [dialog setClickOkBlock:^(UILabel *label){
                [self changeBG];
        }];
        
        [dialog showInView:[self.controller view]];

        
    }else{
        [self changeBG];        
    }
    */
    
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

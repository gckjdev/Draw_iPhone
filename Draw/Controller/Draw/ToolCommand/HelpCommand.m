//
//  HelpCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "HelpCommand.h"
#import "CommonDialog.h"
#import "UIColor+UIColorExt.h"
#import "ShareImageManager.h"

#define VALUE(X) (ISIPAD ? 2*X : X)
#define WIDTH ([LocaleUtils isChinese] ? VALUE(180) : VALUE(230))
#define HEIGHT VALUE(200)
#define FONT_SIZE VALUE(16)

@implementation HelpCommand

- (BOOL)execute
{
    [[CommonDialog createDialogWithTitle:NSLS(@"kGestureExplain") message:NSLS(@"kGestureExplainContent") style:CommonDialogStyleCross] showInView:[self.controller view]];
    
    [self sendAnalyticsReport];
    
    return YES;
}
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_HELP);
}


@end

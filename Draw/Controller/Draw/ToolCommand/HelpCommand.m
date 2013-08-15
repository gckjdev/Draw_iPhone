//
//  HelpCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "HelpCommand.h"
#import "CustomInfoView.h"
#import "UIColor+UIColorExt.h"
#import "ShareImageManager.h"

#define VALUE(X) (ISIPAD ? 2*X : X)
#define WIDTH ([LocaleUtils isChinese] ? VALUE(180) : VALUE(230))
#define HEIGHT VALUE(200)
#define FONT_SIZE VALUE(16)

@implementation HelpCommand

- (BOOL)execute
{
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)] autorelease];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:COLOR_COFFEE];
    UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    [label setFont:font];
    [label setText:NSLS(@"kGestureExplainContent")];
    CustomInfoView *info = [CustomInfoView createWithTitle:NSLS(@"kGestureExplain") infoView:label];
    
    [info.mainView updateCenterY:(info.mainView.center.y - (ISIPAD ? 40 : 20))];
    
    [info showInView:[self.control theTopView]];
    
    [self sendAnalyticsReport];
    
    return YES;
}
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_HELP);
}


@end

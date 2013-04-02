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

#define VALUE(X) (ISIPAD ? 2*X : X)
#define WIDTH VALUE(180)
#define HEIGHT VALUE(200)
#define FONT_SIZE VALUE(16)

@implementation HelpCommand

- (BOOL)execute
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)] autorelease];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:OPAQUE_COLOR(62, 43, 23)];
    UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    [label setFont:font];
    [label setText:NSLS(@"kGestureExplainContent")];
    CustomInfoView *info = [CustomInfoView createWithTitle:NSLS(@"kGestureExplain") infoView:label];
    [info showInView:[self.control theTopView]];
    return YES;
}
-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_HELP);
}


@end

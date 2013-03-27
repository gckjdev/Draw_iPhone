//
//  DrawToCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "DrawToCommand.h"

@implementation DrawToCommand

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


@end

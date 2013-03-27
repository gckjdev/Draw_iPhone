//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"

@implementation EditDescCommand


-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_EDIT_DESC);
}

@end

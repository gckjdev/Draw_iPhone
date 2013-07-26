//
//  DrawInfo.m
//  Draw
//
//  Created by gamy on 13-7-26.
//
//

#import "DrawInfo.h"



@implementation DrawInfo

- (void)dealloc
{
    PPRelease(_shadow);
    PPRelease(_penColor);
    PPRelease(_bgColor);
    PPRelease(_gradient);
    [super dealloc];
}

@end



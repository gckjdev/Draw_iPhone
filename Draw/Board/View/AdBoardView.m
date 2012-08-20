//
//  AdBoardView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdBoardView.h"
#import "AdService.h"
@implementation AdBoardView


- (id)initWithBoard:(Board *)board
{
    self = [super initWithBoard:board];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [[AdService defaultService] createLmAdInView:self frame:CGRectMake(0, 0, 200, 50) iPadFrame:CGRectMake(0, 0, 0, 0)];
    [[AdService defaultService] createLmAdInView:self frame:CGRectMake(0, 100, 200, 50) iPadFrame:CGRectMake(0, 0, 0, 0)];
}

@end

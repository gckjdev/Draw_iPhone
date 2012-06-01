//
//  PickPenView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickPenView.h"

@implementation PickPenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _penArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_penArray release];
    [super dealloc];
}

- (void)setPens:(NSArray *)pens
{
    
}
@end

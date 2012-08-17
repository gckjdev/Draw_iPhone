//
//  ImageBoardView.m
//  Draw
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageBoardView.h"

@implementation ImageBoardView

- (id)initWithBoard:(Board *)board
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)loadView
{
    //should be override by the sub classes.
}



@end

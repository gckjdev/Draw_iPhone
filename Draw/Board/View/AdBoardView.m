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
            
    [[AdService defaultService] createAdInView:self 
                                adPlatformType:AdPlatformAder 
                                 adPublisherId:@"3b47607e44f94d7c948c83b7e6eb800e" 
                                         frame:CGRectMake(0, 0, 200, 50) 
                                     iPadFrame:CGRectMake(0, 0, 0, 0)];
    
    [[AdService defaultService] createAdInView:self 
                                adPlatformType:AdPlatformLm
                                 adPublisherId:@"eb4ce4f0a0f1f49b6b29bf4c838a5147" 
                                         frame:CGRectMake(0, 100, 200, 50) 
                                     iPadFrame:CGRectMake(0, 0, 0, 0)];
}

@end

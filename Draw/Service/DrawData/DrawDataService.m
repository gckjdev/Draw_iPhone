//
//  DrawDataService.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "DrawDataService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"

@implementation DrawDataService

- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = nil;             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
            }
            if ([viewController respondsToSelector:@selector(didFindRecentDraw:)]){
                [viewController didFindRecentDraw:nil];
            }
            
        });
    });
}

@end

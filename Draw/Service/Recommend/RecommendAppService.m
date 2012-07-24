//
//  RecommendAppService.m
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendAppService.h"
#import "GameNetworkRequest.h"
#import "RecommendApp.h"
#import "RecommendAppManager.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"

#define GET_RECOMMEND_APP @"get_recommend_app"

enum {
    APP_NAME = 0,
    APP_DESCRIPTION,
    APP_ICON_URL,
    APP_ULR
};

static RecommendAppService* shareInstance;

@implementation RecommendAppService
@synthesize delegate = _delegate;

+ (RecommendAppService*)defaultService
{
    if (shareInstance == nil) {
        shareInstance = [[RecommendAppService alloc] init];
    }
    return shareInstance;
}

- (void)getRecommendApp
{
    NSOperationQueue* queue = [self getOperationQueue:GET_RECOMMEND_APP];
    
    [queue addOperationWithBlock:^{
        
        CommonNetworkOutput* output = nil;
        output = [GameNetworkRequest getRecommendApp:SERVER_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray* appArray = nil;
            
            if (output.resultCode == ERROR_SUCCESS){
                appArray = (NSArray*)[output.arrayData objectAtIndex:0];
                [[RecommendAppManager defaultManager].appList removeAllObjects];
                for (NSArray* array in appArray) {
                    if (array.count == 4) {
                        NSString* appName = [array objectAtIndex:APP_NAME];
                        NSString* appDescription = [array objectAtIndex:APP_DESCRIPTION];
                        NSString* appIconUrl = [array objectAtIndex:APP_ICON_URL];
                        NSString* appUrl = [array objectAtIndex:APP_ULR];
                        
                        RecommendApp* app = [[RecommendApp alloc] initWithAppName:appName
                                                                      description:appDescription 
                                                                          iconUrl:appIconUrl 
                                                                           appUrl:appUrl];
                        
                        [[RecommendAppManager defaultManager].appList addObject:app];
                        
                    }
                }
                if (_delegate && [_delegate respondsToSelector:@selector(getRecommendAppFinish)]) {
                    [_delegate getRecommendAppFinish];
                }
            }
            
        });                        
    }];

}
@end

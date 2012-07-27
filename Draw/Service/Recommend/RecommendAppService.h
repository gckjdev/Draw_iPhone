//
//  RecommendAppService.h
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@protocol RecommendAppServiceDelegate <NSObject>

- (void)getRecommendAppFinish;

@end

@interface RecommendAppService : CommonService

@property (assign, nonatomic) id<RecommendAppServiceDelegate> delegate;

+ (RecommendAppService*)defaultService;
- (void)getRecommendApp;
@end

//
//  RecommendApp.h
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendApp : NSObject
@property (nonatomic, retain) NSString* appName;
@property (nonatomic, retain) NSString* appDescription;
@property (nonatomic, retain) NSString* appIconUrl;
@property (nonatomic, retain) NSString* appUrl;

- (id)initWithAppName:(NSString*)name 
          description:(NSString*)description 
              iconUrl:(NSString*)iconUrl 
               appUrl:(NSString*)appUrl;

+ (RecommendApp*)draw;
+ (RecommendApp*)shuriken;
+ (RecommendApp*)crazyFinger;
+ (RecommendApp*)ghostGame;
+ (RecommendApp*)countBean;
+ (RecommendApp*)groupBuy;
@end

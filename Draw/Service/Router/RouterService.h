//
//  RouterService.h
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@protocol RouterServiceDelegate <NSObject>

- (void)didServerListFetched:(int)result;

@end

@interface RouterService : CommonService



+ (RouterService*)defaultService;

- (void)fetchServerList:(id<RouterServiceDelegate>)delegate;



@end

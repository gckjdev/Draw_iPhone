//
//  IngotService.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <Foundation/Foundation.h>

typedef void (^GetIngotsListResultHandler)(BOOL success, NSArray *ingotsList);


@interface IngotService : NSObject

+ (IngotService *)sharedIngotService;

- (void)getIngotsList:(GetIngotsListResultHandler)handler;


@end

//
//  BBSService.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "CommonService.h"


@protocol BBSServiceDelegate <NSObject>

@optional
- (void)didGetBBSBoardList:(NSArray *)boardList
               resultCount:(NSInteger)resultCount;

@end
@interface BBSService : CommonService

+ (id)defaultService;
- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate;



@end

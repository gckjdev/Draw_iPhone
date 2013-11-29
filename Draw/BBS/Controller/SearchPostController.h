//
//  SearchPostController.h
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "BBSService.h"
#import "SearchController.h"


@class PBGroup;
@interface SearchPostController : SearchController<BBSServiceDelegate>


@property(nonatomic, retain)PBGroup *group;
@property(nonatomic, assign)BOOL forGroup;

@end

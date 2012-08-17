//
//  AnnounceService.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"

@protocol BoardServiceDelegate <NSObject>

@optional
- (void)didGetBoards:(NSArray *)boards 
          resultCode:(NSInteger)resultCode;

@end

@interface BoardService : CommonService
{
    
}

+ (BoardService *)defaultService;

@end

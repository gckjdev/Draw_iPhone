//
//  BoardManager.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardManager : NSObject
{
    
}
+ (BoardManager *)defaultManager;

//- (NSArray *)BoardList;

- (NSArray *)getLocalBoardList;
- (void)saveBoardList:(NSArray *)boardList;

@end

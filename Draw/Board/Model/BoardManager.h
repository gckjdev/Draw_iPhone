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

@property (nonatomic, retain) NSMutableArray   *boardList;

+ (BoardManager *)defaultManager;


- (void)saveBoardList:(NSArray *)boardList;

@end

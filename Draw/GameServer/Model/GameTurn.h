//
//  GameTurn.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameTurn : NSObject

@property (nonatomic, assign) int round;

@property (nonatomic, retain) NSString *currentPlayUserId;
@property (nonatomic, retain) NSString *nextPlayUserId;
@property (nonatomic, retain) NSString *lastPlayUserId;

@property (nonatomic, retain) NSArray *playResultList;
@property (nonatomic, retain) NSArray *userCommentList;
@property (nonatomic, retain) NSMutableArray *drawActionList;

//@property (nonatomic, retain) 

@property (nonatomic, copy) NSString *lastWord;
@property (nonatomic, copy) NSString* word;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int language;
- (void)updateLastWord;
- (id)init;
- (void)resetData;
@end

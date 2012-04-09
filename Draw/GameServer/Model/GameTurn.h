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
@property (nonatomic, retain) NSArray *drawActionList;

//@property (nonatomic, retain) 

@property (nonatomic, retain) NSString *lastWord;
@property (nonatomic, retain) NSString* word;
@property (nonatomic, assign) int level;

- (void)updateLastWord;

@end

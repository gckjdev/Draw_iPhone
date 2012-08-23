//
//  DiceSoundManager.h
//  Draw
//
//  Created by Orange on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceSoundManager : NSObject

+ (DiceSoundManager*)defaultManager;
- (NSArray*)diceSoundNameArray;
- (void)callNumber:(int)number 
              dice:(int)dice 
            gender:(BOOL)gender;
- (void)openDice:(BOOL)gender;
- (void)scrambleOpen:(BOOL)gender;


@end

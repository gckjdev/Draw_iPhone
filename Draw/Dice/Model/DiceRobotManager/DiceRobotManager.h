//
//  DiceRobotManager.h
//  Draw
//
//  Created by Orange on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceRobotManager : NSObject {
    // What each player last calls
    NSMutableDictionary* lastCall;
    // Does player change his/her dice, compared to last round?
    NSMutableDictionary* changeDiceValue;
}

@end

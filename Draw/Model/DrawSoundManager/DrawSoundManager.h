//
//  DrawSoundManager.h
//  Draw
//
//  Created by Kira on 12-12-13.
//
//

#import <Foundation/Foundation.h>

@interface DrawSoundManager : NSObject

+ (DrawSoundManager*)defaultManager;
- (NSString*)clickWordSound;
- (NSString*)someoneEnterRoomSound;
- (NSString*)guessWrongSound;
- (NSString*)guessCorrectSound;
- (NSString*)congratulationsSound;

@end

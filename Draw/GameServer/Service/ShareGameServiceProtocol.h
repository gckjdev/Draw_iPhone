//
//  ShareGameServiceProtocol.h
//  Draw
//
//  Created by Kira on 13-1-23.
//
//

#import <Foundation/Foundation.h>
@class PBGameUser;

#define PROTOCOL_BUFFER_SHARE_KEY       @"pb_share_key"

typedef enum {
    allRoom = 0,
    friendRoom = 1,
    nearByRoom = 2
}RoomFilter;

@protocol ShareGameServiceProtocol <NSObject>
@required
- (void)getRoomList:(int)startIndex
              count:(int)count;

- (void)getRoomList:(int)startIndex
              count:(int)count
           roomType:(int)type
            keyword:(NSString*)keyword
             gameId:(NSString*)gameId;

- (void)joinGameRequest;
- (void)joinGameRequest:(long)sessionId;
- (void)joinGameRequest:(long)sessionId customSelfUser:(PBGameUser*)customSelfUser;
- (void)joinGameRequestWithCustomUser:(PBGameUser*)customSelfUser;

- (void)createRoomWithName:(NSString*)name
                  password:(NSString*)password;
- (int)onlineUserCount;
- (NSArray*)roomList;
- (void)quitGame;
- (BOOL)isConnected;
- (void)connectServer;
- (int)rule;
- (PBGameSession*)sessionInRoom:(int)index;
@end

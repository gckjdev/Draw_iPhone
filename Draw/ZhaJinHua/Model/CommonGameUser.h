//
//  CommonGameUser.h
//  Draw
//
//  Created by 王 小涛 on 12-11-7.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@interface CommonGameUser : NSObject

@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSString *avatar;
@property (assign, nonatomic) BOOL gender;
@property (retain, nonatomic) NSArray *snsUsers;
@property (retain, nonatomic) NSString *city;
@property (assign, nonatomic) int seatId;
@property (assign, nonatomic) BOOL isPlaying;
@property (retain, nonatomic) NSDictionary *attributes;

+ (CommonGameUser*)fromPBGameUser:(PBGameUser *)pbGameUser;

@end

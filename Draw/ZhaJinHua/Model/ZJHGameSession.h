//
//  ZJHGameSession.h
//  Draw
//
//  Created by 王 小涛 on 12-10-23.
//
//

#import "CommonGameSession.h"

@interface ZJHGameSession : CommonGameSession

@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) int singleBet;
@property (retain, nonatomic) NSDictionary *usersInfo;


@end

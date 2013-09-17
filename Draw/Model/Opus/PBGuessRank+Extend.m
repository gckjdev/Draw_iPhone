//
//  PBGuessRank+Extend.m
//  Draw
//
//  Created by 王 小涛 on 13-7-29.
//
//

#import "PBGuessRank+Extend.h"

@implementation PBGuessRank (Extend)


- (NSString *)correctTimesDesc{
    
    return [NSString stringWithFormat:NSLS(@"%d"), self.pass];

}

- (NSString *)costTimeDesc{
    
    return [NSString stringWithFormat:NSLS(@"%d"), self.spendTime];

}


- (NSString *)earnDesc{
    
    return [NSString stringWithFormat:NSLS(@"%d"), self.earn];

}


@end

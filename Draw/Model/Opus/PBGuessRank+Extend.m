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
    
//    return [NSString stringWithFormat:NSLS(@"kGuessCorrectIs:%d"), self.pass];
    return [NSString stringWithFormat:NSLS(@"%d"), self.pass];

}

- (NSString *)costTimeDesc{
    
//    if (self.spendTime < 60) {
        return [NSString stringWithFormat:NSLS(@"%d"), self.spendTime];
//    }else if (self.spendTime < 3600){
//        int minus = self.spendTime / 60;
//        int second = self.spendTime % 60;
//        return [NSString stringWithFormat:NSLS(@"kCostMinus:%d, second:%d"), minus, second];
//    }else if (self.spendTime < 24 * 3600){
//        int hour = self.spendTime / 3600;
//        int minus = ((self.spendTime % 3600)) / 60;
//        int second = self.spendTime % 60;
//        return [NSString stringWithFormat:NSLS(@"kCostHour:%d, minus:%d, second:%d"), hour, minus, second];
//    }else{
//        int day = self.spendTime / (24 * 3600);
//        int hour = (self.spendTime % (24 * 3600)) / 3600;
//        int minus = (self.spendTime % 3600) / 60;
//        return [NSString stringWithFormat:NSLS(@"kCostDay:%d, hour:%d, minus:%d"), day, hour, minus];
//    }
}


- (NSString *)earnDesc{
    
//    return [NSString stringWithFormat:NSLS(@"kAwardIs:%d"), self.earn];
    return [NSString stringWithFormat:NSLS(@"%d"), self.earn];

}


@end

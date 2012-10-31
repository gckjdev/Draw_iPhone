//
//  betTable.h
//  Draw
//
//  Created by Kira on 12-10-30.
//
//

#import <UIKit/UIKit.h>
#import "ZJHGameController.h"

@interface BetTable : UIView

- (void)someBetFrom:(UserPosition)position
           forCount:(int)counter;
- (void)clearAllCounter;


@end

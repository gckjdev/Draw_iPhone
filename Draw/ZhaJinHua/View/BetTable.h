//
//  BetTable.h
//  Draw
//
//  Created by Kira on 12-10-31.
//
//

#import <UIKit/UIKit.h>
#import "ZJHGameController.h"
#import "NSMutableArray+Queue.h"

@interface BetTable : UIView {
    NSMutableArray* _layerQueue;
    NSMutableArray* _visibleLayerQueue;
}

- (void)someBetFrom:(UserPosition)position
          chipValue:(int)chipValue
              count:(int)count;

- (void)userWonAllChips:(UserPosition)position;
- (void)clearAllChips;
- (void)betSome;

@end

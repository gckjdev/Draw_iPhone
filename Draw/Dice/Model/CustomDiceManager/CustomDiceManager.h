//
//  CustomDiceManager.h
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiceItem.h"

@interface CustomDiceManager : NSObject

- (ItemType)getMyDiceType;
- (void)setMyDiceType:(ItemType)type;

- (UIImage*)diceImageForType:(ItemType)type 
                        dice:(int)dice;
- (UIImage*)openDiceImageForType:(ItemType)type 
                            dice:(int)dice;

- (NSString*)getImagePrefixByType:(ItemType)type;

- (NSArray*)myCustomDiceList;

@end

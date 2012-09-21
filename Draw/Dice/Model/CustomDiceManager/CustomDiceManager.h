//
//  CustomDiceManager.h
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiceItem.h"

#define CUSTOM_DICE @"CUSTOM_DICE"

@class PBGameUser;

typedef enum {
    CustomDiceTypeDefault = 0,
    CustomDiceTypePatriot,
    CustomDiceTypeCount
}CustomDiceType;


@interface CustomDiceManager : NSObject

- (CustomDiceType)getMyDiceType;
- (void)setMyDiceType:(CustomDiceType)type;
- (void)setMyDiceTypeByItemType:(ItemType)type;

- (UIImage*)diceImageForType:(CustomDiceType)type 
                        dice:(int)dice;
- (UIImage*)openDiceImageForType:(CustomDiceType)type 
                            dice:(int)dice;

- (UIImage*)myDiceImage:(int)dice;
- (UIImage*)myOpenDiceImage:(int)dice;

- (NSString*)getImagePrefixByType:(CustomDiceType)type;

- (NSArray*)myCustomDiceList;
+ (CustomDiceManager*)defaultManager;

+ (CustomDiceType)itemTypeToCustomDiceType:(ItemType)type;
+ (CustomDiceType)getUserDiceTypeByPBGameUser:(PBGameUser*)pbUser;
@end

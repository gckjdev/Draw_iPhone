//
//  DiceItem.m
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceItem.h"
#import "ShoppingManager.h"
#import "ItemManager.h"
#import "DiceImageManager.h"
#import "LocaleUtils.h"

#import "UIImageUtil.h"

#import "HKGirlFontLabel.h"

@implementation Item (DiceItem)

+ (UIImage *)createItemImageByType:(ItemType)type
{
    UIImage* backgroundImage = [[DiceImageManager defaultManager] toolsItemBgImage];
    HKGirlFontLabel* label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(backgroundImage.size.width*0.2, 
                                                                                backgroundImage.size.width*0.1, 
                                                                                backgroundImage.size.width*0.6, 
                                                                                backgroundImage.size.height*0.6) 
                                                           pointSize:40] autorelease];
    
    if (type == ItemTypeRollAgain) {
        [label setText:NSLS(@"kRollAgain")];
    }
    
    if (type == ItemTypeCut) {
        [label setText:NSLS(@"kCut")];
    }
    
    return [UIImage creatImageByImage:backgroundImage withLabel:label];
}

+ (Item*)rollAgain
{
    return [[[Item alloc] initWithType:ItemTypeRollAgain 
                                 image:[Item createItemImageByType:ItemTypeRollAgain]
                                  name:NSLS(@"kRollAgain")
                           description:NSLS(@"kRollAgainDescription") 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getRollAgainPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeRollAgain]] autorelease];
}


+ (Item*)cut
{
    return [[[Item alloc] initWithType:ItemTypeCut 
                                 image:[Item createItemImageByType:ItemTypeCut]
                                  name:NSLS(@"kCut")
                           description:NSLS(@"kCutDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getCutPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCut]] autorelease];
}

//- (UIView *)itemViewItemName:(NSString *)itemName
//{
//    CGRect frame = CGRectMake(0, 0, 34, 38);
//    UIImageView *view = [[[UIImageView alloc] initWithFrame:frame] autorelease];
//    view.image = [[DiceImageManager defaultManager] toolsItemBgImage];
//    HKGirlFontLabel *label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 22, 24)] autorelease];
//    label.center = view.center;
//    label.text = itemName;
//    
//    [view addSubview:label];
//    return view;
//}

@end

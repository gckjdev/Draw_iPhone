//
//  ZJHCardTypesView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-17.
//
//

#import "ZJHCardTypesView.h"
#import "ZJHImageManager.h"
#import "CMPopTipView.h"

#define MY_CARD_TYPE_LABEL_TEXT_COLOR [UIColor colorWithRed:126.0/255.0 green:1 blue:1 alpha:1]

#define SPECIAL_CARD_TYPE_VIEW_WIDTH ([DeviceDetection isIPAD] ? 60 : 30)
#define SPECIAL_CARD_TYPE_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 60 : 30)

@implementation ZJHCardTypesView

+ (id)createPokerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PokerView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}



+ (UIView *)normalCardTypesViewWithCardType:(PBZJHCardType)cardType
{
    ZJHCardTypesView *view = [self createPokerView];
    view.bgImageView.image = [[ZJHImageManager defaultManager] cardTypeBgImage];
    switch (cardType) {
        case PBZJHCardTypeHighCard:
            [view.highCardLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        case PBZJHCardTypePair:
            [view.pairLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        case PBZJHCardTypeStraight:
            [view.straightLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        case PBZJHCardTypeFlush:
            [view.flushLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        case PBZJHCardTypeStraightFlush:
            [view.straightFlushLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        case PBZJHCardTypeThreeOfAKind:
            [view.threeOfAKindLabel setTextColor:MY_CARD_TYPE_LABEL_TEXT_COLOR];
            break;
            
        default:
            break;
    }
    
    return view;
}



+ (UIView *)specialCardTypesView
{
    UIImageView *view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 30) ] autorelease];

    view.image = [[ZJHImageManager defaultManager] specialCardTypeImage];
    return view;
}


+ (UIView *)cardTypesViewWithCardType:(PBZJHCardType)cardType;
{
    if (cardType != PBZJHCardTypeSpecial && cardType != PBZJHCardTypeUnknow) {
        return [self normalCardTypesViewWithCardType:cardType];
    }else {
        return [self specialCardTypesView];
    }
    

}

- (void)dealloc {
    [_bgImageView release];
    [_threeOfAKindLabel release];
    [_straightFlushLabel release];
    [_flushLabel release];
    [_straightLabel release];
    [_pairLabel release];
    [_highCardLabel release];
    [super dealloc];
}
@end

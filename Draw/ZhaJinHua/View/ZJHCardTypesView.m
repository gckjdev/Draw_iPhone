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
#import <QuartzCore/QuartzCore.h>

#define MY_CARD_TYPE_LABEL_TEXT_COLOR [UIColor colorWithRed:126.0/255.0 green:1 blue:1 alpha:1]

#define SPECIAL_CARD_TYPE_VIEW_WIDTH ([DeviceDetection isIPAD] ? 172 : 86)
#define SPECIAL_CARD_TYPE_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 97 : 48)

@implementation ZJHCardTypesView

+ (id)createZJHCardTypesView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ZJHCardTypesView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}



+ (UIView *)normalCardTypesViewWithCardType:(PBZJHCardType)cardType
{
    ZJHCardTypesView *view = [self createZJHCardTypesView];
    view.bgImageView.image = [[ZJHImageManager defaultManager] zjhCardTypesNoteBgImage];
    
    RRSGlowLabel *label = nil;
    switch (cardType) {
        case PBZJHCardTypeHighCard:
            label = view.highCardLabel;
            break;
            
        case PBZJHCardTypePair:
            label = view.pairLabel;
            break;
            
        case PBZJHCardTypeStraight:
            label = view.straightLabel;
            break;
            
        case PBZJHCardTypeFlush:
            label = view.flushLabel;
            break;
            
        case PBZJHCardTypeStraightFlush:
            label = view.straightFlushLabel;
            break;
            
        case PBZJHCardTypeThreeOfAKind:
            label = view.threeOfAKindLabel;
            break;
            
        default:
            break;
    }
    
    label.textColor = MY_CARD_TYPE_LABEL_TEXT_COLOR;
    label.glowColor = label.textColor;
    label.glowOffset = CGSizeMake(0.0, 0.0);
    label.glowAmount = 20000.0;
    
    [label setNeedsDisplay];
    
    return view;
}

+ (UIView *)specialCardTypesView
{
    UIImageView *view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SPECIAL_CARD_TYPE_VIEW_WIDTH, SPECIAL_CARD_TYPE_VIEW_HEIGHT) ] autorelease];

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

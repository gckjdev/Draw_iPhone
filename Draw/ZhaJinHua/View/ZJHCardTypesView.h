//
//  ZJHCardTypesView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-17.
//
//

#import <UIKit/UIKit.h>
#import "ZhaJinHua.pb.h"
#import "RRSGlowLabel.h"

@interface ZJHCardTypesView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *threeOfAKindLabel;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *straightFlushLabel;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *flushLabel;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *straightLabel;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *pairLabel;
@property (retain, nonatomic) IBOutlet RRSGlowLabel *highCardLabel;

+ (UIView *)cardTypesViewWithCardType:(PBZJHCardType)cardType;

@end

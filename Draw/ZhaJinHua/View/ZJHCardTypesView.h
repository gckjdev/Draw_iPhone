//
//  ZJHCardTypesView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-17.
//
//

#import <UIKit/UIKit.h>
#import "ZhaJinHua.pb.h"

@interface ZJHCardTypesView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UILabel *threeOfAKindLabel;
@property (retain, nonatomic) IBOutlet UILabel *straightFlushLabel;
@property (retain, nonatomic) IBOutlet UILabel *flushLabel;
@property (retain, nonatomic) IBOutlet UILabel *straightLabel;
@property (retain, nonatomic) IBOutlet UILabel *pairLabel;
@property (retain, nonatomic) IBOutlet UILabel *highCardLabel;

+ (UIView *)cardTypesViewWithCardType:(PBZJHCardType)cardType;

@end

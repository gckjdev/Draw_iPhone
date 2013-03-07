//
//  BuyItemView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "GameBasic.pb.h"

@interface BuyItemView : UIView
@property (assign, nonatomic, readonly) int count;

@property (retain, nonatomic) IBOutlet UIButton *countButton;
@property (retain, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;

+ (id)createWithItem:(PBGameItem *)item;

@end

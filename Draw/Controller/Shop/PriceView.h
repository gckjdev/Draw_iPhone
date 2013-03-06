//
//  PriceView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import <UIKit/UIKit.h>
#import "GameBasic.pb.h"

@interface PriceView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *promotionCurrencyImageView;
@property (retain, nonatomic) IBOutlet UILabel *promotionPriceLabel;
@property (retain, nonatomic) IBOutlet UIImageView *grayLineImageView;
@property (retain, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;

+ (id)createWithPrice:(int)price currency:(PBGameCurrency)currency;

+ (id)createWithPrice:(int)price promotionPrice:(int)promotionPrice currency:(PBGameCurrency)currency;

@end

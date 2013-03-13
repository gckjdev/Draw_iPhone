//
//  BuyItemView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "GameBasic.pb.h"
#import "UserGameItemService.h"

typedef void (^GiveHandler)(PBGameItem *item, int count);

@interface BuyItemView : UIView
@property (assign, nonatomic, readonly) int count;

@property (retain, nonatomic) IBOutlet UIButton *countButton;
@property (retain, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIView *buyInfoView;


+ (void)showOnlyBuyItemView:(PBGameItem *)item
                     inView:(UIView *)inView
              resultHandler:(BuyItemResultHandler)resultHandler;

+ (void)showBuyItemView:(PBGameItem *)item
                 inView:(UIView *)inView
       buyResultHandler:(BuyItemResultHandler)buyResultHandler
            giveHandler:(GiveHandler)giveHandler;
@end

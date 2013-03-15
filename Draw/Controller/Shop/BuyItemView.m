//
//  BuyItemView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "BuyItemView.h"
#import "AutoCreateViewByXib.h"
#import "GameItemDetailView.h"
#import "PBGameItem+Extend.h"
#import "ShareImageManager.h"
#import "InputDialog.h"
#import "UIViewUtils.h"
#import "CustomInfoView.h"
#import "AdService.h"
#import "FriendController.h"
#import "VersionUpdateView.h"
#import "UserGameItemManager.h"

#define MAX_COUNT 9999
#define MIN_COUNT 1

@interface BuyItemView()
@property (assign, nonatomic) int count;
@property (retain, nonatomic) PBGameItem *item;

@end

@implementation BuyItemView

AUTO_CREATE_VIEW_BY_XIB_N(BuyItemView);

- (void)dealloc {
    [_item release];
    [_priceLabel release];
    [_currencyImageView release];
    [_countButton release];
    [_buyInfoView release];
    [super dealloc];
}

+ (id)createWithItem:(PBGameItem *)item
{
    BuyItemView *view;
    switch (item.consumeType) {
        case PBGameItemConsumeTypeNonConsumable:
            view = [self createViewWithIndex:0];
            view.count = 1;
            break;
            
        case PBGameItemConsumeTypeAmountConsumable:
            view = [self createViewWithIndex:1];
            view.count = item.defaultSaleCount;
            break;
            
        case PBGameItemConsumeTypeTimeConsumable:
            view = [self createViewWithIndex:2];
            view.count = 1;
            break;
            
        default:
            break;
    }
    
    
    view.item = item;
    
    GameItemDetailView *detailView = [GameItemDetailView createWithItem:item];
    [view addSubview:detailView];
    
    view.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:item.priceInfo.currency];
    
    [view update];
    
    return view;
}

- (void)update
{
    [self.countButton setTitle:[NSString stringWithFormat:@"%d", self.count] forState:UIControlStateNormal];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%d", [self.item promotionPrice] * self.count];
}

- (IBAction)clickIncreaseButton:(id)sender {
    
    if (self.count >= MAX_COUNT) {
        return;
    }
    
    self.count++;
    
    [self update];
}

- (IBAction)clickDecreaseButton:(id)sender {
    
    if (self.count <= MIN_COUNT) {
        return;
    }
    
    self.count--;
    
    [self update];
}



- (IBAction)clickCountButton:(id)sender {
    InputDialog *dialog = [InputDialog dialogWith:@"kInputCount" clickOK:^(NSString *inputStr) {
        self.count = [inputStr intValue];
        if (self.count >= MAX_COUNT) {
            self.count = MAX_COUNT;
        }
        [self update];
    } clickCancel:^(NSString *inputStr) {
        
    }];
    dialog.targetTextField.keyboardType = UIKeyboardTypeNumberPad;
    [dialog showInView:[self rootView]];
}

+ (void)showOnlyBuyItemView:(PBGameItem *)item
                     inView:(UIView *)inView
              resultHandler:(BuyItemResultHandler)resultHandler
{
    if (item == nil || inView == nil) {
        return;
    }
    
    if (item.consumeType == PBGameItemConsumeTypeTimeConsumable) {
        [VersionUpdateView showInView:inView];
        return;
    }
    
    BuyItemView *infoView = [self createWithItem:item];
    
    CustomInfoView *cusInfoView;
    
    cusInfoView = [CustomInfoView createWithTitle:NSLS(infoView.item.name)
                                         infoView:infoView
                                   hasCloseButton:YES
                                     buttonTitles:[NSArray arrayWithObjects:NSLS(@"kBuy"), nil]];
    
    
    [cusInfoView showInView:inView];
    
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        
        int count = ((BuyItemView *)infoView).count;
        PBGameItem *item = ((BuyItemView *)infoView).item;
        
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kBuy")]) {
            PPDebug(@"you buy %d %@", count, NSLS(item.name));
            [button setTitle:NSLS(@"kBuying...") forState:UIControlStateNormal];
            [cusInfoView showActivity];
            [[UserGameItemService defaultService] buyItem:item count:count handler:^(BuyItemResultCode resultCode, int itemId, int count, NSString *toUserId) {
                if (resultCode == UIS_SUCCESS) {
                    [cusInfoView dismiss];
                }else{
                    [cusInfoView hideActivity];
                    [button setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
                }
                
                if (resultHandler != NULL) {
                    resultHandler(resultCode, itemId, count, toUserId);
                }
            }];
        }
    }];
}


+ (void)showBuyItemView:(PBGameItem *)item
                 inView:(UIView *)inView
       buyResultHandler:(BuyItemResultHandler)buyResultHandler
            giveHandler:(GiveHandler)giveHandler
{
    if (item == nil || inView == nil) {
        return;
    }
    
    if (item.consumeType == PBGameItemConsumeTypeTimeConsumable) {
        [VersionUpdateView showInView:inView];
        return;
    }
    
    BuyItemView *infoView = [self createWithItem:item];
    
    CustomInfoView *cusInfoView;
    
    if ([[UserGameItemManager defaultManager] canBuyItemNow:infoView.item]) {
        cusInfoView = [CustomInfoView createWithTitle:NSLS(infoView.item.name)
                                             infoView:infoView
                                       hasCloseButton:YES
                                         buttonTitles:[NSArray arrayWithObjects:NSLS(@"kBuy"), NSLS(@"kGive"), nil]];
        
    }else{
        cusInfoView = [CustomInfoView createWithTitle:NSLS(infoView.item.name)
                                             infoView:infoView
                                       hasCloseButton:YES
                                         buttonTitles:[NSArray arrayWithObjects:NSLS(@"kGive"), nil]];
    }
    
    [cusInfoView showInView:inView];
    
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        
        int count = ((BuyItemView *)infoView).count;
        PBGameItem *item = ((BuyItemView *)infoView).item;
        
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kBuy")]) {
            
            PPDebug(@"you buy %d %@", count, NSLS(item.name));
            [button setTitle:NSLS(@"kBuying...") forState:UIControlStateNormal];
            [cusInfoView showActivity];
            [[UserGameItemService defaultService] buyItem:item count:count handler:^(BuyItemResultCode resultCode, int itemId, int count, NSString *toUserId) {
                if (resultCode == UIS_SUCCESS) {
                    [cusInfoView dismiss];
                }else{
                    [cusInfoView hideActivity];
                    [button setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
                }
                
                if (buyResultHandler != NULL) {
                    buyResultHandler(resultCode, itemId, count, toUserId);
                }
            }];
        }else{
            PPDebug(@"you give %d %@", count, NSLS(item.name));
            if (giveHandler != NULL) {
                giveHandler(item, count);
            }
            [cusInfoView dismiss];
        }
    }];
}


@end

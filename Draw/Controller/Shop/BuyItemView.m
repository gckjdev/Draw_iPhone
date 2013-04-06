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
#import "VersionUpdateView.h"
#import "UserGameItemManager.h"
#import "CommonMessageCenter.h"
#import "GameItemManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "UIViewUtils.h"
#import "AdService.h"
#import "ItemType.h"
#import "GiftDetailView.h"
#import "ConfigManager.h"

#define MAX_COUNT 9999
#define MIN_COUNT 1
#define GAP ([DeviceDetection isIPAD] ? (6) : (3))


@interface BuyItemView()
@property (assign, nonatomic) int count;
@property (retain, nonatomic) PBGameItem *item;
@property (assign, nonatomic) UIView *inView;
@property (assign, nonatomic) BuyItemResultHandler resultHandler;
@end

@implementation BuyItemView

AUTO_CREATE_VIEW_BY_XIB_N(BuyItemView);

- (void)dealloc {
    RELEASE_BLOCK(_resultHandler);
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
    
    [view updateHeight:(detailView.frame.size.height + GAP +view.buyInfoView.frame.size.height)];
    [view.buyInfoView updateOriginY:(detailView.frame.size.height + GAP)];
    
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
        int count = [inputStr intValue];
        if (count < MIN_COUNT) {
            return;
        }
        
        self.count = MIN(count, MAX_COUNT);
        [self update];
        
    } clickCancel:^(NSString *inputStr) {
        
    }];
    dialog.targetTextField.keyboardType = UIKeyboardTypeNumberPad;
    [dialog showInView:[self PPRootView]];
}

+ (void)showOnlyBuyItemView:(int)itemId
                     inView:(UIView *)inView
              resultHandler:(BuyItemResultHandler)resultHandler
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
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
            [[UserGameItemService defaultService] buyItem:itemId count:count handler:^(int resultCode, int itemId, int count, NSString *toUserId) {
                
                if (resultCode == ERROR_SUCCESS){
                    [cusInfoView dismiss];
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBuySuccess") delayTime:1.2 isHappy:YES];
//                    if (itemId == ItemTypeRemoveAd) {
//                        [[AdService defaultService] disableAd];
//                    }else if(itemId == ItemTypePurse){
//                        [[AccountService defaultService] chargeAccount:([ConfigManager getCoinsIngotRate] * item.priceInfo.price * count) source:ChargeAsAGift];
//                    }
                }else if(resultCode == ERROR_BALANCE_NOT_ENOUGH) {
                    [cusInfoView dismiss];
                    [BalanceNotEnoughAlertView showInController:[inView theViewController]];
                }else{
                    [cusInfoView hideActivity];
                    [button setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:1.2 isHappy:YES];
                }
                
                EXECUTE_BLOCK(resultHandler, resultCode, itemId, count, toUserId);
            }];
        }
    }];
}


+ (void)showBuyItemView:(int)itemId
                 inView:(UIView *)inView
          resultHandler:(BuyItemResultHandler)resultHandler
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    if (item == nil || inView == nil) {
        return;
    }
    
    if (item.consumeType == PBGameItemConsumeTypeTimeConsumable) {
        [VersionUpdateView showInView:inView];
        return;
    }
    
    BuyItemView *infoView = [self createWithItem:item];
    infoView.inView = inView;

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
        BuyItemView * buyItemView = (BuyItemView *)infoView;
        int count = buyItemView.count;
        PBGameItem *item = buyItemView.item;
        
        if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLS(@"kBuy")]) {
            
            PPDebug(@"you buy %d %@", count, NSLS(item.name));
            [button setTitle:NSLS(@"kBuying...") forState:UIControlStateNormal];
            [cusInfoView showActivity];
            [[UserGameItemService defaultService] buyItem:itemId count:count handler:^(int resultCode, int itemId, int count, NSString *toUserId) {
                if (resultCode == ERROR_SUCCESS) {
                    [cusInfoView dismiss];
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBuySuccess") delayTime:2 isHappy:YES];
                    if (itemId == ItemTypeRemoveAd) {
                        [[AdService defaultService] disableAd];
                    }else if(itemId == ItemTypePurse){
                        [[AccountService defaultService] chargeAccount:([ConfigManager getCoinsIngotRate] * item.priceInfo.price * count) source:ChargeAsAGift];
                    }
                }else if(resultCode == ERROR_BALANCE_NOT_ENOUGH){
                    [cusInfoView dismiss];
                    [BalanceNotEnoughAlertView showInController:[inView theViewController]];
                }else{
                    [cusInfoView hideActivity];
                    [button setTitle:NSLS(@"kBuy") forState:UIControlStateNormal];
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:YES];
                }
                
                EXECUTE_BLOCK(resultHandler, resultCode, itemId, count, toUserId);
            }];
        }else{
            PPDebug(@"you give %d %@", count, NSLS(item.name));
            COPY_BLOCK(buyItemView.resultHandler, resultHandler);
            
            FriendController *vc = [[[FriendController alloc] initWithDelegate:(BuyItemView *)infoView] autorelease];
            [[[inView theViewController] navigationController] pushViewController:vc animated:YES];
        
            [cusInfoView dismiss];
        }
    }];
}


- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    [controller.navigationController popViewControllerAnimated:YES];
    GiftDetailView *giftDetailView = [GiftDetailView createWithItem:_item.itemId myFriend:aFriend count:_count];
    
    CustomInfoView *cusInfoView = [CustomInfoView createWithTitle:NSLS(@"kGive")
                                                         infoView:giftDetailView
                                                   hasCloseButton:YES
                                                     buttonTitles:[NSArray arrayWithObjects:NSLS(@"kCancel"), NSLS(@"kOK"), nil]];
        
    [cusInfoView showInView:[self.inView PPRootView]];
    
    __block typeof (self) bself = self;
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        [cusInfoView showActivity];
        if (button.tag == 1) {
            [[UserGameItemService defaultService] giveItem:bself.item.itemId toUser:[aFriend friendUserId] count:bself.count handler:^(int resultCode, int itemId, int count, NSString *toUserId) {
                [cusInfoView hideActivity];
                if (resultCode == ERROR_SUCCESS) {
                    [cusInfoView dismiss];
                    if(itemId == ItemTypePurse){
                        [[AccountService defaultService] chargeAccount:(([ConfigManager getCoinsIngotRate] * bself.item.priceInfo.price) * count) toUser:toUserId source:ChargeAsAGift];
                    }
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGiveSuccess") delayTime:2 isHappy:YES];
                }else if(resultCode == ERROR_BALANCE_NOT_ENOUGH){
                    [BalanceNotEnoughAlertView showInController:[self.inView theViewController]];
                    [cusInfoView dismiss];
                }else{
                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSystemFailure") delayTime:2 isHappy:YES];
                }
                EXECUTE_BLOCK(_resultHandler, resultCode, itemId, count, toUserId);
                RELEASE_BLOCK(_resultHandler);
            }];
        }
    }];
}


@end

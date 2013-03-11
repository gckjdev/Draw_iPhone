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
#import "PBGameItemUtils.h"
#import "ShareImageManager.h"
#import "InputDialog.h"
#import "UIViewUtils.h"

#define MAX_COUNT 9999
#define MIN_COUNT 1

@interface BuyItemView()
@property (assign, nonatomic) int count;
@property (retain, nonatomic) PBGameItem *item;

@end

@implementation BuyItemView

AUTO_CREATE_VIEW_BY_XIB(BuyItemView);

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
    BuyItemView *view  = [self createView];
    
    view.item = item;
    
    GameItemDetailView *detailView = [GameItemDetailView createWithItem:item];
    detailView.userInteractionEnabled = NO;
    [view addSubview:detailView];
    
    view.currencyImageView.image = [[ShareImageManager defaultManager] currencyImageWithType:item.priceInfo.currency];
    
    
    if (item.salesType == PBGameItemSalesTypeMultiple) {
        view.count = 10;
    }else if (item.salesType == PBGameItemSalesTypeOneOff){
        view.count = 1;
        [view updateHeight:(view.frame.size.height - view.buyInfoView.frame.size.height)];
        [view.buyInfoView removeFromSuperview];
    }
    
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



@end

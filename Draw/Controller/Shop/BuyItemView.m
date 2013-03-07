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
    
    view.count = 10;
    
    [view update];
    
    return view;
}

- (void)update
{
    [self.countButton setTitle:[NSString stringWithFormat:@"%d", self.count] forState:UIControlStateNormal];
    
    int price = self.item.priceInfo.price * ([self.item isPromoting] ? self.item.promotionInfo.discount/100.0f : 1) * self.count;
    self.priceLabel.text = [NSString stringWithFormat:@"%d", price];
}

- (IBAction)clickIncreaseButton:(id)sender {
    
    if (self.count >= 9999) {
        return;
    }
    
    self.count++;
    
    [self update];
}

- (IBAction)clickDecreaseButton:(id)sender {
    
    if (self.count <= 0) {
        return;
    }
    
    self.count--;
    
    [self update];
}

- (IBAction)clickCountButton:(id)sender {
    InputDialog *dialog = [InputDialog dialogWith:@"kInputCount" clickOK:^(NSString *inputStr) {
        
    } clickCancel:^(NSString *inputStr) {
        
    }];
    dialog.targetTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    UIView* view = [[[[UIApplication sharedApplication].delegate window] rootViewController] topViewController].view;
    
    [dialog showInView:view];
}



@end

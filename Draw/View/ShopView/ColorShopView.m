//
//  ColorShopView.m
//  Draw
//
//  Created by  on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorShopView.h"
#import "ShareImageManager.h"
#import "ColorShopCell.h"
#import "ColorGroup.h"
#import "ColorView.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationManager.h"
#import "PPDebug.h"
#import "CommonDialog.h"
#import "AccountService.h"
#import "ShoppingManager.h"
#import "AccountManager.h"
#import "DeviceDetection.h"
#import "DrawColorManager.h"

@implementation ColorShopView
@synthesize titleLabel;
@synthesize coinCountLabel;
@synthesize dataTableView;
@synthesize colorGroups;
@synthesize delegate = _delegate;



+ (ColorShopView *)colorShopViewWithFrame:(CGRect)frame 
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ColorShopView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create <ColorShopView> but cannot find cell object from Nib");
        return nil;
    }
    ColorShopView* view =  (ColorShopView*)[topLevelObjects objectAtIndex:0];
    
    //init the coin count and title 
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    UIImageView *tableBg = [[UIImageView alloc] 
                            initWithFrame:view.dataTableView.bounds];
    
    [tableBg setImage:[imageManager showcaseBackgroundImage]];
    [view.dataTableView setBackgroundView:tableBg];
    [tableBg release];
    [view.titleLabel setText:NSLS(@"kBuyColor")];
    view.dataTableView.delegate = view;
    view.dataTableView.dataSource = view;
    //get the datalist
    
    view.colorGroups = [ColorGroup colorGroupList];
    
    //sort the group, the bought color is before the unbought color
    [view.colorGroups sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
        ColorGroup *color1 = (ColorGroup *)obj1;
        ColorGroup *color2 = (ColorGroup *)obj2;
        
        NSComparisonResult result = color2.hasBought - color1.hasBought;
        if (result == NSOrderedSame) {
            return color2.groupId > color1.groupId;
        }
        return result;
    }];
    
    [view updateBalanceLabel];
    return view;
    
}

- (void)updateBalanceLabel
{
    NSString *accountString = [NSString stringWithFormat:@"x%d",[[AccountManager defaultManager] getBalance]];
    [self.coinCountLabel setText:accountString];    
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [colorGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ColorShopCell getCellIdentifier];
    ColorShopCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ColorShopCell createCell:self];
    }
    cell.indexPath = indexPath;
    ColorGroup *group = [colorGroups objectAtIndex:indexPath.row];
    [cell setCellInfo:group hasBought:group.hasBought];
    cell.colorShopCellDelegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ColorShopCell getCellHeight];
}


#define NO_COIN_TAG 201204271
#define BUY_CONFIRM_TAG 201204272
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColorGroup *group = [colorGroups objectAtIndex:indexPath.row];
    if (group.hasBought) {
        return;
    }
    AccountService *service = [AccountService defaultService];
    if (![service hasEnoughCoins:group.price]) {
        NSString *message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughTips"), group.price];
        CommonDialog *noMoneyDialog = [CommonDialog createDialogWithTitle:NSLS(@"kCoinsNotEnoughTitle") message:message style:CommonDialogStyleSingleButton delegate:self];
        noMoneyDialog.tag = NO_COIN_TAG;
        [noMoneyDialog showInView:self];
    }else{
        willBuyGroup = group;
        NSString *message = [NSString stringWithFormat:NSLS(@"kBuyColorDialogMessage"),group.price];
        CommonDialog *buyConfirmDialog = [CommonDialog createDialogWithTitle:NSLS(@"kBuyColorDialogTitle") message:message style:CommonDialogStyleDoubleButton delegate:self];
        buyConfirmDialog.tag = BUY_CONFIRM_TAG;
        [buyConfirmDialog showInView:self];
    }

}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    self.frame = view.frame;
    [view addSubview:self];
    [self setHidden:NO];
    showAnimated = animated;
    if (animated) {
        CGPoint center = self.center;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [animation setDuration:0.3];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [animation setFromValue:[NSNumber numberWithInt:center.y + 480]];
        [animation setToValue:[NSNumber numberWithInt:center.y]];
        [self.layer addAnimation:animation forKey:@"show"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeFromSuperview];
    [self setHidden:YES];
    [self.layer removeAllAnimations];
}

- (void)didPickedColorView:(ColorView *)colorView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPickedColorView:)] && colorView) {
        [self.delegate didPickedColorView:colorView];
    }
    [self clickBack:nil];
}

- (IBAction)clickBack:(id)sender {
    
    if ([sender class] == [CommonDialog class]) {
        return;
    }
    
    if (showAnimated) {
        CGPoint center = self.center;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [animation setDuration:0.3];
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        if([DeviceDetection isIPAD]){
            [animation setToValue:[NSNumber numberWithInt:center.y + 1024]];    
        }else{
            [animation setToValue:[NSNumber numberWithInt:center.y + 480]];
        }
        [self.layer addAnimation:animation forKey:@"dismiss"];
    }else{
        [self removeFromSuperview];
    }
}

- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == BUY_CONFIRM_TAG && willBuyGroup) {
        
        [[AccountService defaultService] buyItem:willBuyGroup.groupId itemCount:1 itemCoins:willBuyGroup.price];
        willBuyGroup.hasBought = YES;
        [self updateBalanceLabel];
        
        NSInteger index = [colorGroups indexOfObject:willBuyGroup];
        [willBuyGroup retain];
        [colorGroups removeObject:willBuyGroup];    
        [colorGroups insertObject:willBuyGroup atIndex:0];
        [willBuyGroup release];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [dataTableView beginUpdates];
        [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                           [NSIndexPath indexPathForRow:0 inSection:0]] 
                         withRowAnimation:UITableViewRowAnimationRight + rand() % 2];
        [dataTableView endUpdates];
        
        [dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NSArray * colorList = [ColorGroup colorListForGroupId:willBuyGroup.groupId];
        [[DrawColorManager sharedDrawColorManager] addBoughtColorList:colorList];
        willBuyGroup = nil;
    }
}



- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    PPRelease(titleLabel);
    PPRelease(coinCountLabel);
    PPRelease(dataTableView);
    PPRelease(colorGroups);
    [super dealloc];
}
@end

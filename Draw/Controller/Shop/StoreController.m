//
//  StoreController.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreController.h"
#import "GameItemService.h"
#import "StoreCell.h"
#import "BuyItemView.h"
#import "CustomInfoView.h"
#import "ChargeController.h"
#import "GiftDetailView.h"
#import "UserGameItemService.h"

@interface StoreController ()

@property (retain, nonatomic) UIButton *selectedButton;
@property (retain, nonatomic) PBGameItem *selectedItem;
@property (assign, nonatomic) int selectedCount;

@end

@implementation StoreController

- (void)dealloc {
    [_selectedButton release];
    [_titleLabel release];
    [_backButton release];
    [_chargeButton release];
    [_selectedItem release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSelectedButton:nil];
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setChargeButton:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kStore");
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    
    [self clickNormalItemsButton:nil];
    
    [GameItemService createTestDataFile];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickChargeButton:(id)sender {
    ChargeController *controller = [[ChargeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)clickNormalItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeNomal resultHandler:^(BOOL success, NSArray *itemsList) {
        bself.dataList = itemsList;
        [bself.dataTableView reloadData];
    }];
}

- (IBAction)clickToolItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [[GameItemService sharedGameItemService] getItemsListWithType:PBDrawItemTypeTool resultHandler:^(BOOL success, NSArray *itemsList) {
        bself.dataList = itemsList;
        [bself.dataTableView reloadData];
    }];
}

- (IBAction)clickPromotionItemsButton:(id)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = (UIButton *)sender;
    self.selectedButton.selected = YES;
    
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [[GameItemService sharedGameItemService] getPromotingItemsList:^(BOOL success, NSArray *itemsList) {
        bself.dataList = itemsList;
        [bself.dataTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PPDebug(@"dataList : %@", dataList);
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [StoreCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [StoreCell createCell:self];
    }
    
    [cell setCellInfo:[self.dataList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"select row: %d", indexPath.row);
    PBGameItem *item = [dataList objectAtIndex:indexPath.row];
    BuyItemView *buyItemView = [BuyItemView createWithItem:item];
    CustomInfoView *cusInfoView = [CustomInfoView createWithTitle:NSLS(item.name)
                                                      infoView:buyItemView 
                                                hasCloseButton:YES
                                                  buttonTitles:NSLS(@"kBuy"), NSLS(@"kGive"), nil];
    [cusInfoView showInView:self.view];

    __block typeof (self) bself = self;
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        int count = ((BuyItemView *)infoView).count;
        if (button.tag == 0) {
            PPDebug(@"you buy %d %@", count, NSLS(item.name));

            [cusInfoView enableButtons:NO];
            [button setTitle:@"kBuying..." forState:UIControlStateNormal];
            [cusInfoView showActivity];
            [[UserGameItemService defaultService] buyItem:item count:count handler:^(int resultCode, PBGameItem *item, int count, NSString *toUserId) {
                [cusInfoView dismiss];
                if (resultCode == 0) {
                    [bself popupHappyMessage:@"kYouBuy" title:nil];
                }
            }];
        }else{
            PPDebug(@"you give %d %@", count, NSLS(item.name));
            
            bself.selectedCount = count;
            bself.selectedItem = item;
            
            FriendController *vc = [[[FriendController alloc] initWithDelegate:bself] autorelease];
            [bself.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    [controller.navigationController popViewControllerAnimated:YES];
    GiftDetailView *giftDetailView = [GiftDetailView createWithItem:_selectedItem myFriend:aFriend count:_selectedCount];
    
    CustomInfoView *cusInfoView = [CustomInfoView createWithTitle:NSLS(@"kGive")
                                                         infoView:giftDetailView
                                                   hasCloseButton:YES
                                                     buttonTitles:NSLS(@"kCancel"), NSLS(@"kOK"), nil];
    [cusInfoView showInView:self.view];
    
    __block typeof (self) bself = self;
    [cusInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        [cusInfoView dismiss];
        // TO DO
        if (button.tag == 1) {
            [[UserGameItemService defaultService] buyItem:_selectedItem count:_selectedCount handler:^(int resultCode, PBGameItem *item, int count, NSString *toUserId) {
                if (resultCode == 0) {
                    [bself popupHappyMessage:@"kYouGive" title:nil];
                }
            }];
        }
    }];
}

@end

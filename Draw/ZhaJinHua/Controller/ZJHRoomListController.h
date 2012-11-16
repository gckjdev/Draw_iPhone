//
//  ZJHRoomListController.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "CommonRoomListController.h"
#import "ZJHRoomListCell.h"
#import "UIGlossyButton.h"

@interface ZJHRoomListController : CommonRoomListController <CommonRoomListCellDelegate>

@property (retain, nonatomic) IBOutlet UIButton *titleFontButton;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIGlossyButton *createRoomButton;
@property (retain, nonatomic) IBOutlet UIGlossyButton *fastEntryButton;
@property (retain, nonatomic) IBOutlet UIButton *allRoomButton;
@property (retain, nonatomic) IBOutlet UIButton *friendRoomButton;
@property (retain, nonatomic) IBOutlet UIButton *nearByRoomButton;
@property (retain, nonatomic) IBOutlet UILabel *emptyListTips;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

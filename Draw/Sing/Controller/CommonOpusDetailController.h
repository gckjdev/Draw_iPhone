//
//  CommonOpusDetailController.h
//  Draw
//
//  Created by 王 小涛 on 13-5-31.
//
//

#import "PPTableViewController.h"
#import "Opus.pb.h"
#import "CommonUserInfoCell.h"
#import "CommonOpusInfoCell.h"
#import "CommonActionHeader.h"

@interface CommonOpusDetailController : PPTableViewController

@property (retain, nonatomic) PBOpus *pbOpus;
@property (assign, nonatomic) Class userInfoCellClass;
@property (assign, nonatomic) Class opusInfoCellClass;
@property (assign, nonatomic) Class actionHeaderClass;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

// if you want to do something before back, overwrite "clickBack:" please, and  remenber to call "[super clickBack:sender] in your overwrite method"

// Overwrite these methods below in your sub-class.
- (void)clickOnOpus:(PBOpus *)opus;
- (void)clickOnTargetUser:(PBGameUser *)user;
- (void)clickAction:(id)sender;

@end

//
//  CommonOpusDetailController.h
//  Draw
//
//  Created by 王 小涛 on 13-5-31.
//
//

#import "PPTableViewController.h"
#import "Opus.h"
#import "CommonUserInfoCell.h"
#import "CommonOpusInfoCell.h"
#import "CommonCommentHeader.h"
#import "CommonTabController.h"
#import "FeedService.h"
#import "ShareEditController.h"
#import "OpusService.h"
#import "UserService.h"

@interface CommonOpusDetailController : CommonTabController<FeedServiceDelegate, OpusServiceDelegate, UserServiceDelegate>

@property (retain, nonatomic) Opus *opus;
@property (assign, nonatomic) Class userInfoCellClass;
@property (assign, nonatomic) Class opusInfoCellClass;
@property (assign, nonatomic) Class actionHeaderClass;
@property (assign, nonatomic) Class guessControllerClass;

@property (retain, nonatomic) IBOutlet UIButton *shareButton;
// if you want to do something before back, overwrite "clickBack:" please, and  remenber to call "[super clickBack:sender] in your overwrite method"

// Overwrite these methods below in your sub-class.
//- (void)clickOnAuthor:(PBGameUser *)author;
- (void)clickOnOpus:(PBOpus *)opus;
//- (void)clickOnTargetUser:(PBGameUser *)user;


- (IBAction)clickGuessActionButton:(UIButton *)button;
- (IBAction)clickCommentActionButton:(UIButton *)button;
- (IBAction)clickShareActionButton:(UIButton *)button;
- (IBAction)clickSaveActionButton:(UIButton *)button;

// implemente in sub-class
- (void)shareToSinaWeibo;
- (void)shareToTencentWeibo;
- (void)shareToFacebook;
- (void)shareToWeChatTimeline;
- (void)shareToWeChatFriends;
- (void)shareViaEmail;
- (void)saveToAlbum;
- (void)saveAsFavorite;

- (void)bindSNS:(int)snsType;
- (void)shareViaSNS:(SnsType)type
               text:(NSString *)text
      imageFilePath:(NSString *)imageFilePath;

@end

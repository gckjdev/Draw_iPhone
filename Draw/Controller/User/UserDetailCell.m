//
//  UserDetailCell.m
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "UserDetailCell.h"
#import "GameBasic.pb.h"
#import "CommonRoundAvatarView.h"
#import "ShareImageManager.h"
#import "UserDetailProtocol.h"
#import "UserSettingController.h"
#import "LevelService.h"
#import "GameSNSService.h"
#import "SNSUtils.h"
#import "TimeUtils.h"
#import "PPSNSCommonService.h"
#import "CustomSegmentedControl.h"
#import "ShareImageManager.h"
#import "FeedCarousel.h"
#import "UIColor+UIColorExt.h"
#import "RoundPercentageView.h"
#import "UIImageView+WebCache.h"

#define NICK_NAME_FONT (ISIPAD?30:15)
#define NICK_NAME_MAX_WIDTH (ISIPAD?424:181)

#define USER_ACTION_BTN_INDEX_OFFSET    20130330
#define USER_ACTION_BTN_COUNT 5

@interface UserDetailCell ()

@property (retain, nonatomic) CustomSegmentedControl* segmentedControl;
@property (retain, nonatomic) FeedCarousel *carousel;

@end

@implementation UserDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail
{
    PBGameUser* pbUser = [detail getUser];
    [self.levelLabel setText:[NSString stringWithFormat:@"lv.%d", [detail getUser].level]];
    [self.nickNameLabel setText:pbUser.nickName];
    [self.signLabel setText:pbUser.signature];
    
    if ([detail isPrivacyVisable]) {
        
        NSDate* date = dateFromStringByFormat(pbUser.birthday, @"yyyyMMdd");
        [self.birthLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBirthday"), ([pbUser hasBirthday]?dateToString(date):@"-")]];
        NSString* zodiacStr = [pbUser hasZodiac]?[LocaleUtils getZodiacWithIndex:pbUser.zodiac-1]:@"-";
        zodiacStr = (zodiacStr != nil)?zodiacStr:@"-";
        [self.zodiacLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kZodiac"),zodiacStr]];
        [self.bloodTypeLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBloodGroup"), ([pbUser hasBloodGroup]?pbUser.bloodGroup:@"-")]];
    } else {
        [self.birthLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBirthday"), NSLS(@"kInvisable")]];
        [self.zodiacLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kZodiac"),NSLS(@"kInvisable")]];
        [self.bloodTypeLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBloodGroup"), NSLS(@"kInvisable")]];
    }
    
    [self.locationLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kLocation"), ([pbUser hasLocation]?pbUser.location:@"-")]];
    
    [self.followCountLabel setText:[NSString stringWithFormat:@"%d", pbUser.followCount]];
    [self.fanCountLabel setText:[NSString stringWithFormat:@"%d", pbUser.fanCount]];

    [self.avatarView setAvatarUrl:pbUser.avatar gender:pbUser.gender];
    
    self.basicDetailView.hidden = YES;
    
    [self.editButton setHidden:![detail canEdit]];
    [self.customBackgroundControl setHidden:![detail canEdit]];
    [self.blackListBtn setHidden:![detail isBlackBtnVisable]];
    [self.superBlackBtn setHidden:![detail isSuperManageBtnVisable]];
    
    [self.genderImageView setImage:[[ShareImageManager defaultManager] userDetailGenderImage:[pbUser gender]]];
    
    [detail initSNSButton:self.sinaBtn withType:TYPE_SINA];
    [detail initSNSButton:self.qqBtn withType:TYPE_QQ];
    [detail initSNSButton:self.facebookBtn withType:TYPE_FACEBOOK];
    
    for (int i = 0; i < USER_ACTION_BTN_COUNT; i ++) {
        UserDetailRoundButton* btn =(UserDetailRoundButton*)[self viewWithTag:(USER_ACTION_BTN_INDEX_OFFSET+i)];
        [detail initUserActionButton:btn atIndex:i];
    }
    
    [self.blackListBtn setTitle:[detail blackUserBtnTitle] forState:UIControlStateNormal];
    
    [self adjustView:self.genderImageView toLabel:self.nickNameLabel];
    [self adjustView:self.levelLabel toLabel:self.signLabel];
    
    [self.segmentedControl setHidden:![detail hasFeedTab]];
    
    [self.noSNSTipsLabel setHidden:!(self.sinaBtn.hidden && self.qqBtn.hidden && self.facebookBtn.hidden)];
    
    [self.customBackgroundImageView setImageWithURL:[NSURL URLWithString:[[detail getUser] backgroundUrl]]];
    
    [self.customBackgroundControl addTarget:self action:@selector(clickCustomBackground:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)adjustView:(UIView*)view
           toLabel:(UILabel*)label
{
    NSString* text = label.text;
    if (text == nil || text.length <= 0) {
        [view setCenter:label.center];
        return;
    }
    CGSize size = [text sizeWithFont:label.font];
    if (size.width < label.frame.size.width) {
        CGPoint orgPoint = CGPointMake(label.frame.origin.x - view.frame.size.width/2 , label.center.y);
        orgPoint.x += (label.frame.size.width - size.width)/2;
        [view setCenter:orgPoint];
    }
}

+ (float)getCellHeight
{
    return ([DeviceDetection isIPAD]?1469:706);
}

+ (NSString*)getCellIdentifier
{
    return @"UserDetailCell";
}

#define CAROUSEL_CENTER (ISIPAD ? CGPointMake(384, 930) : CGPointMake(160, 455))

#define TAB_FONT    (ISIPAD?24:12)

+ (id)createCell:(id)delegate
{
    UserDetailCell* cell = (UserDetailCell*)[super createCell:delegate];
    cell.avatarView.delegate = cell;
    cell.segmentedControl = [[[CustomSegmentedControl alloc]
                              initWithSegmentTitles:@[NSLS(@"kUserOpus"), NSLS(@"kFavorite")]
                              frame:cell.feedTabHolder.frame
                              unpressedImage:[ShareImageManager defaultManager].userDetailTabBgImage
                              pressedImage:[ShareImageManager defaultManager].userDetailTabBgPressedImage
                              delegate:cell] autorelease];
    [cell addSubview:cell.segmentedControl];
    [cell.segmentedControl setFrame:cell.feedTabHolder.frame];
    [cell.segmentedControl setTitleColor:OPAQUE_COLOR(100, 72, 40) forState:UIControlStateNormal];
    [cell.segmentedControl setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [cell.segmentedControl setTitleFont:[UIFont systemFontOfSize:TAB_FONT]];
    
    cell.carousel = [FeedCarousel createFeedCarousel];
    cell.carousel.delegate = cell;
    cell.carousel.center = CAROUSEL_CENTER;
    [cell addSubview:cell.carousel];
    [cell.carousel startScrolling];
    [cell.carousel enabaleWrap:YES];
    [cell.carousel showActivity];
    
    
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_carousel release];
    [_nickNameLabel release];
    [_signLabel release];
    [_levelLabel release];
    [_birthLabel release];
    [_zodiacLabel release];
    [_bloodTypeLabel release];
    [_locationLabel release];
    [_avatarView release];
    [_basicDetailView release];
    [_genderImageView release];
    [_backgroundImageView release];
    [_fanCountLabel release];
    [_followCountLabel release];
    [_editButton release];
    [_drawToButton release];
    [_chatButton release];
    [_followButton release];
    [_fanCountButton release];
    [_followCountButton release];
    [_sinaBtn release];
    [_qqBtn release];
    [_facebookBtn release];
    [_blackListBtn release];
    [_superBlackBtn release];
    [_feedTabHolder release];
    [_segmentedControl release];
    [_noSNSTipsLabel release];
    [_customBackgroundControl release];
    [_customBackgroundImageView release];
    [super dealloc];
}

#pragma mark - CustomSegmentedControl delegate
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickTabAtIndex:)]) {
        [_detailDelegate didClickTabAtIndex:segmentIndex];
    }
}

-(IBAction)switchBasicInfoAndAction:(id)sender
{
    [self.basicDetailView setHidden:!self.basicDetailView.hidden];
}

- (IBAction)clickEdit:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickEdit)]) {
        [_detailDelegate didClickEdit];
    }
}

- (IBAction)clickFollow:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFollowButton)]) {
        [_detailDelegate didClickFollowButton];
    }
}

- (IBAction)clickFollowCount:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFollowCountButton)]) {
        [_detailDelegate didClickFollowCountButton];
    }
}

- (IBAction)clickFanCount:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFanCountButton)]) {
        [_detailDelegate didClickFanCountButton];
    }
}

- (IBAction)clickChatButton:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickChatButton)]) {
        [_detailDelegate didClickChatButton];
    }
}

- (IBAction)clickDrawToButton:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickDrawToButton)]) {
        [_detailDelegate didClickDrawToButton];
    }
}

- (void)didClickOnAvatar:(CommonRoundAvatarView*)view
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickAvatar)]) {
        [_detailDelegate didClickAvatar];
    }
}

- (IBAction)clickBlack:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickBlack)]) {
        [_detailDelegate didclickBlack];
    }
}

- (IBAction)clickManage:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickManage)]) {
        [_detailDelegate didclickManage];
    }
}

- (IBAction)clickSina:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickSina)]) {
        [_detailDelegate didclickSina];
    }
}

- (IBAction)clickQQ:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickQQ)]) {
        [_detailDelegate didclickQQ];
    }
}

- (IBAction)clickFacebook:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickFacebook)]) {
        [_detailDelegate didclickFacebook];
    }
}

- (IBAction)clickMore:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickMore)]) {
        [_detailDelegate didClickMore];
    }
}

- (IBAction)clickUserAction:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickUserActionButtonAtIndex:)]) {
        [_detailDelegate didClickUserActionButtonAtIndex:(((UIButton*)sender).tag - USER_ACTION_BTN_INDEX_OFFSET)];
    }
}

- (IBAction)clickCustomBackground:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickCustomBackground)]) {
        [_detailDelegate didClickCustomBackground];
    }
}

- (void)setDrawFeedList:(NSArray*)feedList
{
    [self.carousel setDrawFeedList:feedList];
}

- (void)setIsLoadingFeed:(BOOL)isLoading
{
    if (isLoading) {
        [self.carousel showActivity];
    } else {
        [self.carousel hideActivity];
    }

}

#pragma mark - feedCarousel delegate
- (void)didSelectDrawFeed:(DrawFeed *)drawFeed
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickDrawFeed:)]) {
        [_detailDelegate didClickDrawFeed:drawFeed];
    }
}



@end

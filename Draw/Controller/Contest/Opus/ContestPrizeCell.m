//
//  ContestPrizeCell.m
//  Draw
//
//  Created by gamy on 13-8-26.
//
//

#import "ContestPrizeCell.h"
#import "UIImageView+Extend.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"

#define VALUE(X) (ISIPAD ? 2*(X) : (X))

@implementation ContestPrizeCell

+ (id)createCell:(id)delegate
{
    NSInteger index = (ISIPAD ? 1 : 0);
    ContestPrizeCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier] ofViewIndex:index];
    cell.delegate = delegate;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"ContestPrizeCell";
}

+ (CGFloat)getCellHeight
{
    return ISIPAD ? 340: 140;
}



- (void)dealloc {
    [_opusImage release];
    [_prizeIcon release];
    [_nickButton release];
    [_avatar release];
    [_prizeLabel release];
    PPRelease(_opus);
    [super dealloc];
}

- (void)enterUserDetail
{
    ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUserId:_opus.feedUser.userId avatar:_opus.feedUser.avatar nickName:_opus.feedUser.nickName];
    [UserDetailViewController presentUserDetail:detail inViewController:(id)[self theViewController]];
}

- (void)didClickOnAvatar:(NSString*)userId
{
    [self enterUserDetail];
}

- (IBAction)clickNickButton:(id)sender {
    [self enterUserDetail];
    
}
#define KEY(X) @(X)
- (UIImage *)imageForPrize:(ContestPrize)prize
{
    NSDictionary *dict = @{KEY(ContestPrizeFirst): @"contest_prize_1@2x.png",
                           KEY(ContestPrizeSecond): @"contest_prize_2@2x.png",
                           KEY(ContestPrizeThird): @"contest_prize_3@2x.png",
                           KEY(ContestPrizeSpecial): @"contest_prize_special@2x.png",
                           };
    NSString *name = [dict objectForKey:KEY(prize)];
    return name ? [UIImage imageNamed:name] : nil;
}

#define TOP_PRIZE_SIZE CGSizeMake(VALUE(42), VALUE(56))
#define SPECIAL_PRIZE_SIZE CGSizeMake(VALUE(114), VALUE(47))

- (void)updatePrizeImageWithPrize:(ContestPrize)prize
                            title:(NSString *)title
{
    if (prize == ContestPrizeSpecial) {
        [self.prizeIcon updateWidth:SPECIAL_PRIZE_SIZE.width];
        [self.prizeIcon updateHeight:SPECIAL_PRIZE_SIZE.height];
        [self.prizeLabel setHidden:NO];
        [self.prizeLabel setText:title];
    }else{
        [self.prizeIcon updateWidth:TOP_PRIZE_SIZE.width];
        [self.prizeIcon updateHeight:TOP_PRIZE_SIZE.height];
        [self.prizeLabel setHidden:YES];
    }
    [self.prizeIcon setImage:[self imageForPrize:prize]];
    
}

- (void)updateUserInfo:(ContestFeed *)opus
{
    [self.avatar setGender:opus.feedUser.gender];
    [self.avatar setUrlString:opus.feedUser.avatar];
    [self.avatar setUserId:opus.feedUser.userId];
    [self.avatar setDelegate:self];
    [self.nickButton setTitle:opus.feedUser.nickName forState:UIControlStateNormal];
    
}

- (void)updateOpus:(ContestFeed *)opus
{
    self.opus = opus;
    [self.opusImage setImageWithUrl:opus.thumbURL placeholderImage:[[ShareImageManager defaultManager] unloadBg] showLoading:YES animated:YES];
}

#define BG_TAG 348923
#define EDGE_SPACE (ISIPAD ? 10 : 5)

- (void)setShowBg:(BOOL)show
{
    UIView *view = [self viewWithTag:BG_TAG];
    if (view == nil) {
        CGRect frame = [self bounds];
        frame = CGRectInset(frame, EDGE_SPACE, 3);
        view = [self reuseViewWithTag:BG_TAG viewClass:[UIView class] frame:frame];
        [view.layer setCornerRadius:4];
        [view.layer setMasksToBounds:YES];
        SET_VIEW_BG(view);
        [self sendSubviewToBack:view];
    }
    view.hidden = !show;
}

- (void)setPrize:(ContestPrize)prize
           title:(NSString *)title
            opus:(ContestFeed *)opus
{
    [self updatePrizeImageWithPrize:prize title:title];
    [self updateUserInfo:opus];
    [self updateOpus:opus];
}

@end

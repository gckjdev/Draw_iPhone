//
//  PrizeCell.m
//  Draw
//
//  Created by ChaoSo on 14-8-21.
//
//

#import "PrizeCell.h"
#import "UIImageView+Extend.h"
#import "DrawFeed.h"
#import "UIViewController+CommonHome.h"
#import "ViewUserDetail.h"
#import "UserDetailViewController.h"
#import "FeedListController.h"
#import "ShowFeedController.h"
@interface PrizeCell()
@property (nonatomic,retain)DrawFeed *feed;

@end
@implementation PrizeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#define DEFAULT_IMAGE @"xiaoguanka"
#define BG_TAG 20140822
#define EDGE_SPACE (ISIPAD ? 10 : 5)
- (void)setCellInfo:(DrawFeed *)feed row:(NSInteger)row
{
    self.feed = feed;
    [self.opusImageView setImageWithUrl:[NSURL URLWithString:feed.pbFeed.opusImage]
                   placeholderImage:[UIImage imageNamed:DEFAULT_IMAGE]
                        showLoading:NO
                           animated:YES];
    [self.avatarView setUrlString:feed.pbFeed.avatar];
    [self.userNameLabel setText:feed.pbFeed.nickName];
    [self.userNameLabel setTextColor:COLOR_GREEN];
    int32_t score = feed.pbFeed.stageScore;

    //分数用Attribute String
    [self.rankDesc setTextColor:COLOR_GREEN];
    [self.rankDesc setFont:AD_FONT(20, 15)];
    NSString *scoreString = [NSString stringWithFormat:@"%d",score];
    NSString *scoreDesc = [NSString stringWithFormat:@"%d分",score];
    
    NSRange range = [scoreDesc rangeOfString:scoreString];
    NSMutableAttributedString *scoreAttr = [
                                        [[NSMutableAttributedString alloc]
                                         initWithString:
                                         scoreDesc
                                         ]autorelease];
    [scoreAttr addAttribute:NSForegroundColorAttributeName
                  value:COLOR_RED
                  range:range
     ];
    [scoreAttr addAttribute:NSFontAttributeName
                  value:AD_FONT(40, 30)
                  range:range
     ];
    
    
    self.rankDesc.attributedText = scoreAttr;
   
    
    
//    [self.rankDesc setText:rankDesc];
   
    if(row%2==0){
        [self showBg:YES];
    }else{
        [self showBg:NO];
    }
   
    [self setPrize:row+1];
    [self setListenForNameLabelAndAvatar];
    [self setSelfViewListen ];
    
}
-(void)showBg:(BOOL)isShow{
    
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
    view.hidden = !isShow;
    
    
    
}
+(NSString *)getCellIdentifier{
    
    return @"PrizeCell";
}


+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    PrizeCell *cell = [PrizeCell createViewWithXibIdentifier:cellId];
    cell.delegate = delegate;
    
    return cell;
}
#define BASE_HEIGHT (ISIPAD ? 335 : 150)
+ (CGFloat)getCellHeightWithFeed
{
    return BASE_HEIGHT;
}

#define KEY(X) @(X)
-(void)setPrize:(NSInteger)prize{
    NSDictionary *dict = @{KEY(PizeCellPrizeFirst): @"contest_prize_1@2x.png",
                           KEY(PizeCellPrizeSecond): @"contest_prize_2@2x.png",
                           KEY(PizeCellPrizeThird): @"contest_prize_3@2x.png",
                           KEY(PizeCellPrizeMine): @"contest_prize_special@2x.png",
                           KEY(PizeCellPrizeCustom):
                               @"contest_prize_custom@2x.png",
                           };
    [self.rankNumber removeAllSubviews];
   
    if(prize==1){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[dict objectForKey:KEY(PizeCellPrizeFirst)]]];
        imageView.frame = _rankNumber.frame;
        [self.rankNumber addSubview:imageView];
        [imageView release];
    }
    else if(prize==2){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[dict objectForKey:KEY(PizeCellPrizeSecond)]]];
        imageView.frame = _rankNumber.frame;
        [self.rankNumber addSubview:imageView];
        [imageView release];
    }
    else if(prize==3){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[dict objectForKey:KEY(PizeCellPrizeThird)]]];
        imageView.frame = _rankNumber.frame;
        [self.rankNumber addSubview:imageView];
        [imageView release];
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[dict objectForKey:KEY(PizeCellPrizeCustom)]]];
        imageView.frame = _rankNumber.frame;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (ISIPAD?9.0f:5.0f), imageView.frame.size.width, imageView.frame.size.height/2)];
        [label setText:[NSString stringWithFormat:@"%d",prize]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:AD_FONT(29, 17)];
        [label setTextColor:COLOR_WHITE];
        [imageView addSubview:label];
        [self.rankNumber addSubview:imageView];
        [label release];
        [imageView release];
    }
    
}

- (void)enterUserDetailController
{
    FeedUser *user = self.feed.feedUser;
    ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUserId:user.userId
                                                               avatar:user.avatar
                                                             nickName:user.nickName];
    [UserDetailViewController presentUserDetail:detail
                               inViewController:(id)[self theViewController]];
}
-(void)enterOpusDetail{
    FeedListController *fc = [[[FeedListController alloc] init] autorelease];
    [fc showFeed:self.feed];
}


#pragma mark - Listen
-(void)setListenInView:(UIView*)view selector:(SEL)selector{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [view addGestureRecognizer:singleTap];
}
-(void)setListenForNameLabelAndAvatar{
    [self setListenInView:_userNameView selector:@selector(enterUserDetailController)];
    [self setListenInView:_avatarView selector:@selector(enterUserDetailController)];
}
// just replace PPTableViewCell by the new Cell Class Name
#define BASE_BUTTON_INDEX 10
- (IBAction)clickImageView:(id)sender {
    [ShowFeedController enterWithFeedId:self.feed.feedId fromController:delegate];
}
-(void)setSelfViewListen{
    [self setListenInView:self selector:@selector(clickImageView:)];
}




- (void)dealloc {
    [_rankNumber release];
    [_avatarView release];
    [_userNameLabel release];
    [_opusImageView release];
    [_rankDesc release];
    [_userNameView release];
    [_opusView release];
    [super dealloc];
}
@end

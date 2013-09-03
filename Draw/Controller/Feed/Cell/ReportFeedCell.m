//
//  ReportFeedCell.m
//  Draw
//
//  Created by Gamy on 13-9-3.
//
//

#import "ReportFeedCell.h"
#import "UIImageView+Extend.h"
#import "DrawFeed.h"
#import "TimeUtils.h"

@implementation ReportFeedCell

- (void)dealloc
{
    PPRelease(_bgImageView);
    PPRelease(_descLabel);
    PPRelease(_userNameLabel);
    PPRelease(_timeLabel);
    PPRelease(_drawImageView);
    PPRelease(_avatarView);
    PPRelease(_feed);
    [super dealloc];
}

// just replace PPTableViewCell by the new Cell Class Name
+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    ReportFeedCell *cell = [ReportFeedCell createViewWithXibIdentifier:cellId ofViewIndex:ISIPAD];
    cell.delegate = delegate;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"ReportFeedCell";
}

#define DESC_FONT (ISIPAD ? [UIFont systemFontOfSize:25] : [UIFont systemFontOfSize:12])

#define DESC_WIDTH (ISIPAD ? 630 : 250)
#define BASE_HEIGHT (ISIPAD ? 280 : 130)

- (void)setCellAppearance{    
    self.userNameLabel.textColor = COLOR_BROWN;
    self.descLabel.textColor = COLOR_ORANGE;
    self.timeLabel.textColor = COLOR_YELLOW;
    self.descLabel.font = DESC_FONT;
    self.descLabel.numberOfLines = 0;
    
    SET_VIEW_ROUND_CORNER(self.drawImageView);
    [self.bgImageView setImage:[ShareImageManager bubleImage]];
    [self.drawImageView setBackgroundColor:[UIColor clearColor]];
}


+ (CGFloat)getCellHeightWithFeed:(CommentFeed *)feed
{
    CGSize size = [[feed displayText] sizeWithFont:DESC_FONT constrainedToSize:CGSizeMake(DESC_WIDTH, MAXFLOAT) lineBreakMode:0];
    return BASE_HEIGHT+size.height;
}


- (void)updateTime:(CommentFeed *)feed
{
    NSString *timeString = dateToTimeLineString(feed.createDate);
    [self.timeLabel setText:timeString];
}

- (void)updateUser:(CommentFeed *)feed
{
    //avatar
    NSString *avatar = [feed.feedUser avatar];
    NSString *userId = [feed.feedUser userId];
    BOOL gender = [feed.feedUser gender];

    [self.avatarView setDelegate:self];
    self.avatarView.delegate = self;
    [self.avatarView setUrlString:avatar];
    [self.avatarView setUserId:userId];
    [self.avatarView setGender:gender];

    //name
    if ([feed isMyFeed]) {
        [self.userNameLabel setText:NSLS(@"Me")];
    }else{
        [self.userNameLabel setText:feed.feedUser.nickName];
    }
}

- (void)updateDrawView:(CommentFeed *)feed
{
    DrawFeed *drawFeed = [feed drawFeed];
    if (drawFeed) {
        NSString *imageUrl = [drawFeed drawImageUrl];
        [self.drawImageView setImage:[[ShareImageManager defaultManager]
                                      unloadBg]];
        if ([imageUrl length] != 0) {
            NSURL *url = [NSURL URLWithString:imageUrl];
            UIImage *defaultImage = [[ShareImageManager defaultManager] unloadBg];
            
            [self.drawImageView setImageWithUrl:url
                               placeholderImage:defaultImage
                                    showLoading:YES
                                       animated:YES];
        }
    }
}

- (void)updateDesc:(CommentFeed *)feed
{
    [self.descLabel setText:[feed displayText]];
}

- (void)setCellInfo:(CommentFeed *)feed
{
    self.feed = feed;
    [self setCellAppearance];
    [self updateDesc:feed];
    [self updateTime:feed];
    [self updateUser:feed];
    [self updateDrawView:feed];
    
}



@end

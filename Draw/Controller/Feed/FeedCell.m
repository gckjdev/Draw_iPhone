//
//  FeedCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"
#import "TimeUtils.h"
#import "Feed.h"
#import "Draw.h"
#import "UserManager.h"
#import "ShareImageManager.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "WordManager.h"
#import "Word.h"
#import "DeviceDetection.h"

@implementation FeedCell
@synthesize guessStatLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize avatarView = _avatarView;
@synthesize drawView = _drawView;
@synthesize feed = _feed;

#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(12, 20, 83, 82) : CGRectMake(5, 9, 35, 36))
#define SHOW_DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(530, 9, 170, 170) :CGRectMake(222, 4, 70, 72))
#define FEED_CELL_HEIGHT ([DeviceDetection isIPAD] ?  228 : 100)
#define DESC_WIDTH ([DeviceDetection isIPAD] ?  400 : 170)
#define DESC_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:14 * 2] : [UIFont systemFontOfSize:14])

+ (id)createCell:(id)delegate
{

    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    FeedCell *cell = ((FeedCell*)[topLevelObjects objectAtIndex:0]);
    
    cell.delegate = delegate;
    
    if (cell) {

        cell.drawView = [[[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME]autorelease];
        [cell addSubview:cell.drawView];
        if ([cell.drawView isKindOfClass:[ShowDrawView class]]){
            [(ShowDrawView*)cell.drawView setShowPenHidden:YES];
        }
        cell.drawView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"FeedCell";
}

+ (CGFloat)getCellHeight
{
    return FEED_CELL_HEIGHT;
    
}


- (void)updateTime:(Feed *)feed
{
    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(feed.createDate);
    } else {
        timeString = englishBeforeTime(feed.createDate);
    }
    
    if (timeString) {
        [self.timeLabel setText:timeString];
    }else {
        NSString *formate = @"yy-MM-dd HH:mm";
        timeString = dateToStringByFormat(feed.createDate, formate);
        [self.timeLabel setText:timeString];
    }
}


- (void)updateDesc:(Feed *)feed
{
    NSString *desc = @"";
    NSString *creatorNick = [FeedManager opusCreatorForFeed:feed];
    NSString *word = feed.wordText;
    NSString *creatorId = feed.authorId;
    
    NSString *targetNick= [FeedManager targetNameForFeed:feed];
    if (feed.drawData.languageType == ChineseType 
        && [LocaleUtils isTraditionalChinese]) {
        word = [WordManager changeToTraditionalChinese:word];
    }
    
    FeedActionDescType descType = [FeedManager feedActionDescFor:feed];
    switch (descType) {
        case FeedActionDescDrawed:
            desc = [NSString stringWithFormat:NSLS(@"kDrawDesc"), word];  
            break;
        case FeedActionDescDrawedNoWord:
            desc = NSLS(@"kDrawDescNoWord");  
            break;
            
        case FeedActionDescDrawedToUser:
            desc = [NSString stringWithFormat:NSLS(@"kDrawToUserDesc"), word, targetNick];  
            break;
            
        case FeedActionDescDrawedToUserNoWord:
            desc = [NSString stringWithFormat:NSLS(@"kDrawToUserNoWordDesc"),targetNick];  
            break;
            
        case FeedActionDescGuessed:
            if ([creatorId isEqualToString:[UserManager defaultManager].userId]) {
                desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc_MyDraw"), word]; 
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc"),creatorNick, word];
            }
            break;
        case FeedActionDescGuessedNoWord:
            if ([creatorId isEqualToString:[UserManager defaultManager].userId]) {
                desc = [NSString stringWithFormat:NSLS(@"kGuessRightDescNoWord_MyDraw")];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kGuessRightDescNoWord"), creatorNick]; 
            }
            break;
        case FeedActionDescTried:
            if ([creatorId isEqualToString:[UserManager defaultManager].userId]) {
                desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc_MyDraw"), word];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc"),creatorNick , word]; 
            }
              
            break;
        case FeedActionDescTriedNoWord:
            if ([creatorId isEqualToString:[UserManager defaultManager].userId]) {
                desc = [NSString stringWithFormat:NSLS(@"kTryGuessDescNoWord_MyDraw")];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kTryGuessDescNoWord"), creatorNick]; 
            }
              
            break;

            
        default:
            break;
    }
    
    
    CGPoint origin = self.descLabel.frame.origin;
    UIFont *font = DESC_FONT;
    CGSize maxSize = CGSizeMake(DESC_WIDTH, 1000000);
    
    CGSize labelSize = [desc sizeWithFont:font constrainedToSize:maxSize 
         lineBreakMode:UILineBreakModeWordWrap];

    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    
    [self.descLabel setText:desc];
}

- (void)updateUser:(Feed *)feed
{
    //avatar
    
    [self.avatarView removeFromSuperview];
    [self.avatarView setDelegate:nil];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:feed.avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    self.avatarView.userId = feed.userId;
    self.avatarView.delegate = self;
    [self addSubview:self.avatarView];
    
    //name
    [self.userNameLabel setText:[FeedManager userNameForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.guessTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.guessTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}


- (void)updateDrawViewWithDrawData:(Feed *)feed
{
    CGRect normalFrame = DRAW_VIEW_FRAME;
    CGRect currentFrame = SHOW_DRAW_VIEW_FRAME;
    ShowDrawView *view = [[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME];
    [self.drawView removeFromSuperview];
    self.drawView = view;
    [self addSubview:self.drawView];
    [view release];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
        CGFloat yScale = currentFrame.size.height / normalFrame.size.height;        
        
        view.drawActionList = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (feed == self.feed) {
                [view show];
                feed.drawImage = [view createImage];
                [[ShareImageManager defaultManager] saveImage:feed.drawImage 
                                                withImageName:[feed saveKey] 
                                                         asyn:YES];               
            }
            
        });
    });
    
}

- (void)updateDrawView:(Feed *)feed
{
    [self.drawView removeFromSuperview];
    
    if (feed.drawImage == nil) {
        feed.drawImage = [[ShareImageManager defaultManager] getImageWithName:[feed saveKey]];
    }
    
    if (feed.drawImage) {
        UIImageView* imageView = [[UIImageView alloc] 
                                  initWithImage:feed.drawImage];
        self.drawView = imageView;
        [imageView release];
        self.drawView.frame = SHOW_DRAW_VIEW_FRAME;
        [self addSubview:self.drawView];
    }else if(feed.drawData){
        PPDebug(@"<updateDrawView> feed = %@, image is nil, use draw data to show.", feed.feedId);
        [self updateDrawViewWithDrawData:feed];
    }else{
        [FeedManager parseDrawData:feed delegate:self];
    }
}
- (void)setCellInfo:(Feed *)feed
{
    self.feed = feed;
    [self updateDrawView:feed];
    [self updateDesc:feed];
    [self updateTime:feed];
    [self updateUser:feed];
    [self updateGuessDesc:feed];
}


- (IBAction)clickActionButton:(id)sender {
    //
    ActionType type = [FeedManager actionTypeForFeed:self.feed];
    if (type == ActionTypeGuess) {
        if (delegate && [delegate respondsToSelector:@selector(didClickGuessButtonOnFeed:)]) {
            [delegate didClickGuessButtonOnFeed:self.feed];
        }
    }else if(type == ActionTypeOneMore){
        if (delegate && [delegate respondsToSelector:@selector(didClickDrawOneMoreButtonAtIndexPath:)]) {
            [delegate didClickDrawOneMoreButtonAtIndexPath:self.indexPath];
        }
    }
}

- (void)didClickOnAvatar:(NSString*)userId
{
    if (delegate && [delegate respondsToSelector:@selector(didClickAvatar:nickName:gender:atIndexPath:)]) {
        [delegate didClickAvatar:self.feed.userId 
                        nickName:self.feed.nickName 
                          gender:self.feed.gender 
                     atIndexPath:self.indexPath];
    }
}

- (void)didParseFeedDrawData:(Feed *)feed
{
    if (self.feed.drawImage == nil) {
        [self updateDrawViewWithDrawData:feed];
    }
}


- (void)dealloc {
    if ([_drawView respondsToSelector:@selector(cleanAllActions)]){
        [_drawView performSelector:@selector(cleanAllActions)];
    }

    PPRelease(timeLabel);
    PPRelease(descLabel);
    PPRelease(userNameLabel);
    PPRelease(guessStatLabel);
    PPRelease(_drawView);
    PPRelease(_avatarView);
    PPRelease(_feed);
    [super dealloc];
}
@end

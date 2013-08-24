//
//  CommonCommentController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-3.
//
//

#import "CommonCommentController.h"
#import "ShareImageManager.h"
#import "CommonMessageCenter.h"
#import "Opus.pb.h"

@interface CommonCommentController ()
{
    BOOL canSend;
}
@property (retain, nonatomic) PBOpus *opus;
@property (retain, nonatomic) CommentFeed *commentFeed;

@end

@implementation CommonCommentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        canSend = YES;
    }
    return self;
}

- (id)initWithOpus:(PBOpus *)opus
{
    self = [super init];
    if (self) {
        self.opus = opus;
    }
    return self;
}

- (id)initWithOpus:(PBOpus *)opus feed:(CommentFeed *)feed
{
    self = [super init];
    if (self) {
        self.opus = opus;
        self.commentFeed = feed;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    ShareImageManager *manager = [ShareImageManager defaultManager];
    [self.inputBGView setImage:[manager inputImage]];
    if (self.commentFeed) {
        [self.titleLabel setText:NSLS(@"kReplyComment")];
    }else{
        [self.titleLabel setText:NSLS(@"kComment")];
    }
    [self.contentView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setInputBGView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    PPRelease(_contentView);
    PPRelease(_titleLabel);
    PPRelease(_inputBGView);
    PPRelease(_commentFeed);
    PPRelease(_opus);
    [super dealloc];
}

- (IBAction)clickBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#define ACTION_SUMMARY_MAX_LENGTH 60

- (void)sendComment
{
    if (!canSend) {
        return;
    }
    canSend = NO;
    NSString *msg = _contentView.text;
    if ([msg length] != 0) {
        [self showActivityWithText:NSLS(@"kSending")];
        FeedService *_feedService = [FeedService defaultService];
        
        NSString *opusId = _opus.opusId;
        NSString *author = _opus.author.userId;
        NSString *comment = msg;
        //new attribute
        
        NSInteger commentType = 0;
        NSString *commentId = nil;
        NSString *commentSummary = nil;
        NSString *commentUserId = nil;
        NSString *commentNickName = nil;
        
        if (self.commentFeed) {
            commentType = _commentFeed.feedType;
            commentId = _commentFeed.feedId;
            if (IS_OPUS_COMMENT_ACTION(_commentFeed.feedType)) {
                commentSummary = _commentFeed.comment;
            }
            commentUserId = _commentFeed.feedUser.userId;
            commentNickName = _commentFeed.feedUser.nickName;
            
        }else{
            commentType = _opus.type;
            commentId = opusId;
            commentSummary = _opus.name;
            commentUserId = author;
            commentNickName = _opus.author.nickName;
        }
        if ([commentSummary length] > ACTION_SUMMARY_MAX_LENGTH) {
            PPDebug(@"<sendComment> summary length = %d", [commentSummary length]);
            commentSummary = [commentSummary substringToIndex:ACTION_SUMMARY_MAX_LENGTH];
        }
        [_feedService commentOpus:opusId
                           author:author
                          comment:comment
                      commentType:commentType
                        commentId:commentId
                   commentSummary:commentSummary
                    commentUserId:commentUserId
                  commentNickName:commentNickName
                         delegate:self];
    }
    
}

#pragma mark feed service delegate
- (void)didCommentOpus:(NSString *)opusId
         commentFeedId:(NSString *)commentFeedId
               comment:(NSString *)comment
            resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    canSend = YES;
    if (resultCode == 0) {
        [self.contentView setText:nil];
//        [self.feed incTimesForType:FeedTimesTypeComment];
        [self dismissModalViewControllerAnimated:YES];
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCommentFail")
                                                       delayTime:1
                                                         isHappy:NO];
        PPDebug(@"comment fail: opusId = %@, comment = %@", opusId, comment);
    }
}

#pragma mark - text view delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [self sendComment];
        return NO;
    }
    return YES;
} 

@end


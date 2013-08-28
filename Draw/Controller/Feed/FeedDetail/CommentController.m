//
//  CommentController.m
//  Draw
//
//  Created by  on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentController.h"
#import "ShareImageManager.h"
#import "CommonMessageCenter.h"
#import "WordFilterService.h"
#import "CommonDialog.h"

@interface CommentController ()
{
    BOOL canSend;
}

@property (nonatomic, assign) BOOL forContestReport;

@end

@implementation CommentController
@synthesize contentView;
@synthesize inputBGView;
@synthesize titleLabel;
@synthesize feed = _feed;
@synthesize commentFeed = _commentFeed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        canSend = YES;
    }
    return self;
}

- (id)initWithFeed:(DrawFeed *)feed
{
    return [self initWithFeed:feed forContestReport:NO];
}

- (id)initWithFeed:(DrawFeed *)feed forContestReport:(BOOL)forContestReport
{
    self = [super init];
    if (self) {
        self.feed = feed;
        self.forContestReport = forContestReport;
    }
    return self;
}
- (id)initWithFeed:(DrawFeed *)feed commentFeed:(CommentFeed *)commentFeed
{
    self = [super init];
    if (self) {
        self.feed = feed;
        self.commentFeed = commentFeed;
    }
    return self;    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    SET_VIEW_BG(self.view);
    ShareImageManager *manager = [ShareImageManager defaultManager];
    [self.inputBGView setImage:[manager inputImage]];
    if (self.commentFeed) {
        [self.titleLabel setText:NSLS(@"kReplyComment")];        
    }else{
        [self.titleLabel setText:NSLS(@"kComment")];
    }
    [self.contentView becomeFirstResponder];
    
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    if (self.commentFeed) {
        [titleView setTitle:NSLS(@"kReplyComment")];
    }else{
        [titleView setTitle:NSLS(@"kComment")];
    }
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBack:)];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setInputBGView:nil];
    [self setTitleLabel:nil];
    [self setFeed:nil];
    [self setCommentFeed:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    PPRelease(contentView);
    PPRelease(titleLabel);
    PPRelease(inputBGView);
    PPRelease(_commentFeed);
    PPRelease(_feed);
    [super dealloc];
}
- (IBAction)clickBack:(id)sender {
    
    if ([self.contentView.text length] > 0) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kHint") message:NSLS(@"kGiveUpComment") style:CommonDialogStyleDoubleButton];
        [dialog showInView:self.view];
        [dialog setClickOkBlock:^(id infoView){
            [self dismissModalViewControllerAnimated:YES];
        }];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

#define ACTION_SUMMARY_MAX_LENGTH 60

- (void)sendComment
{
    NSString *msg = contentView.text;
    if ([[WordFilterService defaultService] checkForbiddenWord:msg]){
        return;
    }

    if (!canSend) {
        return;
    }
    canSend = NO;
    
    if ([msg length] != 0) {
        [self showActivityWithText:NSLS(@"kSending")];
        FeedService *_feedService = [FeedService defaultService];
        
        NSString *opusId = _feed.feedId;
        NSString *author = _feed.feedUser.userId;
        NSString *comment = msg;        
        //new attribute

        NSInteger commentType = 0;
        NSString *commentId = nil;
        NSString *commentSummary = nil;
        NSString *commentUserId = nil;
        NSString *commentNickName = nil;
        
        if (self.commentFeed) {
            // 回复评论/鲜花/点评等的操作
            commentType = _commentFeed.feedType;
            commentId = _commentFeed.feedId;
            if (IS_OPUS_COMMENT_ACTION(_commentFeed.feedType)) {
                commentSummary = _commentFeed.comment;
            }
            commentUserId = _commentFeed.feedUser.userId;
            commentNickName = _commentFeed.feedUser.nickName;
            
        }else{
            // 评论 或者 点评 作品本身
            commentType = self.feed.feedType;
            commentId = opusId;
            commentSummary = self.feed.wordText;
            commentUserId = author;
            commentNickName = _feed.feedUser.nickName;
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
                        contestId:self.feed.contestId
                 forContestReport:_forContestReport
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
        [self.feed incTimesForType:FeedTimesTypeComment];
        [self dismissModalViewControllerAnimated:YES];
        
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCommentFail") 
                                                       delayTime:1 
                                                         isHappy:NO];
        PPDebug(@"comment fail: opusId = %@, comment = %@", opusId, comment);        
    }
}

//#pragma mark - key board rect
//
//#define BG_CONTENT_SPACE ([DeviceDetection isIPAD] ?  5.0 : 3.0)
//#define KEYBOARD_BG_SPACE ([DeviceDetection isIPAD] ? 50.0 : 30.0)
//
//#define KEYBOARD_BG_SPACE ([DeviceDetection isIPAD] ? 50.0 : 30.0)
//#define INPUT_BG_FRAME [DeviceDetection isIPAD] ? CGRectMake(10, 70, 300, 140) : CGRectMake(20, 155, 728, 349)
//#define INPUT_CONTENT_FRAME [DeviceDetection isIPAD] ? CGRectMake(13, 73, 294, 120) : CGRectMake(25, 160, 718, 342)
//
//- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
//{
//
//    //update the text view
//    CGFloat end = CGRectGetMinY(keyboardRect);
//    CGRect frame = INPUT_BG_FRAME;
//    CGFloat bgStartY = CGRectGetMinY(frame);
//    CGFloat bgHeight = end - bgStartY - KEYBOARD_BG_SPACE;
//    CGFloat contentHeiht = bgHeight - BG_CONTENT_SPACE;
//
//    PPDebug(@"bgHeight = %f, contentHeight = %f", bgHeight,contentHeiht);
//    
//    self.inputBGView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), bgHeight);
//
//    frame = INPUT_CONTENT_FRAME;
//    self.contentView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), contentHeiht);
//
//    PPDebug(@"BG VIEW FRAME = %@, CONTENT VIEW FRAME = %@", NSStringFromCGRect(self.inputBGView.frame),NSStringFromCGRect(self.contentView.frame));
//    
////    PPDebug(@"bgHeight = %f, contentHeight = %f", bgHeight,contentHeiht);
//}
//


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

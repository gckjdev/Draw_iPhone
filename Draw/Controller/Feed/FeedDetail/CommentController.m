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
    }
    return self;
}

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
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
    [self setFeed:nil];
    [self setCommentFeed:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self dismissModalViewControllerAnimated:YES];
}

#define ACTION_SUMMARY_MAX_LENGTH 20

- (void)sendComment
{
    NSString *msg = contentView.text;
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
            commentType = _commentFeed.feedType;
            commentId = _commentFeed.feedId;
            if (_commentFeed.feedType == FeedTypeComment) {
                commentSummary = _commentFeed.comment;
            }       
            commentUserId = _commentFeed.feedUser.userId;
            commentNickName = _commentFeed.feedUser.nickName;
            
        }else{
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
    if (resultCode == 0) {
        [self.contentView setText:nil];
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCommentFail") 
                                                       delayTime:1 
                                                         isHappy:NO];
        PPDebug(@"comment fail: opusId = %@, comment = %@", opusId, comment);        
    }
}

#pragma mark - key board rect

#define BG_CONTENT_SPACE ([DeviceDetection isIPAD] ?  5.0 : 3.0)
#define KEYBOARD_BG_SPACE ([DeviceDetection isIPAD] ? 50.0 : 30.0)

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    //update the text view
    CGFloat end = CGRectGetMinY(keyboardRect);
    CGRect frame = self.inputBGView.frame;
    CGFloat bgStartY = CGRectGetMinY(frame);
    CGFloat bgHeight = end - bgStartY - KEYBOARD_BG_SPACE;
    CGFloat contentHeiht = bgHeight - BG_CONTENT_SPACE;

    self.inputBGView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), bgHeight);

    frame = self.contentView.frame;
    self.contentView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), contentHeiht);

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

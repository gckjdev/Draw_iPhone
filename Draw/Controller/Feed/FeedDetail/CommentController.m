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
    [self.titleLabel setText:NSLS(@"kComment")];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [contentView release];
    [inputBGView release];
    [titleLabel release];
    [super dealloc];
}
- (IBAction)clickBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)sendComment
{
    NSString *msg = contentView.text;
    if ([msg length] != 0) {
        [self showActivityWithText:NSLS(@"kSending")];
        FeedService *_feedService = [FeedService defaultService];
        [_feedService commentOpus:_feed.feedId author:_feed.feedUser.userId comment:msg delegate:self];        
    }

}

#pragma mark feed service delegate
- (void)didCommentOpus:(NSString *)opusId commentFeedId:(NSString *)commentFeedId comment:(NSString *)comment resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self.contentView setText:nil];
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kCommentFail") delayTime:1 isHappy:NO];
        PPDebug(@"comment fail: opusId = %@, comment = %@", opusId, comment);        
    }
}

#pragma mark - key board rect

#define BG_CONTENT_SPACE 3
#define KEYBOARD_BG_SPACE 20

- (void)keyboardWillShowWithRect:(CGRect)keyboardRect
{
    //update the text view
    CGFloat end = CGRectGetMinY(keyboardRect);
    CGFloat bgHeight = end - CGRectGetMinY(self.inputBGView.frame) - KEYBOARD_BG_SPACE;
    CGFloat contentHeiht = bgHeight - BG_CONTENT_SPACE;
    
    CGRect frame = self.inputBGView.frame;
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

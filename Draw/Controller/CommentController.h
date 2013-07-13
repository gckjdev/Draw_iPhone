//
//  CommentController.h
//  Draw
//
//  Created by  on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "FeedService.h"

@class DrawFeed;
@class CommentFeed;
@interface CommentController : PPViewController<UITextViewDelegate, FeedServiceDelegate>
{
    DrawFeed *_feed;
    CommentFeed *_commentFeed;
}
@property (retain, nonatomic) IBOutlet UITextView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBGView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) CommentFeed *commentFeed;

- (id)initWithFeed:(DrawFeed *)feed;
- (IBAction)clickBack:(id)sender;
- (id)initWithFeed:(DrawFeed *)feed commentFeed:(CommentFeed *)commentFeed;
@end

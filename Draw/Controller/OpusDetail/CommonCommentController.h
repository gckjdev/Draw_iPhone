//
//  CommonCommentController.h
//  Draw
//
//  Created by 王 小涛 on 13-7-3.
//
//

#import "PPViewController.h"
#import "FeedService.h"

@class PBOpus;
@class CommentFeed;

@interface CommonCommentController : PPViewController<UITextViewDelegate, FeedServiceDelegate>

@property (retain, nonatomic) IBOutlet UITextView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBGView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;


- (id)initWithOpus:(PBOpus *)opus;
- (id)initWithOpus:(PBOpus *)opus feed:(CommentFeed *)feed;

@end

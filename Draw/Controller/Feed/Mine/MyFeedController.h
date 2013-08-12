//
//  MyFeedController.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "CommonTabController.h"
#import "FeedService.h"
#import "RankView.h"
#import "FeedCell.h"
#import "CommonDialog.h"
#import "CommentFeed.h"

@class Feed;
@interface MyFeedController : CommonTabController<FeedServiceDelegate,RankViewDelegate,
FeedCellDelegate, UIActionSheetDelegate, CommonDialogDelegate>
{
    RankView *_selectRanView;
    Feed *_seletedFeed;
    CommentFeed *_selectedCommentFeed;
    
    NSInteger indexOfCommentOpus;
    NSInteger indexOfCommentDelete;
    NSInteger indexOfCommentReply;
    
}


+ (void)enterControllerWithIndex:(NSInteger)index
                  fromController:(UIViewController *)controller 
                        animated:(BOOL)animated;

@end

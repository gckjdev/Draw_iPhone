//
//  CommentHeaderView.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentHeaderView.h"

@implementation CommentHeaderView
@synthesize delegate = _delegate;
+ (id)createCommentHeaderView:(id)delegate
{
    NSString* identifier = @"CommentHeaderView";
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    CommentHeaderView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}

- (void)setViewInfo:(DrawFeed *)feed
{
    
    //    猜画:3 | 评论:2 | 鲜花:2 | 番茄:1 
    
    //    if (feed.guessTimes == 0) {
    //        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    //    }else{
    //    猜画:3 | 猜对:2 | 评论:2 | 鲜花:2 | 番茄:1 | 保存:1
    NSInteger guessTimes = feed.guessTimes;

    NSInteger correctTimes = feed.correctTimes;
//    NSInteger commentTimes = feed.correctTimes;
    NSInteger flowerTimes = feed.flowerTimes;
    NSInteger tomatoTimes = feed.tomatoTimes;
    //    NSInteger saveTimes = feed.saveTimes;
    
    
    NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessDetailStat"),guessTimes, correctTimes,flowerTimes,tomatoTimes];
    UILabel *label = (UILabel *)[self viewWithTag:100];
    [label setText:desc]; 
}
+ (CGFloat)getHeight
{
    return 40;
}

@end

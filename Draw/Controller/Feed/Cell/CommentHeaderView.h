//
//  CommentHeaderView.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawFeed.h"

@protocol CommentHeaderViewDelegate <NSObject>

@optional
- (void)didSelectCommentType:(int)type;

@end



@interface CommentHeaderView : UIView
{
    NSInteger _currentType;
    DrawFeed *_feed;
}
@property(nonatomic, assign)id delegate;
@property(nonatomic, retain)DrawFeed *feed;
- (IBAction)clickButton:(id)sender;
- (void)setSeletType:(CommentType)type;
- (CommentType)seletedType;
+ (id)createCommentHeaderView:(id)delegate;
- (void)setViewInfo:(DrawFeed *)feed;
+ (CGFloat)getHeight;
- (void)updateTimes:(DrawFeed *)feed;

@end


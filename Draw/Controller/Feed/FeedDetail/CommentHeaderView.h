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

typedef enum{
    CommentTypeNO = -100,
    CommentTypeGuess = 2,
    CommentTypeComment = 3,
    CommentTypeFlower = 6,
    CommentTypeTomato = 7,
}CommentType;


@interface CommentHeaderView : UIView
{
    NSInteger _currentType;
}
@property(nonatomic, assign)id delegate;
- (IBAction)clickButton:(id)sender;
+ (id)createCommentHeaderView:(id)delegate;
- (void)setViewInfo:(DrawFeed *)feed;
+ (CGFloat)getHeight;
- (void)updateTimes:(DrawFeed *)feed;
@end


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
}
@property(nonatomic, assign)id delegate;
- (IBAction)clickButton:(id)sender;
+ (id)createCommentHeaderView:(id)delegate;
- (void)setViewInfo:(DrawFeed *)feed;
+ (CGFloat)getHeight;
@end


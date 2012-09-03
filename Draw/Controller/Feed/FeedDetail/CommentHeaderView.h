//
//  CommentHeaderView.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawFeed.h"

@interface CommentHeaderView : UIView
{
    
}
@property(nonatomic, assign)id delegate;
+ (id)createCommentHeaderView:(id)delegate;
- (void)setViewInfo:(DrawFeed *)feed;
+ (CGFloat)getHeight;
@end


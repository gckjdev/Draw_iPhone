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
    
}
+ (CGFloat)getHeight
{
    return 40;
}

@end

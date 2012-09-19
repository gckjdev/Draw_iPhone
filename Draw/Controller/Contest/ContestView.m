//
//  ContestView.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestView.h"

@implementation ContestView
@synthesize delegate = _delegate;
@synthesize contest = _contest;

+ (id)createCommentHeaderView:(id)delegate
{
    NSString* identifier = @"ContestView";
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    ContestView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}

- (void)dealloc
{
    PPRelease(_contest);
    [super dealloc];
}

- (void)setViewInfo:(Contest *)contest
{
    self.contest = contest;
    //update the view info.
}

@end

//
//  ContestView.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contest;

@protocol ContestViewDelegate <NSObject>

@optional
- (void)didClickOpusButton:(Contest *)contest;
- (void)didClickJoinButton:(Contest *)contest;
- (void)didClickDetailButton:(Contest *)contest;
@end

@interface ContestView : UIView
{
    id<ContestViewDelegate> _delegate;
    Contest *_contest;
}
@property(nonatomic, assign)id<ContestViewDelegate>delegate;
@property(nonatomic, retain)Contest *contest;

- (void)setViewInfo:(Contest *)contest;
@end

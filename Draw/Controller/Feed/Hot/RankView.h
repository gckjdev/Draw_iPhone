//
//  RankView.h
//  Draw
//
//  Created by  on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class RankView;

@protocol RankViewDelegate <NSObject>
@optional
- (void)didClickRankView:(RankView *)rankView;

@end

typedef enum{
     RankViewTypeFirst = 1,
     RankViewTypeSecond = 2,
     RankViewTypeNormal = 3,
     RankViewTypeDrawOnCell = 4,
}RankViewType;

@class DrawFeed;
//@class HJManagedImageV;
@class ShowDrawView;
@class TopPlayer;
@interface RankView : UIView
{
    DrawFeed *_feed;
}

@property(nonatomic, assign)id delegate;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *author;
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;
@property (retain, nonatomic) DrawFeed *feed;


+ (id)createRankView:(id)delegate type:(RankViewType)type;
+ (CGFloat)heightForRankViewType:(RankViewType)type;
+ (CGFloat)widthForRankViewType:(RankViewType)type;

- (void)setViewInfo:(DrawFeed *)feed;

- (void)updateViewInfoForMyOpus;
- (void)updateViewInfoForUserOpus;
- (void)updateViewInfoForContestOpus;
- (IBAction)clickMaskView:(id)sender;
- (void)setRankViewSelected:(BOOL)selected;


@property (retain, nonatomic) IBOutlet UIImageView *drawFlag;
@property (retain, nonatomic) IBOutlet UIImageView *cupFlag;
@property (retain, nonatomic) IBOutlet UIButton *maskButton;
@end

//
//  TopPlayerView.h
//  Draw
//
//  Created by  on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPlayer.h"

@class HJManagedImageV;
@class TopPlayerView;

@protocol TopPlayerViewDelegate <NSObject>
@optional
- (void)didClickTopPlayerView:(TopPlayerView *)topPlayerView;

@end


@interface TopPlayerView : UIView
{
    TopPlayer *_topPlayer;
}


@property(nonatomic, assign)id delegate;
@property(nonatomic, retain)TopPlayer *topPlayer;

@property (retain, nonatomic) IBOutlet HJManagedImageV *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *levelInfo;
@property (retain, nonatomic) IBOutlet UIButton *maskButton;


+ (id)createTopPlayerView:(id)delegate;
- (void)setViewInfo:(TopPlayer *)player;
- (void)setRankFlag:(NSInteger)rank;
- (void)setViewSeleted:(BOOL)selected;
- (IBAction)clickPlayerView:(id)sender;

@end

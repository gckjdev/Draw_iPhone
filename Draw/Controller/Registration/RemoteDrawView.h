//
//  RemoteDrawView.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "ShowDrawView.h"

@protocol RemoteDrawViewDelegate <NSObject>
@optional
- (void)didClickPlaybackButton:(int)index;

@end


@class PBDraw;

@interface RemoteDrawView : UIView
@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet ShowDrawView *showDrawView;
@property (retain, nonatomic) IBOutlet UIButton *playbackButton;
@property (assign, nonatomic) id<RemoteDrawViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *wordLabel;

+ (RemoteDrawView*)creatRemoteDrawView;

- (void)setViewByRemoteDrawData:(PBDraw *)remoteDrawData index:(int)aIndex;
- (IBAction)clickPlaybackButton:(id)sender;

@end

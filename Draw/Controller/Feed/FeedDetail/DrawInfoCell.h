//
//  DrawInfoCell.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPTableViewCell.h"
#import "DrawFeed.h"
#import "FeedService.h"
#import "ShowDrawView.h"

@class HJManagedImageV;
@protocol DrawInfoCellDelegate <NSObject>

@optional
- (void)didUpdateShowView;

@end

@interface DrawInfoCell : PPTableViewCell<FeedServiceDelegate, ShowDrawViewDelegate>
{
    id<DrawInfoCellDelegate> _delegate;
    DrawFeed *_feed;
    ShowDrawView *_showView;
    NSInteger _getTimes;
}

@property (assign, nonatomic) id<DrawInfoCellDelegate> delegate;
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) IBOutlet HJManagedImageV *drawImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
- (void)setCellInfo:(DrawFeed *)feed;
+ (NSString*)getCellIdentifier;
@end


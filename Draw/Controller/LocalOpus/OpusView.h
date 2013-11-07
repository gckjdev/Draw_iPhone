//
//  MyPaintButton.h
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Opus;
@class DrawFeed;

@protocol OpusViewDelegate <NSObject>

- (void)didClickOpus:(Opus*)opus;
- (void)didClickFeed:(DrawFeed*)feed;

@end

@interface OpusView : UIView
{
}
@property (retain, nonatomic) IBOutlet UIImageView *titleBackground;
@property (retain, nonatomic) IBOutlet UILabel *opusTitle;
@property (nonatomic, retain) IBOutlet UIImageView* background;
//@property (retain, nonatomic) IBOutlet UIImageView *myOpusTag;
@property (retain, nonatomic) IBOutlet UIImageView *opusImage;
@property (assign, nonatomic) id<OpusViewDelegate>delegate;
@property (assign, nonatomic) BOOL isDraft;

+ (id)createOpusView:(id<OpusViewDelegate>)delegate;

// for local draft.
- (void)updateWithOpus:(Opus*)opus;

// for my opus and favourite.
- (void)updateWithFeed:(DrawFeed *)feed;


@end

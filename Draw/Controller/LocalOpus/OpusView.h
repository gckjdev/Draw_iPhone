//
//  MyPaintButton.h
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Opus;

@protocol OpusViewDelegate <NSObject>

- (void)didClickOpus:(Opus*)opus;

@end

@interface OpusView : UIView
{
}
@property (retain, nonatomic) IBOutlet UIImageView *titleBackground;
@property (retain, nonatomic) IBOutlet UILabel *opusTitle;
@property (nonatomic, retain) IBOutlet UIImageView* background;
@property (retain, nonatomic) IBOutlet UIImageView *myOpusTag;
@property (retain, nonatomic) IBOutlet UIImageView *opusImage;
@property (retain, nonatomic) Opus* opus;
@property (assign, nonatomic) id<OpusViewDelegate>delegate;


+ (id)createOpusView:(id<OpusViewDelegate>)delegate;
- (void)updateWithOpus:(Opus*)opus;
@end

//
//  WhisperStyleView.h
//  Draw
//
//  Created by 王 小涛 on 13-11-12.
//
//

#import <UIKit/UIKit.h>

@class DrawFeed;

@interface WhisperStyleView : UIView

+ (id)createWithFrame:(CGRect)frame
                 feed:(DrawFeed *)feed;

- (void)setHotRankViewStyle;

@end

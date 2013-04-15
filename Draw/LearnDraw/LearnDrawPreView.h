//
//  LearnDrawPreView.h
//  Draw
//
//  Created by gamy on 13-4-15.
//
//

#import <Foundation/Foundation.h>


@class DrawFeed;

@interface LearnDrawPreView : UIView

@property(nonatomic, retain)UIImage *placeHolderImage;

+ (LearnDrawPreView *)learnDrawPreViewWithDrawFeed:(DrawFeed *)feed
                                  placeHolderImage:(UIImage *)image;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

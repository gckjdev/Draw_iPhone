//
//  DrawBgBox.h
//  Draw
//
//  Created by gamy on 13-3-4.
//
//

#import <UIKit/UIKit.h>


@class PBDrawBg;
@class DrawBgBox;

@protocol DrawBgBoxDelegate <NSObject>


- (void)drawBgBox:(DrawBgBox *)drawBgBox didSelectedDrawBg:(PBDrawBg *)drawBg;

@end

@interface DrawBgBox : UIView

@property(nonatomic, assign) id<DrawBgBoxDelegate> delegate;
- (void)updateViewsWithSelectedBgId:(NSString *)bgId;

+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate;

@end

//
//  CommonSnsInfoView.h
//  Draw
//
//  Created by Orange on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonSnsInfoView : UIView
- (id)initWithFrame:(CGRect)frame 
            hasSina:(BOOL)hasSina 
              hasQQ:(BOOL)hasQQ 
        hasFacebook:(BOOL)hasFacebook;

- (void)setHasSina:(BOOL)hasSina 
             hasQQ:(BOOL)hasQQ 
       hasFacebook:(BOOL)hasFacebook;

@property (retain, nonatomic) UIImageView* sinaImageView;
@property (retain, nonatomic) UIImageView* qqImageView;
@property (retain, nonatomic) UIImageView* facebookImageView;

@end

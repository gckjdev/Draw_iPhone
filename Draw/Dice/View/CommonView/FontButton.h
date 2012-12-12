//
//  FontButton.h
//  Draw
//
//  Created by 小涛 王 on 12-8-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontLabel.h"
//#import "UIGlossyButton.h"

@interface FontButton : UIButton

@property (retain, nonatomic) FontLabel *fontLable;

- (id)initWithFrame:(CGRect)frame 
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize;

@end

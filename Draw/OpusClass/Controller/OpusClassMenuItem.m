//
//  OpusClassMenuItem.m
//  Draw
//
//  Created by qqn_pipi on 14-6-17.
//
//

#import "OpusClassMenuItem.h"

#define MENU_TEXT_FONT_SIZE     (ISIPAD ? 24 : 11)
#define MENU_BACKGROUND         COLOR_ORANGE
#define MENU_TEXT_COLOR         COLOR_WHITE

@implementation THGridMenuItem (OpusClassMenuItem)

-(void)addTitle:(NSString *)title {
    self.backgroundColor = [UIColor clearColor];
    CGRect parentFrame = self.frame;
    CGFloat margin = (ISIPAD ? 10.0 : 4);
    CGRect titleFrame = CGRectMake(margin, 0.0, parentFrame.size.width - (margin *2), parentFrame.size.height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.text = title;
    titleLabel.backgroundColor = MENU_BACKGROUND;
    SET_VIEW_ROUND_CORNER_RADIUS(titleLabel, (ISIPAD ? 8 : 4));
    titleLabel.textColor = MENU_TEXT_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:MENU_TEXT_FONT_SIZE];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.contentMode = UIViewContentModeScaleAspectFit;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel release];
}

@end

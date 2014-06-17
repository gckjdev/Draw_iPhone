//
//  OpusClassMenuItem.m
//  Draw
//
//  Created by qqn_pipi on 14-6-17.
//
//

#import "OpusClassMenuItem.h"

@implementation THGridMenuItem (OpusClassMenuItem)

-(void)addTitle:(NSString *)title {
    self.backgroundColor = [UIColor clearColor];
    CGRect parentFrame = self.frame;
    CGFloat margin = 10.0;
    CGRect titleFrame = CGRectMake(margin, 0.0, parentFrame.size.width - (margin *2), parentFrame.size.height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.text = title;
    titleLabel.backgroundColor = COLOR_ORANGE;
    SET_VIEW_ROUND_CORNER_RADIUS(titleLabel, BUTTON_CORNER_RADIUS);
    titleLabel.textColor = COLOR_WHITE;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.contentMode = UIViewContentModeScaleAspectFit;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
}

@end

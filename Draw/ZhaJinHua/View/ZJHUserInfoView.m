//
//  ZJHUserInfoView.m
//  Draw
//
//  Created by Kira on 12-12-4.
//
//

#import "ZJHUserInfoView.h"
#import "ZJHImageManager.h"

@implementation ZJHUserInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    [self.backgroundImageView setImage:[ZJHImageManager defaultManager].ZJHUserInfoBackgroundImage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

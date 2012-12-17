//
//  BulletinView.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinView.h"

@implementation BulletinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)showBulletinInController:(PPViewController*)controller
{
    BulletinView* view = (BulletinView*)[BulletinView createInfoViewByXibName:@"BulletinView"];
    [view showInView:controller.view];
}

- (IBAction)clickClose:(id)sender
{
    [self disappear];
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

//
//  RoomTitleView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-16.
//
//

#import "RoomTitleView.h"
#import "ZJHImageManager.h"

@implementation RoomTitleView

#pragma mark - pravite methods

+ (id)createRoomTitleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RoomTitleView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

+ (RoomTitleView *)roomTitleViewWithTitle:(NSString *)title
{
    RoomTitleView *view = (RoomTitleView *)[self createRoomTitleView];
    view.bgImageView.image = [[ZJHImageManager defaultManager] roomTitleBgImage];
    view.titleLabel.text = title;
    
    
    view.titleLabel.shadowColor = [UIColor colorWithRed:50.0/255.0 green:29.0/255.0 blue:9.0/255.0 alpha:0.8];
    view.titleLabel.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    view.titleLabel.shadowBlur = 1.0f;
    view.titleLabel.numberOfLines = 1;
//    view.titleLabel.innerShadowColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
//    view.titleLabel.innerShadowOffset = CGSizeMake(1.0f, 1.0f);
    return view;
}

+ (void)showRoomTitle:(NSString *)title
               inView:(UIView *)view
{
    RoomTitleView *titleView = [self roomTitleViewWithTitle:title];
    [titleView setCenter:CGPointMake(view.bounds.size.width/2, titleView.bounds.size.height/2)];
    [view addSubview:titleView];
}


- (void)dealloc {
    [_titleLabel release];
    [_bgImageView release];
    [super dealloc];
}
@end

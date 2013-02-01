//
//  WidthBox.m
//  Draw
//
//  Created by gamy on 13-2-1.
//
//

#import "WidthBox.h"
#import "WidthView.h"

@interface WidthBox()
{
    NSMutableArray *widthViewList;
}
@end

@implementation WidthBox

#define VIEW_WIDTH ([WidthView width] + 2)


#define WIDTH_END (-1)
static NSInteger widthList[] = {1, 5, 10, 20, 30, WIDTH_END};

+ (NSInteger)countOfList:(NSInteger *)list
{
    NSInteger *value = list;
    NSInteger count = 0;
    while (value != NULL && *value != WIDTH_END) {
        count ++;
    }
    return count;
}
+ (id)widthBoxWithWidthList:(NSInteger *)list
{
    WidthView *view = [[[WidthView alloc] initWithFrame:CGRectZero] autorelease];
    NSInteger count = [WidthBox countOfList:list];
    CGFloat height = count * [WidthView width];
    CGFloat width = [WidthView width];
    view.frame = CGRectMake(0, 0, width, height);
    
    for (NSInteger *value = list; value != NULL && (*value) != WIDTH_END; value++ ) {
        WidthView *wv = [WidthView viewWithWidth:*value];
        [view addSubview:wv];
    }
//    view.frame.size = CGSizeMake(VIEW_WIDTH, 1);
    return view;
}
+ (id)widthBox
{
    return [WidthBox widthBoxWithWidthList:widthList];
}
- (void)setWidthSelected:(NSInteger)width
{
    
}

@end

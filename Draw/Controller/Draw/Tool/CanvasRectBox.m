//
//  CanvasRectBox.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "CanvasRectBox.h"
#import "UIViewUtils.h"

@interface CanvasRectBox()

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) id<CanvasRectBoxDelegate>delegate;


@end

@implementation CanvasRectBox

- (void)updateView
{
    
}

+ (id)canvasRectBoxWithDelegate:(id<CanvasRectBoxDelegate>)delegate
{
    CanvasRectBox *box = [UIView createViewWithXibIdentifier:@"CanvasRectBox"];
    box.delegate = box;
    [box updateView];
    return box;
}

- (void)setSelectedRect:(CanvasRectStyle)style
{
    
}


- (void)dealloc {
    [_scrollView release];
    [super dealloc];
}
@end

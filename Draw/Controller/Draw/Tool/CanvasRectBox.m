//
//  CanvasRectBox.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "CanvasRectBox.h"
#import "UIViewUtils.h"
#import "CanvasRect.h"
#import <QuartzCore/QuartzCore.h>
#import "UserGameItemManager.h"
#import "ItemType.h"

#pragma mark-- CanvasRectView

typedef enum {
    CanvasRectViewTypeUnbuy = 0,
    CanvasRectViewTypeBought,
    CanvasRectViewTypeSelected,
    
}CanvasRectViewType;

@interface CanvasRectView : UIControl
{
    
}
@property(nonatomic, retain)UILabel *title;
@property(nonatomic, assign)CGRect rect;
@property(nonatomic, assign)CanvasRectViewType type;

- (id)initWithCanvasRect:(CGRect)rect;
+ (CGFloat)width;
- (CGFloat)contentHeight;
@end


@interface CanvasRectBox()
{
    CanvasRectView *_currentRectView;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) id<CanvasRectBoxDelegate>delegate;


@end


@class CanvasRectView;

@implementation CanvasRectBox


#define ROW_NUMBER 3

- (void)clickCanvasRectView:(CanvasRectView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(canvasBox:didSelectedRect:)]) {
//        [self.delegate canvasBox:self didSelectedRect:view.rect canvasStyle:view.tag];
        CanvasRect *canvasRect = [CanvasRect canvasRectWithStyle:view.tag];
        [self.delegate canvasBox:self didSelectedRect:canvasRect];
    }
}

#define ROW_1_OFFSET (ISIPAD ? (-20) : (-10))
#define CONTENT_HEIGHT_OFFSET (ISIPAD ? 6 : 3)

- (void)updateView
{
    CanvasRectStyle *list = [CanvasRect getRectStyleList];
    NSInteger index = 0;
    
    CGFloat space = (CGRectGetWidth(self.bounds) - ROW_NUMBER * [CanvasRectView width]) / (ROW_NUMBER - 1);
    
    CGFloat contentHeight = 0;
    while (list != NULL && *list != CanvasRectEnd) {
        
        CGRect rect = [CanvasRect rectForCanvasRectStype:*list];
        
        CanvasRectView *view = [[[CanvasRectView alloc] initWithCanvasRect:rect] autorelease];
        
        CGPoint origin = CGPointMake((index % ROW_NUMBER) * (space + [CanvasRectView width]), index / ROW_NUMBER * (space + [CanvasRectView width]));
        
        if (index / ROW_NUMBER == 1) {
            origin.y += ROW_1_OFFSET;
        }
        
        CGRect frame = view.frame;
        frame.origin = origin;
        view.frame = frame;
        contentHeight = CGRectGetHeight(frame);
        [self.scrollView addSubview:view];
        view.tag = *list;
        [view addTarget:self action:@selector(clickCanvasRectView:) forControlEvents:UIControlEventTouchUpInside];
        ItemType type = [CanvasRect itemTypeFromCanvasRectStyle:*list];
        
        if ([[UserGameItemManager defaultManager] hasItem:type]) {
            [view setType:CanvasRectViewTypeBought];
        }else{
            [view setType:CanvasRectViewTypeUnbuy];
        }
        
        list ++; index ++;
    }
    contentHeight += CONTENT_HEIGHT_OFFSET;
    self.scrollView.contentSize =  CGSizeMake(CGRectGetWidth(self.frame), contentHeight);
}

+ (id)canvasRectBoxWithDelegate:(id<CanvasRectBoxDelegate>)delegate
{
    CanvasRectBox *box = [UIView createViewWithXibIdentifier:@"CanvasRectBox"];
    box.delegate = delegate;
    [box updateView];
    return box;
}

- (void)setSelectedRect:(CanvasRectStyle)style
{
    [_currentRectView setType:CanvasRectViewTypeBought];
    _currentRectView = (CanvasRectView *)[self.scrollView viewWithTag:style];
    [_currentRectView setType:CanvasRectViewTypeSelected];
}


- (void)dealloc {
    [_scrollView release];
    [super dealloc];
}
@end



#pragma mark-- CanvasRectView

@implementation CanvasRectView

#define WIDTH (ISIPAD ? 120 : 55)
#define BORDER_WIDTH (ISIPAD ? 4 : 2)

#define FONT_SIZE (ISIPAD ? 20 : 10)

#define MAX_SIZE 1136



- (CGFloat)contentHeight
{
    return self.title.bounds.size.height;
}

+ (CGFloat)width
{
    return WIDTH;
}

- (void)dealloc
{
    PPRelease(_title);
    [super dealloc];
}

- (void)setType:(CanvasRectViewType)type
{
    _type = type;
    UIColor *color = nil;
    switch (type) {
        case CanvasRectViewTypeBought:
        {
            color = [UIColor greenColor];
            break;
        }
        case CanvasRectViewTypeSelected:
        {
            color = [UIColor redColor];
            break;
        }
        case CanvasRectViewTypeUnbuy:
        default:
        {
            color = [UIColor grayColor];
            break;
        }
    }
    [self.title setTextColor:color];
    [self.title.layer setBorderColor:color.CGColor];
    
}


- (CGFloat)scale:(NSInteger)value
{
    if (value >= 1136) {
        return 1;
    }
    if (value == 1024) {
        return 0.95;
    }
    if (value == 700) {
        return 0.82;
    }
    if (value <= 300) {
        return 0.7;
    }
    return 0.6;
}

- (CGRect)scaleRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat scale = [self scale:MAX(width, height)];
    if (width > height) {
        width = WIDTH;
        height = WIDTH / CGRectGetWidth(rect) * height;
        rect.origin.y = (CGRectGetHeight(rect) - height) / 2;
    }else{
        height = WIDTH;
        width =  WIDTH / CGRectGetHeight(rect) * width;
        rect.origin.x = (CGRectGetWidth(rect) - width) / 2;
    }
    rect.size = CGSizeMake(width * scale, height * scale);
    return rect;
}


- (void)updateColor
{
    
}


- (id)initWithCanvasRect:(CGRect)rect
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
    if (self) {
        self.rect = rect;
        CGRect frame = [self scaleRect:rect];
        frame.origin.y = WIDTH - CGRectGetHeight(frame);
        frame.origin.x = (WIDTH - CGRectGetWidth(frame)) / 2;
        self.title = [[[UILabel alloc] initWithFrame:frame] autorelease];
        
        UILabel *tt = self.title;
        [tt setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [tt.layer setBorderWidth:BORDER_WIDTH];
        [tt.layer setBorderColor:[UIColor blackColor].CGColor];
        
        NSString *txt = nil;

        //纯粹排版，可以无视。
        if (CGRectGetHeight(rect) > CGRectGetWidth(rect)) {
            [tt setTextAlignment:NSTextAlignmentCenter];
            txt = [NSString stringWithFormat:@"%.0f\nx\n%.0f",rect.size.width, rect.size.height];
        }else{
            if (CGRectGetHeight(rect) == CGRectGetWidth(rect)) {
                txt = [NSString stringWithFormat:@"\t\t\t\t%.0f x\n\t\t\t\t%.0f",rect.size.width, rect.size.height];     
            }else{
                txt = [NSString stringWithFormat:@"\t\t\t\t%.0f\n\t\t\t\tx %.0f",rect.size.width, rect.size.height];
            }

            if (CGRectGetWidth(rect) < 500) {
                txt = [NSString stringWithFormat:@"\t\t\t%.0f x\n\t\t\t%.0f",rect.size.width, rect.size.height];
            }
            
        }
        [tt setText:txt];
        tt.numberOfLines = 0;
        
        [self addSubview:tt];
    }
    return self;
}


@end
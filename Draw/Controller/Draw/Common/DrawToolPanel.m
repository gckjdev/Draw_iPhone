//
//  DrawToolPanel.m
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import "DrawToolPanel.h"
#import "DrawColor.h"


@interface DrawToolPanel ()
{
    
}
- (IBAction)clickUndo:(id)sender;
- (IBAction)clickRedo:(id)sender;

- (IBAction)clickPen:(id)sender;
- (IBAction)clickEraser:(id)sender;
- (IBAction)clickAddColor:(id)sender;
- (IBAction)clickColorPicker:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *widthSlider;
@property (retain, nonatomic) IBOutlet UIView *alphaSlider;
@property (retain, nonatomic) IBOutlet UILabel *penWidth;
@property (retain, nonatomic) IBOutlet UILabel *colorAlpha;

@end

@implementation DrawToolPanel

#define MAX_COLOR_NUMBER 8
#define VALUE(x) (ISIPAD ? x*2 : x)

#define SPACE_COLOR_LEFT VALUE(8)
#define SPACE_COLOR_COLOR VALUE(2)
#define SPACE_COLOR_UP VALUE(10)

- (void)updateView
{
    //update color
    NSArray *list = [DrawColor getRecentColorList];
    NSInteger i = 0;
    for (DrawColor *color in list) {
        ColorPoint *point = [ColorPoint pointWithColor:color];
        [self addSubview:point];
        CGRect frame = point.frame;
        CGFloat x = SPACE_COLOR_LEFT + i * (CGRectGetWidth(point.frame) + SPACE_COLOR_COLOR);
        
        frame.origin = CGPointMake(x, SPACE_COLOR_UP);
        point.frame = frame;
        point.delegate = self;
        if (++i >= MAX_COLOR_NUMBER) {
            break;
        }
    }
    
    
    //update width and alpha
    
}

+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"DrawToolPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    DrawToolPanel  *view = (DrawToolPanel *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
    
}

- (IBAction)clickUndo:(id)sender {
}

- (IBAction)clickRedo:(id)sender {
}

- (IBAction)clickPen:(id)sender {
}

- (IBAction)clickEraser:(id)sender {
}

- (IBAction)clickAddColor:(id)sender {
}

- (IBAction)clickColorPicker:(id)sender {
}



#pragma mark - Color Point Delegate
- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    for (ColorPoint *point in [self subviews]) {
        if ([point isKindOfClass:[ColorPoint class]] && colorPoint != point) {
            [point setSelected:NO];
        }
    }
}

- (void)dealloc {
    [_widthSlider release];
    [_alphaSlider release];
    [_penWidth release];
    [_colorAlpha release];
    [super dealloc];
}
@end

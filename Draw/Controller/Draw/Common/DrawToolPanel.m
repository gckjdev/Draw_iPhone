//
//  DrawToolPanel.m
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import "DrawToolPanel.h"

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
- (void)dealloc {
    [_widthSlider release];
    [_alphaSlider release];
    [_penWidth release];
    [_colorAlpha release];
    [super dealloc];
}
@end

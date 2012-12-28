//
//  ColorPickingBox.m
//  Draw
//
//  Created by gamy on 12-12-27.
//
//

#import "Palette.h"
#import "DrawColor.h"

@interface Palette ()
{
    
}

@property(nonatomic, retain) IBOutlet UIView *colorChip;
@property(nonatomic, retain) IBOutlet ILSaturationBrightnessPickerView *colorPicker;
@property(nonatomic, retain) IBOutlet ILHuePickerView *huePicker;

@end

@implementation Palette

- (void)dealloc
{
    PPRelease(_colorChip);
    PPRelease(_colorPicker);
    PPRelease(_huePicker);
    [super dealloc];
}

- (void)updateView
{
    [self.colorPicker setDelegate:self];
    [self.huePicker setDelegate:_colorPicker];
}

- (void)setCurrentColor:(DrawColor *)currentColor
{
    if (_currentColor != currentColor) {
        PPRelease(_currentColor);
        _currentColor = [currentColor retain];
        UIColor *c = [_currentColor color];
        _colorChip.backgroundColor = c;
        _colorPicker.color = c;
        _huePicker.color = c;
    }
}

+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"Palette";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    Palette  *view = (Palette *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view setCurrentColor:[DrawColor greenColor]];
    [view updateView];
    return view;
    
}

- (void)updateCurrentColorWithColor:(UIColor *)newColor
{
    CGFloat R, G, B;
    CGColorRef color = [newColor CGColor];
    int numComponents = CGColorGetNumberOfComponents(color);
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        R = components[0];
        G = components[1];
        B = components[2];
        self.currentColor = [DrawColor colorWithRed:R green:G blue:B alpha:1];
    }
}

-(void)colorPicked:(UIColor *)newColor forPicker:(ILSaturationBrightnessPickerView *)picker
{
    
    _colorChip.backgroundColor = newColor;
    [self updateCurrentColorWithColor:newColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(palette:didPickColor:)]) {
        [self.delegate palette:self didPickColor:self.currentColor];
    }
}

@end

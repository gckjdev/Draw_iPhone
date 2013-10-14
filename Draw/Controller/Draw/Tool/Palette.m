//==============================================================================
//
//  MainViewController.m
//  InfColorPicker
//
//  Created by Troy Gaul on 7 Aug 2010.
//
//  Copyright (c) 2011 InfinitApps LLC - http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import <QuartzCore/QuartzCore.h>
#import "InfColorBarPicker.h"
#import "InfColorSquarePicker.h"
#import "InfHSBSupport.h"
#import "Palette.h"
#import "DrawColor.h"
#import "ColorPoint.h"
//------------------------------------------------------------------------------

static void HSVFromUIColor( UIColor* color, float* h, float* s, float* v )
{
	CGColorRef colorRef = [ color CGColor ];
	
	const CGFloat* components = CGColorGetComponents( colorRef );
	size_t numComponents = CGColorGetNumberOfComponents( colorRef );
	
	CGFloat r, g, b;
	if( numComponents < 3 ) {
		r = g = b = components[ 0 ];
	}
	else {
		r = components[ 0 ];
		g = components[ 1 ];
		b = components[ 2 ];
	}
	
	RGBToHSV( r, g, b, h, s, v, YES );
}

//==============================================================================

@interface Palette()

- (void) updateResultColor;


@end

//==============================================================================

@implementation Palette

//------------------------------------------------------------------------------

@synthesize delegate, resultColor, sourceColor;
@synthesize barView, squareView;
@synthesize barPicker, squarePicker;
@synthesize resultColorView;

//------------------------------------------------------------------------------
#pragma mark	Class methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark	Memory management
//------------------------------------------------------------------------------

- (void) dealloc
{
	[ barView release ];
	[ squareView release ];
	[ barPicker release ];
	[ squarePicker release ];
	[ resultColorView release ];
	
	[ sourceColor release ];
	[ resultColor release ];
	
	[ super dealloc ];
}


- (void)updateView
{
    barPicker.value = hue;
	squareView.hue = hue;
	squarePicker.hue = hue;
	squarePicker.value = CGPointMake( saturation, brightness );
        
    self.backgroundColor = [UIColor whiteColor];
}

+ (id) paletteWithDelegate:(id)delegate
{
    Palette *palette = [self createViewWithXibIdentifier:@"Palette"];
    palette.delegate = delegate;
    [palette updateView];
    return palette;
}
//------------------------------------------------------------------------------


#pragma mark	IB actions
//------------------------------------------------------------------------------

- (IBAction) takeBarValue: (InfColorBarPicker*) sender
{
	hue = sender.value;
	
	squareView.hue = hue;
	squarePicker.hue = hue;
	
	[ self updateResultColor ];
}

//------------------------------------------------------------------------------

- (IBAction) takeSquareValue: (InfColorSquarePicker*) sender
{    
	saturation = sender.value.x;
	brightness = sender.value.y;
    
	[ self updateResultColor ];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) informDelegateDidChangeColor
{
	if( self.delegate && [ (id) self.delegate respondsToSelector: @selector( palette:didPickColor:) ] )
    {
        DrawColor *color = [[[DrawColor alloc] initWithColor:self.resultColor] autorelease];
        [self.delegate palette:self didPickColor:color];
    }
}

//------------------------------------------------------------------------------

- (void) updateResultColor
{
	// This is used when code internally causes the update.  We do this so that
	// we don't cause push-back on the HSV values in case there are rounding
	// differences or anything.  However, given protections from hue and sat
	// changes when not necessary elsewhere it's probably not actually needed.
	
	[ self willChangeValueForKey: @"resultColor" ];
	
	[ resultColor release ];
	resultColor = [ [ UIColor colorWithHue: hue saturation: saturation
								brightness: brightness alpha: 1.0f ] retain ];
	
	[ self didChangeValueForKey: @"resultColor" ];
	
    [resultColorView updateWithUIColor:resultColor];
	
	[ self informDelegateDidChangeColor ];
}

//------------------------------------------------------------------------------

- (void) setResultColor: (UIColor*) newValue
{
	if( ![ resultColor isEqual: newValue ] ) {
		[ resultColor release ];
		resultColor = [ newValue retain ];
		
		float h = hue;
		HSVFromUIColor( newValue, &h, &saturation, &brightness );
		
		if( h != hue ) {
			hue = h;
			
			barPicker.value = hue;
			squareView.hue = hue;
			squarePicker.hue = hue;
		}
		
		squarePicker.value = CGPointMake( saturation, brightness );
        
        [resultColorView updateWithUIColor:resultColor];
        
		[ self informDelegateDidChangeColor ];
	}
}

//------------------------------------------------------------------------------

- (void) setSourceColor: (UIColor*) newValue
{
	if( ![ sourceColor isEqual: newValue ] ) {
		[ sourceColor release ];
		sourceColor = [ newValue retain ];
		self.resultColor = newValue;
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
//    [self informDelegateDidChangeColor];
    
}

@end

//==============================================================================

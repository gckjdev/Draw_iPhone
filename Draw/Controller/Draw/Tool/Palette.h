
@class InfColorBarView;
@class InfColorSquareView;
@class InfColorBarPicker;
@class InfColorSquarePicker;
@class DrawColor;
@class ColorPoint;

@protocol ColorPickingBoxDelegate;

//------------------------------------------------------------------------------

@interface Palette : UIView {
	float hue;
	float saturation;
	float brightness;
}

// Public API:

+ (id) paletteWithDelegate:(id<ColorPickingBoxDelegate>)delegate;

@property( retain, nonatomic ) UIColor* sourceColor;
@property( retain, nonatomic ) UIColor* resultColor;
@property( assign, nonatomic ) id< ColorPickingBoxDelegate> delegate;

// IB outlets:

@property( retain, nonatomic ) IBOutlet InfColorBarView* barView;
@property( retain, nonatomic ) IBOutlet InfColorSquareView* squareView;
@property( retain, nonatomic ) IBOutlet InfColorBarPicker* barPicker;
@property( retain, nonatomic ) IBOutlet InfColorSquarePicker* squarePicker;
@property( retain, nonatomic ) IBOutlet ColorPoint* resultColorView;

- (IBAction) takeBarValue: (id) sender;
- (IBAction) takeSquareValue: (id) sender;


@end

//------------------------------------------------------------------------------

@protocol ColorPickingBoxDelegate <NSObject>

@optional
- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color;

@end


//------------------------------------------------------------------------------

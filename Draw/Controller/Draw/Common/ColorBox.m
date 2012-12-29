//
//  ColorBox.m
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import "ColorBox.h"

@interface ColorBox ()
{
    
}

@property (retain, nonatomic) IBOutlet UIView *defaultColorView;
@property (retain, nonatomic) IBOutlet UITableView *colorTableView;

- (IBAction)clickCloseButton:(id)sender;
- (IBAction)clickMoreButton:(id)sender;


@end

@implementation ColorBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)clickCloseButton:(id)sender {
    
}

- (IBAction)clickMoreButton:(id)sender {
    
}
- (void)dealloc {
    [_defaultColorView release];
    [_colorTableView release];
    [super dealloc];
}
@end

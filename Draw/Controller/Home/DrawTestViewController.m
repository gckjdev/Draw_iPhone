//
//  TestViewController.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "DrawTestViewController.h"
#import "ColorPoint.h"
#import "DrawSlider.h"

@interface DrawTestViewController ()

@end

@implementation DrawTestViewController


+ (DrawTestViewController *)enterWithController:(UIViewController *)controller
{
    DrawTestViewController *test = [[[DrawTestViewController alloc] init] autorelease];
    [controller.navigationController pushViewController:test animated:YES];
    return test;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    ColorPoint *point = [ColorPoint pointWithColor:[DrawColor orangeColor]];
//    point.center = self.view.center;
//    point.selected = YES;
//    [self.view addSubview:point];

    DrawSlider *slider = [[DrawSlider alloc] initWithDrawSliderStyle:DrawSliderStyleLarge];
    slider.center = self.view.center;
    [self.view addSubview:slider];
    
//    UIImage *bg = [UIImage imageNamed:@"draw_slider2_bg"];
//    UIImage *load = [UIImage imageNamed:@"draw_slider2_load"];
//    UIImage *p = [UIImage imageNamed:@"draw_slider2_point@2x.png"];
//    
//    [_slider setMaximumTrackImage:bg forState:UIControlStateNormal];
//    
//    [_slider setMinimumTrackImage:load forState:UIControlStateNormal];
//    [_slider setBackgroundColor:[UIColor colorWithPatternImage:bg]];
////    [_slider setMaximumTrackImage:p forState:<#(UIControlState)#>]
//    [_slider setThumbImage:p forState:UIControlStateNormal];
//    [_slider setFrame:CGRectMake(10, 200, 96, 12)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_slider release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSlider:nil];
    [super viewDidUnload];
}
@end

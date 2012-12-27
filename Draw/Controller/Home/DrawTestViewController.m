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
#import "DrawToolPanel.h"


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

- (void)drawSlider:(DrawSlider *)drawSlider
    didValueChange:(CGFloat)value
       pointCenter:(CGPoint)center
{
    CMPopTipView *pop = nil;
    if (drawSlider == slider1) {
        pop = pop1;
    }else
    {
        pop = pop2;
    }
//    [pop presentPointingAtView:drawSlider inView:self.view animated:YES];
    NSString *v = [NSString stringWithFormat:@"%.1f",value];
    UILabel *label = (UILabel *)pop.customView;
    [label setText:v];
}


- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    //hide pop view
    CMPopTipView *pop = nil;
    if (drawSlider == slider1) {
        pop = pop1;
    }else
    {
        pop = pop2;
    }
//    [pop presentPointingAtView:drawSlider inView:self.view animated:YES];
    [pop dismissAnimated:NO];
//    NSString *v = [NSString stringWithFormat:@"%f",value];
//    UILabel *label = (UILabel *)pop.customView;
//    [label setText:v];
}

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    //show pop View
    CMPopTipView *pop = nil;
    if (drawSlider == slider1) {
        pop = pop1;
    }else
    {
        pop = pop2;
    }

    [pop presentPointingAtView:slider1 inView:self.view animated:NO];
//    pop.alpha = 1;
    NSString *v = [NSString stringWithFormat:@"%.1f",value];
    UILabel *label = (UILabel *)pop.customView;
    [label setText:v];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    ColorPoint *point = [ColorPoint pointWithColor:[DrawColor orangeColor]];
//    point.center = self.view.center;
//    point.selected = YES;
//    [self.view addSubview:point];

    slider2 = [[[DrawSlider alloc] initWithDrawSliderStyle:DrawSliderStyleSmall] autorelease];
    slider2.center = self.view.center;
    [self.view addSubview:slider2];

    UILabel *l1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)] autorelease];
    UILabel *l2 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)] autorelease];
    
    pop1 = [[CMPopTipView alloc] initWithCustomView:l1];
    pop2 = [[CMPopTipView alloc] initWithCustomView:l2];
    
    slider1 = [[[DrawSlider alloc] initWithDrawSliderStyle:DrawSliderStyleLarge] autorelease];
    slider1.center = CGPointMake(100, 300);
    slider1.delegate = self;
    slider2.delegate = self;
    [self.view addSubview:slider1];

    
    DrawToolPanel *panel = [DrawToolPanel createViewWithdelegate:nil];
    [self.view addSubview:panel];
    
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

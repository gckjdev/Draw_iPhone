//
//  TestViewController.m
//  Draw
//
//  Created by gamy on 12-12-25.
//
//

#import "DrawTestViewController.h"
#import "ColorPoint.h"

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
    ColorPoint *point = [ColorPoint pointWithColor:[DrawColor orangeColor]];
    point.center = self.view.center;
    point.selected = YES;
    [self.view addSubview:point];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
